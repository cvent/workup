# Workup

[![Build status](https://ci.appveyor.com/api/projects/status/hu0nygm28cbs040s/branch/master?svg=true)](https://ci.appveyor.com/project/jonathanmorley/workup-pn3lv/branch/master)
[![Build Status](https://travis-ci.org/cvent/workup.svg?branch=master)](https://travis-ci.org/cvent/workup)

Workup is a workstation provisioning tool that focuses on cross-compatibility
and minimal assumptions about the initial state of the machine.

All data is stored in `~/.workup`

## What does it do?

Workup uses Chef Policyfiles to run cookbooks

## Installation

### As a package

#### MacOS
On MacOS systems the install script is invoked with:

    curl -L 'https://raw.githubusercontent.com/cvent/workup/master/install.sh' | sudo bash

#### Microsoft Windows
On Microsoft Windows systems the install script is invoked using Windows
PowerShell as an Administrator (The first command should not produce
any output):

    Set-ExecutionPolicy -Force RemoteSigned # Enable remote scripts
    (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/cvent/workup/master/install.ps1') | iex

### As a gem

    chef gem install workup

## Usage

### Upgrading workup

Re-run the install script above

### Uninstall workup

#### MacOS

    sudo rm -rf /opt/workup
    sudo rm -f /usr/local/bin/workup
    sudo pkgutil --forget com.cvent.pkg.workup
    # And if you want to forget all your system configuration data
    sudo rm -rf ~/.workup

### Converging your workstation

    workup

### Customizing workup

You can modify the `~/.workup/Policyfile.rb` to use different chef cookbooks.
Note, these changes will currently be overwritten if you run the install script.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cvent/workup.

# Thanks

This was based on the [pantry](https://github.com/chef/pantry-chef-repo) project
by Chef.
