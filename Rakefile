require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

namespace :test do
  RuboCop::RakeTask.new(:lint)
  RSpec::Core::RakeTask.new(:spec)
end

task test: ['test:lint', 'test:spec']

task :files do
  FileUtils.cp_r 'files/.', File.join(ENV['HOME'], '.workup')
end

task :package do
  `rm -rf ./pkg`
  `vagrant up 
end

task default: :test
