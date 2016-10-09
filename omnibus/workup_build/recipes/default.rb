if node['os'] == 'windows'
  powershell_script 'Disable password complexity requirements' do
    code <<-EOH
      secedit /export /cfg $env:temp/export.cfg
      ((get-content $env:temp/export.cfg) -replace ('PasswordComplexity = 1', 'PasswordComplexity = 0')) | Out-File $env:temp/export.cfg
      secedit /configure /db $env:windir/security/new.sdb /cfg $env:temp/export.cfg /areas SECURITYPOLICY
    EOH
  end

  include_recipe 'omnibus'

  powershell_script 'copy elsewhere' do
    code 'Copy-Item -Recurse /home/vagrant/workup /Users/vagrant/workup'
  end
else
  include_recipe 'omnibus'
end

omnibus_build 'workup' do
  project_dir '/Users/vagrant/workup/omnibus'
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
    command 'installer -pkg $(ls /Users/vagrant/workup/omnibus/pkg/*.pkg | tail -n1) -target /'
  end
when 'windows'
end
