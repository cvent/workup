#!/bin/bash

rake clobber build

pushd omnibus

kitchen test macos
rm -rf .bundle
rm -rf vendor
rm -rf Gemfile.lock
kitchen test windows

popd
