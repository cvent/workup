# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'workup/version'

Gem::Specification.new do |spec|
  spec.name          = 'workup'
  spec.version       = Workup::VERSION
  spec.licenses      = ['Apache-2.0']
  spec.authors       = ['Morley, Jonathan']
  spec.email         = ['JMorley@cvent.com']

  spec.summary       = 'A workstation provisioner.'
  spec.description   = 'Workup is a workstation provisioning tool that focuses on cross-compatibility
  and minimal assumptions about the initial state of the machine.'
  spec.homepage      = 'https://github.com/cvent/workup'

  spec.files         = Dir.glob('{lib,files,exe}/**/*', File::FNM_DOTMATCH)
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 11.2'
  spec.add_development_dependency 'rubocop', '~> 0.42.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'test-kitchen', '~> 1.15'
  spec.add_development_dependency 'kitchen-vagrant', '~> 1.0'

  spec.add_dependency 'thor', '~> 0.19.1'
  spec.add_dependency 'logging', '~> 2.1'
  spec.add_dependency 'chef-dk', '~> 0.17.17'
  spec.add_dependency 'chef', '< 12.15.19' # chef-config 12.15.19 is not released
  spec.add_dependency 'mixlib-shellout', '~> 2.2'
end
