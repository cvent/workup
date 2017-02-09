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
require 'workup/runner'
require 'workup/logging'

require 'thor'
require 'pathname'

module Workup
  class Application < Thor
    class_option :workup_dir, type: :string, default: File.join(Dir.home, '.workup')
    class_option :policyfile, type: :string, default: File.join(Dir.home, '.workup', 'Policyfile.rb')
    class_option :dry_run, type: :boolean, default: false
    class_option :verify_ssl, type: :boolean, default: true
    class_option :password, type: :boolean, default: false

    attr_reader :log

    def initialize(*args)
      @log ||= begin
        log = ::Logging.logger['workup']
        log.add_appenders('stdout')
        log.level = :debug
        log
      end

      super(*args)
    end

    desc 'workup', 'Run Workup'
    def workup
      if (ENV['SUDO_USER'] || ENV['USER']) == 'root'
        raise 'You cannot run workup as root directly'
      end

      Workup::Runner.new(log, options).run
    end

    default_task :workup
  end
end
