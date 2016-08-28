# Workup

[![Build status](https://ci.appveyor.com/api/projects/status/altgdohi6glq09ij/branch/master?svg=true)](https://ci.appveyor.com/project/jonathanmorley/workup/branch/master)

Workup is a workstation provisioning tool that focuses on cross-compatibility
and minimal assumptions about the initial state of the machine.

All data is stored in `~/.workup`

## What does it do?

Workup uses Chef policyfiles to run cookbooks

## Install

### UNIX, Linux and MacOS
On UNIX, Linux and MacOS systems the install script is invoked with:

    curl -L 'https://raw.githubusercontent.com/jonathanmorley/workup/master/bootstrap.sh' | sudo bash

### Microsoft Windows
On Microsoft Windows systems the install script is invoked using Windows
PowerShell as an Administrator (The first command should not produce
any output):

    Set-ExecutionPolicy -Force RemoteSigned # Enable remote scripts
    (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jonathanmorley/workup/master/bootstrap.ps1') | iex


## Upgrading workup

Re-run the installation script above

## Uninstall workup

  * Remove `~/.workup`
  * `sudo rm /usr/local/bin/workup` (Non-windows operating systems only)

## Converging your workstation
On Microsoft Windows systems, you may find that your machine restarts during the execution of this command. Please re-issue this command to continue the setup.

    workup

# Customizing workup

You can modify the `~/.workup/Policyfile.rb` to use different chef cookbooks.
Note, these changes will currently be overwritten if you run the bootstrap script.

# Thanks

This is based on the [pantry](https://github.com/chef/pantry-chef-repo) project
by Chef.
