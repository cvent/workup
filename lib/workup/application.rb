require 'mixlib/shellout'
require 'thor'

require 'workup/helpers'

module Workup
  class Application < Thor
    class_option :workup_dir, type: :string, default: File.join(Dir.home, '.workup')
    class_option :dry_run, type: :boolean, default: false

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

      client_cmd = ['chef-client', '--no-fork', '--config', clientrb_path]
      client_cmd << '-A' if windows?
      client_cmd << '--why-run' if options[:dry_run]

      execute(*client_cmd, env: { PASSWORD: password },
              live_stdout: STDOUT, live_stderr: STDERR)
    end

    default_task :workup
  end
end
