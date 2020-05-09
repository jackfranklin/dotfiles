function suspended-jobs
  if jobs -c > /dev/null
    jobs -c | tail | grep -v '^$' | paste -s -d","
  end
end
