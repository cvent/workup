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

override :ruby, version: "2.2.5"

exclude "**/.git"
exclude "**/bundler/git"

compress :dmg do
  window_bounds '200, 200, 750, 600'
  pkg_position '10, 10'
end
