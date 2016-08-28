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
    $MachinePaths += $Path
    [Environment]::SetEnvironmentVariable('Path', ($MachinePaths -join ';'), [System.EnvironmentVariableTarget]::Machine)
    Reset-Path
  }
}

Write-Host 'Bootstrapping workup'

$WORKUP_BRANCH = 'master' # Useful for testing
$WORKUP_URL = "https://raw.githubusercontent.com/jonathanmorley/workup/${WORKUP_BRANCH}"

$WORKUP_DIR = Join-Path ${HOME} '.workup'
$WORKUP_BINS = Join-Path ${WORKUP_DIR} 'bin'

$CHEFDK_URL = 'https://omnitruck.chef.io/install.ps1'
$CHEFDK_VERSION = '0.15.15'

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

Add-ToPath 'C:\opscode\chefdk\bin'

@(${WORKUP_DIR}, ${WORKUP_BINS}) |% {
  $leaf_name = Split-Path ${_} -Leaf
  If (Test-Path ${_} -PathType 'Container') {
    Write-Host "${leaf_name} directory already exists"
  } ElseIf (Test-Path ${_} -PathType 'Leaf') {
    Throw "${_} is unexpectedly a file. Please resolve this and try again"
  } Else {
    Write-Host -NoNewLine "Creating ${leaf_name} directory... "
    New-Item -Type Directory ${_} | Out-Null
    Write-Host -ForegroundColor 'Green' 'OK'
  }
}

@('Policyfile.rb', 'client.rb') |% {
  Write-Host -NoNewLine "Fetching new ${_}... "
  $wc.DownloadFile("${WORKUP_URL}/${_}", (Join-Path ${WORKUP_DIR} ${_}))
  Write-Host -ForegroundColor 'Green' 'OK'
}

Write-Host -NoNewLine 'Fetching new workup script... '
$workup_bin = Join-Path ${WORKUP_BINS} 'workup'
$wc.DownloadFile("${WORKUP_URL}/workup.ps1", "${workup_bin}.ps1")
If(!(Test-Path ${workup_bin})) { cmd /c mklink ${workup_bin} "${workup_bin}.ps1" }

Write-Host -ForegroundColor 'Green' 'OK'

Add-ToPath $WORKUP_BINS

Write-Host 'You are ready to run workup'
