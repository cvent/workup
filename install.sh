#!/bin/bash

set -e

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo_success() {
  printf "\033[1;32m%s\033[0m\n" "$1"
}

echo_warning() {
  printf "\033[1;33m%s\033[0m\n" "$1"
}

echo_error() {
  printf "\031[1;33m%s\033[0m\n" "$1"
}

echo 'Bootstrapping Workup'

WORKUP_VERSION="0.1.5"
WORKUP_URL="https://github.com/cvent/workup/releases/download/v${WORKUP_VERSION}/workup.pkg"
WORKUP_DIR="${HOME}/.workup"

# MacOS Sierra's git does not function out of the box. It requires an xcode install
# From https://github.com/timsutton/osx-vm-templates/blob/master/scripts/xcode-cli-tools.sh

for i in {1..3}
do
  if [[ $(xcode-\select -p 2> /dev/null) ]]; then
    break
  else
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

printf "Installing Workup v%s... " "${WORKUP_VERSION}"
installer="${WORKUP_DIR}/workup.pkg"
curl -Ls "${WORKUP_URL}" -o "${installer}"
if /usr/sbin/installer -target / -pkg "${installer}" > /dev/null; then
  echo_success 'OK'
fi

WORKUP_PATH_DIR='/usr/local/bin'
printf 'Checking PATH for %s... ' "${WORKUP_PATH_DIR}"
local_regex="(^|:)${WORKUP_PATH_DIR}/?(\$|:)"
if [[ "${PATH}" =~ $local_regex ]]; then
  echo_success 'OK'
else
  echo_error "Not found, please add ${WORKUP_PATH_DIR} to your PATH"
  exit 1
fi

echo 'You are ready to run workup'
