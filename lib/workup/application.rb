# frozen_string_literal: true
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
require 'thor'
require 'pathname'

module Workup
  class Application < Thor
    class_option :workup_dir, type: :string, default: File.join(Dir.home, '.workup')
    class_option :policyfile, type: :string, default: File.join(Dir.home, '.workup', 'Policyfile.rb')
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

      Workup::Helpers.check_user

      super(*args)
    end

    no_commands do
      def chef_lib(description)
        log.info description
        return_code = Workup::Helpers.silence { yield }
        if return_code.zero?
          log.debug "OK\n"
        else
          log.error "Failure\n"
          exit return_code
        end
      end
    end

    desc 'default', 'Default task'
    def default
      chef_zero
      workup
    end

    desc 'chef_zero', 'Create the chef-zero directory'
    def chef_zero
      Workup::Helpers.initialize_files(options[:workup_dir])

      policyfile = options[:policyfile]
      policyfile = File.join(Dir.pwd, policyfile) if Pathname.new(policyfile).relative?

      chefzero_path = File.join(options[:workup_dir], 'chef-zero')

      chef_lib('Updating lock file... ') do
        ChefDK::Command::Update.new.run([policyfile])
      end

      chef_lib('Creating chef-zero directory... ') do
        ChefDK::Command::Export.new.run(['--force', policyfile, chefzero_path])
      end
    end

    desc 'workup', 'Run workup'
    def workup
      log.info "Starting workup\n"
      Workup::Helpers.initialize_files(options[:workup_dir])
      Workup::Helpers.chef_client(File.join(options[:workup_dir], 'client.rb'),
                                  options[:dry_run])
    end

    default_task :default
  end
end
