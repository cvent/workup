$ErrorActionPreference = "Stop"

If (!([Security.Principal.WindowsPrincipal] `
     [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
}

Function Reset-Path {
  $MachinePaths = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine) -split ';'
  $UserPaths = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::User) -split ';'
  $Env:Path = ($MachinePaths + $UserPaths) -join ';'
}

Function Add-ToPath {
  Param([string]$Path)
  $Path = $Path.TrimEnd('/')

  Reset-Path
  $Paths = $Env:Path -split ';'
  If (!($Paths -contains $Path) -and !($Paths -contains "${Path}/")) {
    $MachinePaths = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine) -split ';'
    $MachinePaths = $Path + $MachinePaths
    [Environment]::SetEnvironmentVariable('Path', ($MachinePaths -join ';'), [System.EnvironmentVariableTarget]::Machine)
    Reset-Path
  }
}

Write-Host 'Bootstrapping workup'

$WORKUP_URL = 'https://raw.githubusercontent.com/cvent/workup/master'
$WORKUP_DIR = Join-Path ${HOME} '.workup'

$CHEFDK_URL = 'https://omnitruck.chef.io/install.ps1'
$CHEFDK_VERSION = '0.17.17'

$wc = New-Object System.Net.WebClient

Write-Host -NoNewLine "Checking for ChefDK >= v${CHEFDK_VERSION}... "
If (Get-Command chef -ErrorAction SilentlyContinue) {
  $current_chef_version = (chef --version | select -first 1) -replace 'Chef Development Kit Version: ',''

  $install_chef = (([System.Version] ${current_chef_version}) -lt ([System.Version] ${CHEFDK_VERSION}))

  Write-Host -NoNewLine "v${current_chef_version} found "

  If ($install_chef) {
    Write-Host -ForegroundColor 'Yellow' 'Too old'
  } Else {
    Write-Host -ForegroundColor 'Green' 'OK'
  }
} Else {
  Write-Host -ForegroundColor 'Yellow' 'Not found'
  $install_chef = $true
}

If (${install_chef}) {
  Get-WmiObject `
      -Class Win32_Product `
      -Filter "Name LIKE 'Chef Development Kit%'" |% {
    Write-Host -NoNewLine "Uninstalling ChefDK v$($_.Version)... "
    $_.Uninstall() | Out-Null
    Write-Host -ForegroundColor 'Green' 'OK'
  }

  Write-Host -NoNewLine "Installing ChefDK v${CHEFDK_VERSION}... "
  . { $wc.DownloadString(${CHEFDK_URL}) } | iex | Out-Null
  install -project 'chefdk' -version ${CHEFDK_VERSION} | Out-Null
  Write-Host -ForegroundColor 'Green' 'OK'
}

# ChefDK binaries
Add-ToPath 'C:\opscode\chefdk\bin'

# Chef gem binaries
Add-ToPath (Join-Path ${ENV:LOCALAPPDATA} 'chefdk\gem\ruby\2.1.0\bin')

Write-Host -NoNewLine 'Installing latest workup... '
chef gem list -i workup
If ($LASTEXITCODE -eq 0) { chef gem update workup }
Else { chef gem install workup }
Write-Host -ForegroundColor 'Green' 'OK'

If (Test-Path ${WORKUP_DIR} -PathType 'Container') {
  Write-Host "~/.workup directory already exists"
} ElseIf (Test-Path ${WORKUP_DIR} -PathType 'Leaf') {
  Throw "~/.workup is unexpectedly a file. Please resolve this and try again"
} Else {
  Write-Host -NoNewLine "Creating ~/.workup directory... "
  New-Item -Type Directory ${WORKUP_DIR} | Out-Null
  Write-Host -ForegroundColor 'Green' 'OK'
}

@('Policyfile.rb', 'client.rb') |% {
  Write-Host -NoNewLine "Fetching new ${_}... "
  $wc.DownloadFile("${WORKUP_URL}/files/${_}", (Join-Path ${WORKUP_DIR} ${_}))
  Write-Host -ForegroundColor 'Green' 'OK'
}

Write-Host 'You are ready to run workup'
