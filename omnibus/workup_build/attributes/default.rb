default['omnibus']['build_user'] = 'vagrant'
default['omnibus']['build_user_home'] = '/Users/vagrant'
default['omnibus']['build_user_password'] = 'vagrant'

case node['os']
when 'windows'
  default['workup_build']['build_dir'] = '/workup'
else
  default['omnibus']['build_user_group'] = 'vagrant'
  default['workup_build']['build_dir'] = '/opt/workup'
end
