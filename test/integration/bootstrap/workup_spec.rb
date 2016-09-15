describe command('workup') do
  it { should exist }
  its('exit_status') { should eq 0 }
end

describe command("bash -l -c \"shopt -q login_shell && echo 'Login shell' || echo 'Not login shell'\"") do
  its(:stdout) { should match /fff/ }
end
