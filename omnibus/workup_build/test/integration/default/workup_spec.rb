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

case os.family
when 'windows'
 workup_bin = 'C:/cvent/workup/bin/workup.bat'
 policyfile_git = '${env:USERPROFILE}/.workup/Policyfile_git.rb'
else
 workup_bin = '/usr/local/bin/workup'
 policyfile_git = '~/.workup/Policyfile_git.rb'
end

describe file(workup_bin) do
  it { should exist }
end

describe command(env(workup_bin, PASSWORD: 'vagrant')) do
  its('exit_status') { should eq 0 }
  its('stdout') { should match 'Chef Client finished, 0/0 resources updated' }
  its('stderr') { should be_empty }
end

describe command(env("#{workup_bin} --policyfile #{policyfile_git}", PASSWORD: 'vagrant')) do
  its('exit_status') { should eq 0 }
  its('stdout') { should match 'Chef Client finished, 0/0 resources updated' }
  its('stderr') { should be_empty }
end
