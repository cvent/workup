require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

namespace :test do
  RuboCop::RakeTask.new(:lint)
  RSpec::Core::RakeTask.new(:spec)
end

task test: ['test:lint', 'test:spec']

directory "#{ENV['HOME']}/.workup"

%w(client.rb Policyfile.rb).each do |f|
  file "#{ENV['HOME']}/.workup/#{f}" => "files/#{f}" do
    cp "files/#{f}" "#{ENV['HOME']}/.workup/#{f}"
  end

  desc 'Copy files into place'
  task files: "#{ENV['HOME']}/.workup/#{f}"
end

task default: :test
