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

require 'mixlib/shellout'

module Workup
  class Helpers
    class << self
      def check_user
        user = ENV['SUDO_USER'] || ENV['USER']
        raise 'You cannot run workup as root directly' if user == 'root'
      end

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

      def silence
        $stdout = StringIO.new
        yield
      ensure
        $stdout = STDOUT
      end

      def execute(*cmd, **args)
        command = Gem.win_platform? ? cmd.join(' ') : cmd
        Mixlib::ShellOut.new(command, **args).run_command
      end

      def chef_bin(executable)
        [
          "#{Gem.win_platform? ? '/cvent' : '/opt' }/workup/embedded/bin/#{executable}",
          "#{Gem.win_platform? ? '/opscode' : '/opt'}/chefdk/bin/#{executable}",
          "#{Gem.win_platform? ? '/opscode' : '/opt'}/chef/bin/#{executable}"
        ].find(-> { raise "#{executable} not found" }) { |path| File.exist? path }
      end

      def chef_client(client_rb, dry_run = false)
        cmd = [chef_bin('chef-client'), '--no-fork', '--config', client_rb]
        cmd << '-A' if Gem.win_platform?
        cmd << '--why-run' if dry_run

        execute(*cmd, live_stdout: STDOUT, live_stderr: STDERR, timeout: 6*60*60)
      end

      def chef_apply(recipe, dry_run = false)
        cmd = [chef_bin('chef-apply'), '--log_level', 'fatal', '--minimal-ohai']
        cmd << '--why-run' if dry_run
        if Gem.win_platform?
          cmd.concat(['--execute', "\"#{recipe.gsub(/\n/, ';')}\""])
        else
          cmd.concat(['--execute', recipe])
        end

        execute(*cmd, live_stdout: STDOUT, live_stderr: STDERR)
      end

      def initialize_files(workup_dir)
        chef_apply("directory('#{workup_dir}') { recursive true }")

        files_dir = File.join(File.dirname(File.expand_path(__FILE__)), '../../files')

        Dir.glob("#{files_dir}/*")
           .each do |f|
             chef_apply %(file '#{File.join(workup_dir, File.basename(f))}' do
               action :create_if_missing
               content IO.read('#{f}')
             end)
           end
      end
    end
  end
end
