$ErrorActionPreference = "Stop"

If (!([Security.Principal.WindowsPrincipal] `
     [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
}

$WORKUP_DIR = Join-Path ${HOME} '.workup'
$WORKUP_BINS = Join-Path ${WORKUP_DIR} 'bin'
chef exec ruby (Join-Path ${WORKUP_BINS} 'workup.rb') $args
