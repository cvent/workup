include_recipe 'omnibus'

omnibus_build 'workup' do
  project_dir '/Users/vagrant/workup/omnibus'
  log_level :internal
end
