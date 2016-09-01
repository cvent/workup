require 'mixlib/shellout'
require 'thor'

module Workup
  class Helpers
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

    def windows?
      RUBY_PLATFORM =~ /mswin|mingw32|windows/
    end

    def sudo_wrap(*cmd, **args)
      env_vars = (args[:env] || []).map { |k, v| "#{k}=#{v}" }
      ['sudo', *env_vars, '-k', '-S', '-p', '', '--', *cmd]
    end

    def execute(*cmd, **args)
      sudo_required = !windows? && !ENV['SUDO_USER']

      command = sudo_required ? sudo_wrap(*cmd, args) : cmd

      command = command.join(' ') if windows?

      shell_out = Mixlib::ShellOut.new(command, cwd: options[:workup_dir], **args)
      shell_out.user = user unless windows?
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
  end
end
