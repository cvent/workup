#!/bin/bash

set -e

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo 'Bootstrapping workup'

WORKUP_BRANCH='master' # Useful for testing
WORKUP_URL="https://raw.githubusercontent.com/cvent/workup/${WORKUP_BRANCH}"

WORKUP_DIR="${HOME}/.workup"
WORKUP_BINS="${WORKUP_DIR}/bin"

CHEFDK_URL='https://omnitruck.chef.io/install.sh'
CHEFDK_VERSION='0.17.17'

echo_success() {
  printf "\033[1;32m$1\033[0m\n"
}

echo_warning() {
  printf "\033[1;33m$1\033[0m\n"
}

printf "Checking for ChefDK >= v${CHEFDK_VERSION}... "
if command -v '/usr/local/bin/chef' > /dev/null; then
  # From https://stackoverflow.com/questions/4023830/bash-how-compare-two-strings-in-version-format
  vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
  }

  chefdk_version_regex="^Chef Development Kit Version: (.+)$"
  if [[ "$(/usr/local/bin/chef env -v)" =~ $chefdk_version_regex ]]; then
    vercomp "${BASH_REMATCH[1]}" "${CHEFDK_VERSION}"
    if [[ "${?}" == '-1' ]]; then install_chef='true'; else install_chef='false'; fi

    printf "v${BASH_REMATCH[1]} found "
  else
    install_chef=true
  fi

  if ${install_chef}; then
    echo_warning "Too old"
  else
    echo_success "OK"
  fi
else
  echo_warning "Not found"
  install_chef='true'
fi

if ${install_chef}; then
  printf "Installing ChefDK v${CHEFDK_VERSION}... "
  curl -Ls "${CHEFDK_URL}" | sudo bash -s -- -P 'chefdk' -v "${CHEFDK_VERSION}" > /dev/null
  echo_success "OK"
fi

printf 'Creating workup directory... '
[ -d "${WORKUP_DIR}" ] || mkdir "${WORKUP_DIR}"
echo_success "OK"

printf 'Creating bin directory... '
[ -d "${WORKUP_BINS}" ] || mkdir "${WORKUP_BINS}"
echo_success "OK"

printf 'Fetching new Policyfile... '
curl -Lsko "${WORKUP_DIR}/Policyfile.rb" "${WORKUP_URL}/Policyfile.rb"
echo_success "OK"

printf 'Fetching new client.rb... '
curl -Lsko "${WORKUP_DIR}/client.rb" "${WORKUP_URL}/client.rb"
echo_success "OK"

printf 'Fetching workup... '
curl -Lsko "${WORKUP_BINS}/workup" "${WORKUP_URL}/workup.sh"
chmod +x "${WORKUP_BINS}/workup"
echo_success "OK"

printf 'Installing workup... '
local_bin='/usr/local/bin/workup'
[[ -h ${local_bin} ]] || ln -s "${WORKUP_BINS}/workup" "${local_bin}"
echo_success "OK"

printf 'Checking PATH for /usr/local/bin... '
local_regex='(^|:)/usr/local/bin/?($|:)'
if [[ "${PATH}" =~ $local_regex ]]; then
  echo_success "OK"
  echo 'You are ready to run workup'
else
  echo_warning "Not found"
fi
