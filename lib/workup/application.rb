#
# Copyright:: Copyright (c) 2016 Cvent Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'workup/helpers'
require 'workup/logging'

require 'chef-dk/command/update'
require 'chef-dk/command/export'
require 'mixlib/shellout'
require 'thor'

module Workup
  class Application < Thor
    class_option :workup_dir, type: :string, default: File.join(Dir.home, '.workup')
    class_option :dry_run, type: :boolean, default: false
    class_option :verify_ssl, type: :boolean, default: true

    attr_reader :log

    def initialize(*args)
      @log ||= begin
        log = ::Logging.logger['workup']
        log.add_appenders('stdout')
        log.level = :debug
        log
      end

      Workup::Helpers.check_user!

      super(*args)
    end

    no_commands do
      def execute(*cmd, **args)
        command = Gem.win_platform? ? cmd.join(' ') : cmd

        shell_out = Mixlib::ShellOut.new(command, **args)
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

    desc 'default', 'Default task'
    def default
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
      Workup::Helpers.silence do
        ChefDK::Command::Update.new.run([policy_path])
      end
      log.debug "OK\n"

      log.info 'Creating chef-zero directory... '
      Workup::Helpers.silence do
        ChefDK::Command::Export.new.run(['--force', policy_path, chefzero_path])
      end
      log.debug "OK\n"
    end

    desc 'chef_client', 'Run chef-client'
    def chef_client
      raise 'Workup directory does not exist' unless File.exist?(options[:workup_dir])
      clientrb_path = File.join(options[:workup_dir], 'client.rb')

      chef_client_dir = if Gem.win_platform?
        'C:/opscode/workup/embedded/bin'
      else
        '/opt/workup/embedded/bin'
      end

      client_cmd = ['./chef-client', '--no-fork', '--config', clientrb_path]
      client_cmd << '-A' if Gem.win_platform?
      client_cmd << '--why-run' if options[:dry_run]

      execute(*client_cmd, live_stdout: STDOUT, live_stderr: STDERR, cwd: chef_client_dir)
    end

    default_task :default
  end
end
