require 'mixlib/shellout'
require 'thor'

def log
  @log ||= begin
    require 'logging'

    Logging.color_scheme('bright', lines: { debug: :green, error: :red })
    Logging.appenders.stdout(
      'stdout',
      layout: Logging.layouts.pattern(pattern: '%m', color_scheme: 'bright')
    )

    log = Logging.logger['workup']
    log.add_appenders('stdout')
    log.level = :debug
    log
  end
end

def user
  @user ||= begin
    user = ENV['SUDO_USER'] || ENV['USER']
    raise 'You cannot run workup as root directly' if user == 'root'
    user
  end
end

def password
  @password ||= begin
    require 'io/console'

    print 'Enter Password: '
    password = STDIN.noecho(&:gets).chomp
    puts
    password
  end
end

def sudo_wrap(*cmd, **args)
  env_vars = (args[:env] || []).map { |k, v| "#{k}=#{v}" }
  ['sudo', *env_vars, '-k', '-S', '-p', '', '--', *cmd]
end

def execute(*cmd, **args)
  windows = RUBY_PLATFORM =~ /mswin|mingw32|windows/
  sudo_required = !windows && !ENV['SUDO_USER']

  command = sudo_required ? sudo_wrap(*cmd, args) : cmd

  command = command.join(' ') if windows

  shell_out = Mixlib::ShellOut.new(command, cwd: options[:workup_dir], **args)
  shell_out.user = user if !windows
  shell_out.input = "#{password}\n" if sudo_required

  shell_out.run_command

  if shell_out.error?
    log.error "Error\n"
    log.error shell_out.inspect
    log.error shell_out.stdout
    log.error shell_out.stderr
    exit shell_out.exitstatus
  else
    log.debug "OK\n"
  end
end

class Workup < Thor
  class_option :workup_dir, type: :string, default: File.join(Dir.home, '.workup')

  desc 'workup', 'Run workup'
  def workup
    password = password()
    log.info "Starting workup\n"

    chef_zero
    chef_client
  end

  desc 'chef_zero', 'Create the chef-zero directory'
  def chef_zero
    raise 'Workup directory does not exist' unless File.exist?(options[:workup_dir])
    policy_path = File.join(options[:workup_dir], 'Policyfile.rb')
    lock_path = File.join(options[:workup_dir], 'Policyfile.lock.json')
    chefzero_path = File.join(options[:workup_dir], 'chef-zero')

    log.info 'Updating lock file... '
    execute('chef', (File.exist?(lock_path) ? 'update' : 'install'), policy_path,
            env: { GIT_SSL_NO_VERIFY: 'true' })

    log.info 'Creating chef-zero directory... '
    execute('chef', 'export', '--force', policy_path, chefzero_path,
            env: { GIT_SSL_NO_VERIFY: 'true' })
  end

  desc 'chef_client', 'Run chef-client'
  def chef_client
    raise 'Workup directory does not exist' unless File.exist?(options[:workup_dir])
    clientrb_path = File.join(options[:workup_dir], 'client.rb')

    execute('chef-client', '--no-fork', '--config', clientrb_path,
            env: { PASSWORD: password }, live_stdout: STDOUT, live_stderr: STDERR)
  end

  default_task :workup
end

Workup.start(ARGV)
