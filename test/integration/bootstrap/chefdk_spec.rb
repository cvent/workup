describe command('chef') do
  it { should exist }
end

describe command('chef --version') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /0\.15\.15/ }
end
