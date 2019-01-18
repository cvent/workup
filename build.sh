#!/bin/bash

# Time to omnibus this
pushd omnibus

# install all dependencies for packaging
bundle install

# Build macos package
bundle exec kitchen test macos

rm -rf .bundle/ vendor/

# Build windows package
bundle exec kitchen test windows

popd

echo "Build completed check in ./omnibus/pkg for the packages"
