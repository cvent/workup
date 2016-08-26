#!/bin/bash

set -e

read -s -p "Enter Password: " password </dev/tty
echo -n -e "\n"

if [[ ${EUID} -eq 0 ]] && [[ -n "${SUDO_USER}" ]]; then
  user="$SUDO_USER"
else
  user="$USER"
fi

# Make sure the script is not run directly as root
if [[ ${user} == 'root' ]]; then
   echo "Do not run this script as root" 1>&2
   exit 1
fi

# If password is incorrect
if ! sudo -u "${user}" sudo -k -p '' -S true <<< "${password}" 2> /dev/null; then
  echo "The password you entered is incorrect"
  exit 2
fi

echo 'Starting workup'

WORKUP_DIR="${HOME}/.workup"

printf 'Running chef shell-init... '
eval "$(/usr/local/bin/chef shell-init bash)"
printf "\033[1;32mOK\033[0m\n"

if [[ -e "${WORKUP_DIR}/Policyfile.lock.json" ]]; then
  printf 'Updating lock file... '
  sudo -u "${user}" sudo -k -p '' -S GIT_SSL_NO_VERIFY=true chef update "${WORKUP_DIR}/Policyfile.rb" > /dev/null <<< "${password}"
  printf "\033[1;32mOK\033[0m\n"
else
  printf 'Creating lock file... '
  sudo -u "${user}" sudo -k -p '' -S GIT_SSL_NO_VERIFY=true chef install "${WORKUP_DIR}/Policyfile.rb" > /dev/null <<< "${password}"
  printf "\033[1;32mOK\033[0m\n"
fi

printf 'Creating chef-zero directory... '
sudo -u "${user}" sudo -k -p '' -S chef export --force "${WORKUP_DIR}/Policyfile.rb" "${WORKUP_DIR}/chef-zero" > /dev/null <<< "${password}"
printf "\033[1;32mOK\033[0m\n"

echo 'Running chef-client'
sudo -u "${user}" sudo -k -p '' -S PASSWORD="${password}" chef-client --config "${WORKUP_DIR}/client.rb" <<< "${password}"
