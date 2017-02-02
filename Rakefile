# frozen_string_literal: true
require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'kitchen/rake_tasks'

task test: ['test:lint', 'test:spec']
namespace :test do
  RuboCop::RakeTask.new(:lint)
  RSpec::Core::RakeTask.new(:spec)
end

task :files do
  FileUtils.cp_r 'files/.', File.join(ENV['HOME'], '.workup')
end

omnibus_platforms = [:macos, :windows]

desc 'Build omnibus packages'
task omnibus: omnibus_platforms.map { |platform| "omnibus:#{platform}" }
namespace :omnibus do
  omnibus_platforms.each do |platform|
    task platform => [:clobber, :test, :build, "kitchen:default-#{platform}"]
  end
end

task default: :test
