# frozen_string_literal: true

def env(cmd, **options)
  (options.map do |k, v|
    os.family == 'windows' ? "$env:#{k} = '#{v}';" : "#{k}='#{v}'"
  end + [*cmd]).join(' ')
end

# Waiting on login shell support for unix
describe command('workup') do
  it { should exist }
end if os.family == 'windows'

workup_bin = case os.family
             when 'windows' then 'C:/workup/bin/workup.bat'
             else '/usr/local/bin/workup'
             end

describe file(workup_bin) do
  it { should exist }
end

describe command(env(workup_bin, PASSWORD: 'vagrant')) do
  its('exit_status') { should eq 0 }
  its('stdout') { should match 'Chef Client finished, 0/0 resources updated' }
  its('stderr') { should be_empty }
end
