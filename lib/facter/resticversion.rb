Facter.add('restic_version') do
  setcode do
    if File.exists?('/usr/bin/restic')
      Facter::Core::Execution.execute('/usr/bin/restic version')
    end

  end
end








