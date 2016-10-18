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

# These options are required for all software definitions
name 'workup'
default_version 'local_source'

# For the specific super-special version "local_source", build the source from
# the local git checkout. This is what you'd want to occur by default if you
# just ran omnibus build locally.
version('local_source') do
  source path: File.expand_path('../..', project.files_path),
         # Since we are using the local repo, we try to not copy any files
         # that are generated in the process of bundle installing omnibus.
         # If the install steps are well-behaved, this should not matter
         # since we only perform bundle and gem installs from the
         # omnibus cache source directory, but we do this regardless
         # to maintain consistency between what a local build sees and
         # what a github based build will see.
         options: { exclude: ['omnibus/vendor'] }
end

# For any version other than "local_source", fetch from github.
source git: 'git://github.com/cvent/workup.git' if version != 'local_source'

# For nokogiri
dependency 'libxml2'
dependency 'libxslt'
dependency 'libiconv'
dependency 'liblzma'
dependency 'zlib'

# ruby and bundler and friends
dependency 'ruby'
dependency 'ruby-windows-devkit' if windows?
dependency 'rubygems'
dependency 'bundler'

# dependency "chef"

# Version manifest file
dependency 'version-manifest'

build do
  command 'cat C:\workup\embedded\bin\gem'

  env = with_standard_compiler_flags(with_embedded_path)

  gem 'install pkg/workup-0.1.1.gem', env: env

  block do
    open("#{install_dir}/bin/workup.bat", "w") do |file|
      file.print <<-EOH
@ECHO OFF
"%~dp0\\..\\embedded\\bin\\workup.bat" %*
EOH
    end
  end if windows?
end
