if node['os'] == 'windows'
  powershell_script 'Disable password complexity requirements' do
    code <<-EOH
      secedit /export /cfg $env:temp/export.cfg
      ((get-content $env:temp/export.cfg) -replace ('PasswordComplexity = 1', 'PasswordComplexity = 0')) | Out-File $env:temp/export.cfg
      secedit /configure /db $env:windir/security/new.sdb /cfg $env:temp/export.cfg /areas SECURITYPOLICY
    EOH
  end

  #include_recipe 'git'

  #include_recipe 'rubyinstaller'
  #gem_package 'bundler'

  #file '/Users/vagrant/load-omnibus-toolchain.bat'

  include_recipe 'omnibus'

  powershell_script 'copy elsewhere' do
    code 'Copy-Item -Recurse /home/vagrant/workup /Users/vagrant/workup'
  end

  powershell_script 'install libyaml' do
    code '/Users/vagrant/load-omnibus-toolchain.ps1; pacman -S --noconfirm libyaml'
  end
else
  include_recipe 'omnibus'
end

omnibus_build 'workup' do
  project_dir '/Users/vagrant/workup/omnibus'
  log_level :internal
end

workup_build_dir = node['os'] == 'windows' ? '/workup' : '/opt/workup'
directory workup_build_dir do
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
