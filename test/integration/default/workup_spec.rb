# frozen_string_literal: true

# Give chef some time to get installed
sleep 120 if os.family == 'windows'

def env(cmd, **options)
  (options.map do |k, v|
    os.family == 'windows' ? "$env:#{k} = '#{v}';" : "#{k}='#{v}'"
  end + [*cmd]).join(' ')
end

case os.family
when 'windows'
  workup_cmd = '$env:PATH = "C:/opscode/chefdk/bin;${env:PATH}"; chef exec workup'
  policyfile_git = '${env:USERPROFILE}/.workup/Policyfile_git.rb'
else
  workup_cmd = '/Users/vagrant/.chefdk/gem/ruby/2.1.0/bin/workup'
  policyfile_git = '~/.workup/Policyfile_git.rb'
end

describe command(env(workup_cmd, PASSWORD: 'vagrant')) do
  its('exit_status') { should eq 0 }
  its('stdout') { should match 'Chef Client finished, 0/0 resources updated' }
  its('stderr') { should be_empty }
end

describe command(env("#{workup_cmd} --policyfile #{policyfile_git}", PASSWORD: 'vagrant')) do
  its('exit_status') { should eq 0 }
  its('stdout') { should match 'Chef Client finished, 0/0 resources updated' }
  its('stderr') { should be_empty }
end
