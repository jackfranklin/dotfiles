#!/usr/bin/env ruby

if `which brew` == ""
  puts `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
end
