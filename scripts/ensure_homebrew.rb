#!/usr/bin/env ruby

if `which brew` == ""
  puts `ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"`
end
