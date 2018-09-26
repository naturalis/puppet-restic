Facter.add('restic_version') do
  setcode do
    Facter::Core::Execution.execute('/usr/bin/restic version')
  end
end








