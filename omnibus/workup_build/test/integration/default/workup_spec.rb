# frozen_string_literal: true
describe file('/usr/local/bin/workup') do
  it { should exist }
end

# Waiting on login shell support
describe command('workup') do
  it { should exist }
end

describe command('PASSWORD=vagrant /usr/local/bin/workup') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match 'Chef Client finished, 0/0 resources updated' }
end
