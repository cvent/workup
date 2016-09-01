require "bundler/gem_tasks"
require 'rubocop/rake_task'
require "rspec/core/rake_task"

namespace :test
  RuboCop::RakeTask.new(:lint)
  RSpec::Core::RakeTask.new(:spec)
end

task test: ['test:lint', 'test:spec']

task :default => :test
