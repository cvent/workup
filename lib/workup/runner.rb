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
#

require 'workup/helpers'
require 'chef-dk/command/update'
require 'chef-dk/command/export'

module Workup
  class Runner
    def initialize(logger, options)
      @logger = logger
      @options = options
    end

    def run
      Workup::Helpers.initialize_files(workup_dir)
      prompt_for_password if password_required?

      chef_lib('Updating lock file... ') do
        ChefDK::Command::Update.new.run([policyfile])
      end

      chef_lib('Creating chef-zero directory... ') do
        ChefDK::Command::Export.new.run(['--force', policyfile, chefzero_path])
      end

      Workup::Helpers.chef_client(chef_client_config, dry_run?)
    end

    def password_required?
      @options[:password]
    end

    def dry_run?
      @options[:dry_run]
    end

    def workup_dir
      @options[:workup_dir]
    end

    def chef_client_config
      File.join(workup_dir, 'client.rb')
    end

    def policyfile
      File.expand_path(@options[:policyfile], __FILE__)
    end

    def chefzero_path
      File.join(workup_dir, 'chef-zero')
    end

    private

    def prompt_for_password
      ENV['PASSWORD'] ||= begin
                            if STDIN.tty?
                              print 'Enter Password: '
                              password = STDIN.noecho(&:gets).chomp
                              puts
                              password
                            end
                          end
    end

    def chef_lib(description)
      @logger.info description
      return_code = Workup::Helpers.silence { yield }
      if return_code.zero?
        @logger.debug "OK\n"
      else
        @logger.error "Failure\n"
        exit return_code
      end
    end
  end
end
