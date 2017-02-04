#!/bin/bash

# Need to remove extra files and build workup gem
bundle exec rake clobber

# Time to omnibus this
pushd omnibus

# remove previous traces of builds and install dependencies
rm -rf pkg
bundle install

# Build macos package
bundle exec kitchen test macos
rm -rf .bundle/ vendor/ Gemfile.lock

# Build windows package
bundle exec kitchen test windows

popd

echo "Build completed check in ./omnibus/pkg for the packages"
