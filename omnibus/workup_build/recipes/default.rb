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

directory '/Users/vagrant/.workup' do
  action :create
  recursive true
end

case node['os']
when 'darwin'
  execute 'install workup' do
    action :run
    command 'installer -pkg $(ls /vagrant/code/workup/omnibus/pkg/*.pkg | tail -n1) -target /'
  end

  execute 'create Policyfile_git' do
    command 'cp /vagrant/code/workup/files/Policyfile.rb /Users/vagrant/.workup/Policyfile_git.rb'
    returns [0, 1, 2, 3]
  end

  execute 'make Policyfile use git' do
    action :run
    command 'echo "cookbook \'nop\', github: \'sczizzo/Archive\', rel: \'nop-cookbook\'" >> ~/.workup/Policyfile_git.rb'
  end
when 'windows'
  execute 'copy pkg back' do
    command 'robocopy /vagrant/code/workup/omnibus/pkg /Users/vagrant/workup/omnibus/pkg'
    returns [0, 1, 2, 3]
  end

  powershell_script 'install workup' do
    action :run
    code "cmd /c start '' /wait msiexec /i (ls /vagrant/code/workup/omnibus/pkg/*.msi | select -last 1).FullName /qn"
  end

  execute 'create Policyfile_git' do
    command 'robocopy /vagrant/code/workup/files/Policyfile.rb /Users/vagrant/.workup/Policyfile_git.rb'
    returns [0, 1, 2, 3]
  end

  powershell_script 'Make Policyfile use git' do
    code <<-EOH
    Add-Content '~/.workup/Policyfile_git.rb' "cookbook 'nop', github: 'sczizzo/Archive', rel: 'nop-cookbook'"
    EOH
  end
end
