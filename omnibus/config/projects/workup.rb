#
# Copyright 2016 YOUR NAME
#
# All Rights Reserved.
#

name "workup"
maintainer "Cvent"
homepage "https://github.com/cvent/workup"

# Defaults to C:/workup on Windows
# and /opt/workup on all other platforms
install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration 1

# Creates required build directories
dependency "preparation"

# workup dependencies/components
dependency "workup"

dependency 'shebang-cleanup'

exclude "**/.git"
exclude "**/bundler/git"
