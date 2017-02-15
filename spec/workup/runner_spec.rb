# frozen_string_literal: true
require 'spec_helper'

describe Workup::Runner do
  let(:runner) do
    Workup::Runner.new(nil, workup_dir: '/home/test/.workup',
                            policyfile: '~/.workup/Policyfile.rb')
  end

  it '.workup_dir' do
    expect(runner.chef_client_config).to eq '/home/test/.workup/client.rb'
  end

  it '.policyfile' do
    expect(runner.policyfile).to eq "#{Dir.home}/.workup/Policyfile.rb"
  end

  it '.chefzero_path' do
    expect(runner.chefzero_path).to eq '/home/test/.workup/chef-zero'
  end
end
