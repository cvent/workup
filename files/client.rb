# frozen_string_literal: true

## Local directories
chef_repo_path              File.join(__dir__, 'chef-zero')
file_cache_path             File.join(__dir__, 'local-cache')

## Chef zero settings
local_mode                  true
chef_zero.enabled           true

## Logging
log_level                   :error
add_formatter               'doc'

## Node information
node_name((ENV['SUDO_USER'] || ENV['USER'] || ENV['USERNAME']).downcase)

# This plugin causes OS X to hang for 5 minutes before every chef client run
ohai.disabled_plugins = [:Passwd]

## Pull in Policyfile config
local_config = File.join(chef_repo_path, '.chef', 'config.rb')
eval(IO.read(local_config)) if File.exist? local_config
