chef_repo_path              File.join __dir__, 'chef-zero'
file_cache_path             File.join __dir__, 'local-cache'

## Chef zero settings
local_mode                  true
chef_zero.enabled           true
log_level                   :error
add_formatter               'doc'
node_name                   (ENV['SUDO_USER'] || ENV['USER'] || ENV['USERNAME']).downcase

## Policyfile settings
policy_name                 'workup'
policy_group                'local'
use_policyfile              true
policy_document_native_api  true

# This plugin causes OS X to hang for 5 minutes before every chef client run
ohai.disabled_plugins       = [:Passwd]
