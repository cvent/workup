$ErrorActionPreference = "Stop"

$CHEFDK_URL = 'https://omnitruck.chef.io/install.ps1'
$CHEFDK_VERSION = '0.17.17'

# Install chef
If(!(Test-Path 'C:/opscode/chefdk/bin/chef')) {
  . { (New-Object System.Net.WebClient).DownloadString(${CHEFDK_URL}) } | iex | Out-Null
  install -project 'chefdk' -version ${CHEFDK_VERSION} | Out-Null
}

$KITCHEN_DATA = "${env:TEMP}/kitchen/data"

# Install workup
C:/opscode/chefdk/bin/chef gem install "${KITCHEN_DATA}/pkg/workup-0.1.5.gem"

# Make a policyfile to test git
If(!(Test-Path -Path '~/.workup')){ New-Item '~/.workup' -Type Directory }
Copy-Item "${KITCHEN_DATA}/files/Policyfile.rb" '~/.workup/Policyfile_git.rb'
Add-Content '~/.workup/Policyfile_git.rb' "cookbook 'nop', github: 'sczizzo/Archive', rel: 'nop-cookbook'"
