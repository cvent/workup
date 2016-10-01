include_recipe 'omnibus'

omnibus_build 'workup' do
  project_dir '/Users/vagrant/workup/omnibus'
  log_level :internal
end

directory (windows? ? 'C:\\workup' : '/opt/workup') do
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
