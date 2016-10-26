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

echo 'Bootstrapping Workup'

WORKUP_VERSION="0.1.2"
WORKUP_URL="https://github.com/cvent/workup/releases/download/v${WORKUP_VERSION}/workup.pkg"
WORKUP_DIR="${HOME}/.workup"

printf 'Creating ~/.workup directory... '
[ -d "${WORKUP_DIR}" ] || mkdir "${WORKUP_DIR}"
echo_success "OK"

printf "Installing Workup v%s... " "${WORKUP_VERSION}"
installer="${WORKUP_DIR}/workup.pkg"
curl -Ls "${WORKUP_URL}" -o "${installer}"
/usr/sbin/installer -target / -pkg "${installer}"
echo_success 'OK'

printf 'Checking PATH for /usr/local/bin... '
local_regex='(^|:)/usr/local/bin/?($|:)'
if [[ "${PATH}" =~ $local_regex ]]; then
  echo_success 'OK'
  echo 'You are ready to run workup'
else
  echo_warning 'Not found'
fi
