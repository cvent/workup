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

module Workup
  class Helpers
    class << self
      def check_user!
        user = ENV['SUDO_USER'] || ENV['USER']
        raise 'You cannot run workup as root directly' if user == 'root'
      end

      def initialize_files!(workup_dir)
        files_dir = File.join(File.dirname(File.expand_path(__FILE__)), '../../files')

        Dir.mkdir workup_dir unless File.directory? workup_dir
        FileUtils.cp_r "#{files_dir}/.", workup_dir
      end

      def silence
        $stdout = StringIO.new
        yield
      ensure
        $stdout = STDOUT
      end
    end
  end
end
