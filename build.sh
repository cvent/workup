#!/bin/bash

rake clobber build

pushd omnibus

rm -rf pkg
kitchen test macos
rm -rf .bundle
rm -rf vendor
rm -f Gemfile.lock
kitchen test windows

popd
