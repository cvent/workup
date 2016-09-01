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

def sudo_wrap(*cmd)
  ['sudo', '-k', '-S', "-p''", '--', *cmd]
end

def execute(*cmd, **args)
  sudo_required = RUBY_PLATFORM !~ /mswin|mingw32|windows/ &&
                  !ENV['SUDO_USER']

  command = sudo_required ? sudo_wrap(*cmd) : cmd
  stdin = sudo_required ? "#{password}\n" : nil

  shell_out = Mixlib::ShellOut.new(command, user: user, cwd: options[:workup_dir], input: stdin, **args)

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
  class_option :workup_dir, type: :string, default: File.join(Dir.home(user), '.workup')

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

    log.info "Running chef-client\n"
    execute('chef-client', '--no-fork', '--config', clientrb_path,
            env: { PASSWORD: password })
  end

  default_task :workup
end

Workup.start(ARGV)
