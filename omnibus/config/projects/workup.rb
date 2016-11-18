# frozen_string_literal: true
#
# Copyright 2016 YOUR NAME
#
# All Rights Reserved.
#

name 'workup'
maintainer 'Cvent'
homepage 'https://github.com/cvent/workup'

# Defaults to C:/workup on Windows
# and /opt/workup on all other platforms
install_dir "#{default_root}/#{name}"

build_version '0.1.6'

build_iteration 1

# Creates required build directories
dependency 'preparation'

# workup dependencies/components
dependency 'workup'

override :"ruby-windows-devkit", version: '4.5.2-20111229-1559' if windows? && windows_arch_i386?

dependency 'shebang-cleanup'
dependency 'openssl-customization'

exclude '**/.git'
exclude '**/bundler/git'

project_location_dir = name
package :msi do
  fast_msi true
  upgrade_code '769d8737-c798-49d1-bab0-0a31da3ee7df'.capitalize
  parameters ProjectLocationDir: project_location_dir
end
