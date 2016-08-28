$ErrorActionPreference = "Stop"

If (!([Security.Principal.WindowsPrincipal] `
     [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
}

$response = Read-host "Enter Password" -AsSecureString
$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($response))

Write-Host 'Starting workup'

$WORKUP_DIR = Join-Path ${HOME} '.workup'

If (Test-Path (Join-Path ${WORKUP_DIR} 'Policyfile.lock.json')) {
  Write-Host -NoNewLine 'Updating lock file... '
  $env:GIT_SSL_NO_VERIFY = $true
  chef update "${WORKUP_DIR}/Policyfile.rb" | Out-Null
  Write-Host -ForegroundColor 'Green' 'OK'
} Else {
  Write-Host -NoNewLine 'Creating lock file... '
  $env:GIT_SSL_NO_VERIFY = $true
  chef install "${WORKUP_DIR}/Policyfile.rb" | Out-Null
  Write-Host -ForegroundColor 'Green' 'OK'
}

Write-Host -NoNewLine 'Creating chef-zero directory... '
chef export --force (Join-Path ${WORKUP_DIR} 'Policyfile.rb') (Join-Path ${WORKUP_DIR} 'chef-zero') | Out-Null
Write-Host -ForegroundColor 'Green' 'OK'

Write-Host 'Running chef-client'
Try {
  $env:PASSWORD = $password
  chef-client --config (Join-Path ${WORKUP_DIR} 'client.rb')
} Finally {
  Remove-Item env:\password
}
