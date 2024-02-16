function fixwsldate
  # WSL2 lets the date get out of sync
  sudo ntpdate pool.ntp.org
end
