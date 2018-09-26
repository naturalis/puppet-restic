Facter.add('restic_status') do
  setcode do
    if File.exists?('/usr/bin/chkrestic')
      Facter::Core::Execution.execute('/usr/bin/chkrestic')
    end
  end
end








