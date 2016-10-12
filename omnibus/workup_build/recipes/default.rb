
# frozen_string_literal: true
powershell_script 'Disable password complexity requirements' do
  code <<-EOH
    secedit /export /cfg $env:temp/export.cfg
    ((get-content $env:temp/export.cfg) -replace ('PasswordComplexity = 1', 'PasswordComplexity = 0')) | Out-File $env:temp/export.cfg
    secedit /configure /db $env:windir/security/new.sdb /cfg $env:temp/export.cfg /areas SECURITYPOLICY
  EOH
end if node['os'] == 'windows'

include_recipe 'omnibus'

execute 'copy elsewhere' do
  command 'robocopy /mir /Users/vagrant/workup /vagrant/code/workup'
  returns [0, 1, 2, 3]
end if node['os'] == 'windows'

omnibus_build 'workup' do
  project_dir '/vagrant/code/workup/omnibus'
  log_level :internal
end

directory node['workup_build']['build_dir'] do
  action :delete
  recursive true
end

case node['os']
when 'darwin'
  execute 'install workup' do
    action :run
    command 'installer -pkg $(ls /vagrant/code/workup/omnibus/pkg/*.pkg | tail -n1) -target /'
  end
when 'windows'
end
