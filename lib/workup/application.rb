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

      Workup::Helpers.check_user

      super(*args)
    end

    desc 'default', 'Default task'
    def default
      chef_zero
      workup
    end

    desc 'chef_zero', 'Create the chef-zero directory'
    def chef_zero
      Workup::Helpers.initialize_files(options[:workup_dir])

      policy_path = File.join(options[:workup_dir], 'Policyfile.rb')
      chefzero_path = File.join(options[:workup_dir], 'chef-zero')

      log.info 'Updating lock file... '
      Workup::Helpers.silence { ChefDK::Command::Update.new.run([policy_path]) }
      log.debug "OK\n"

      log.info 'Creating chef-zero directory... '
      Workup::Helpers.silence do
        ChefDK::Command::Export.new.run(['--force', policy_path, chefzero_path])
      end
      log.debug "OK\n"
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
