# frozen_string_literal: true

def env(cmd, **options)
  (options.map do |k, v|
    os.family == 'windows' ? "$env:#{k} = '#{v}';" : "#{k}='#{v}'"
  end + [*cmd]).join(' ')
end

workup_bins = os.family == 'windows' ? 'C:/workup/bin' : '/usr/local/bin'
workup_bin = File.join(workup_bins, 'workup')

describe file(workup_bin) do
  it { should exist }
end

# Waiting on login shell support
# describe command('workup') do
#   it { should exist }
# end

describe command(env(workup_bin, PASSWORD: 'vagrant')) do
  its('exit_status') { should eq 0 }
  its('stdout') { should match 'Chef Client finished, 0/0 resources updated' }
  its('stderr') { should be_empty }
end
