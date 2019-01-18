# frozen_string_literal: true
require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

task test: ['test:lint', 'test:spec']
namespace :test do
  RuboCop::RakeTask.new(:lint)
  RSpec::Core::RakeTask.new(:spec)
end

task :files do
  FileUtils.cp_r 'files/.', File.join(ENV['HOME'], '.workup')
end

task default: :test
