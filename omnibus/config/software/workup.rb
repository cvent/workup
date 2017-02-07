# frozen_string_literal: true
#
# Copyright 2016 YOUR NAME
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

require_relative '../../../lib/workup/version.rb'

name 'workup'
default_version Workup::VERSION

source path: File.expand_path('../..', project.files_path),
       options: { exclude: ['omnibus/vendor'] }

# For nokogiri
dependency 'libxml2'
dependency 'libxslt'
dependency 'libiconv'
dependency 'liblzma'
dependency 'zlib'

# ruby and bundler and friends
dependency 'ruby'
dependency 'rubygems'
dependency 'bundler'
dependency 'appbundler'

if windows?
  dependency 'ruby-windows-devkit'
  dependency 'git-windows'
end

# Version manifest file
dependency 'version-manifest'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  delete "#{name}-*.gem"

  # We bundle install to ensure the versions of gems we are going to
  # appbundle-lock to are definitely installed
  bundle 'install', env: env

  gem "build #{name}.gemspec", env: env
  gem "install #{name}-*.gem --no-document", env: env

  appbundle 'workup', env: env

  block do
    ['workup', 'git'].each do |cmd|
      open("#{install_dir}/bin/#{cmd}.bat", "w") do |file|
        file.print <<-EOH
  @ECHO OFF
  "%~dp0\\..\\embedded\\bin\\#{cmd}.bat" %*
  EOH
      end
    end
  end if windows?
end
