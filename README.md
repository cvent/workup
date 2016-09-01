# Workup

[![Build status](https://ci.appveyor.com/api/projects/status/hu0nygm28cbs040s/branch/master?svg=true)](https://ci.appveyor.com/project/jonathanmorley/workup-pn3lv/branch/master)
[![Build Status](https://travis-ci.org/cvent/workup.svg?branch=master)](https://travis-ci.org/cvent/workup)

Workup is a workstation provisioning tool that focuses on cross-compatibility
and minimal assumptions about the initial state of the machine.

All data is stored in `~/.workup`

## What does it do?

Workup uses Chef Policyfiles to run cookbooks

## Installation

### As a gem

Add this line to your application's Gemfile:

```ruby
gem 'workup'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install workup

### As a command

#### UNIX, Linux and MacOS
On UNIX, Linux and MacOS systems the install script is invoked with:

    curl -L 'https://raw.githubusercontent.com/cvent/workup/master/bootstrap.sh' | sudo bash

#### Microsoft Windows
On Microsoft Windows systems the install script is invoked using Windows
PowerShell as an Administrator (The first command should not produce
any output):

    Set-ExecutionPolicy -Force RemoteSigned # Enable remote scripts
    (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/cvent/workup/master/bootstrap.ps1') | iex

## Usage

### Upgrading workup

Re-run the installation script above

### Uninstall workup

  * Remove `~/.workup`
  * `sudo rm /usr/local/bin/workup` (Non-windows operating systems only)

### Converging your workstation
On Microsoft Windows systems, you may find that your machine restarts during the execution of this command. Please re-issue this command to continue the setup.

    workup

### Customizing workup

You can modify the `~/.workup/Policyfile.rb` to use different chef cookbooks.
Note, these changes will currently be overwritten if you run the bootstrap script.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cvent/workup.

# Thanks

This is based on the [pantry](https://github.com/chef/pantry-chef-repo) project
by Chef.
