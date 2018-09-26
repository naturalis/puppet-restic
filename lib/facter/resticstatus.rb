Facter.add('restic_status') do
  setcode do
    Facter::Core::Execution.execute('/usr/bin/chkrestic')
  end
end








