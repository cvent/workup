#!/bin/bash

set -e

CHEFDK_URL='https://omnitruck.chef.io/install.sh'
CHEFDK_VERSION='0.17.17'

# Install chef
if ! command -v '/usr/local/bin/chef' > /dev/null; then
  curl -Ls "${CHEFDK_URL}" | sudo bash -s -- -P 'chefdk' -v "${CHEFDK_VERSION}"
fi

# MacOS Sierra's git does not function out of the box. It requires an xcode install
# From https://github.com/timsutton/osx-vm-templates/blob/master/scripts/xcode-cli-tools.sh

for i in {1..3}
do
  if [[ ! $(xcode-\select -p 2> /dev/null) ]]; then
    # create the placeholder file that's checked by CLI updates'
    # .dist code in Apple's SUS catalog
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    # find the CLI Tools update
    OSX_VERSION=$(sw_vers -productVersion)
    PROD=$(softwareupdate -l |
      grep "\*.*Command Line.*${OSX_VERSION}" |
      head -n 1 |
      awk -F"*" '{print $2}' |
      sed -e 's/^ *//' |
      tr -d '\n')

    if [[ ! -z "${PROD}" ]]; then
      # install it
      softwareupdate -i "${PROD}"
      rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
      break
    fi
  fi
done

if [[ $(xcode-\select -p 2> /dev/null) ]]; then
  echo "Xcode installed after $i attempts"
else
  echo "Xcode not installed after $i attempts"
  exit 2
fi

# Install workup
/opt/chefdk/bin/chef gem install /tmp/kitchen/data/pkg/workup-0.1.5.gem -V

# Make a policyfile to test git
mkdir -p ~/.workup
cp /tmp/kitchen/data/files/Policyfile.rb ~/.workup/Policyfile_git.rb
echo "cookbook 'nop', github: 'sczizzo/Archive', rel: 'nop-cookbook'" >> ~/.workup/Policyfile_git.rb
