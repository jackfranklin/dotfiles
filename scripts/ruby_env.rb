#!/usr/bin/env ruby

brews = %w{rbenv ruby-build}

puts "Making sure Homebrew exists"
if `which brew` == ""
  puts "Installing Homebrew"
  `ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"`
end

puts "Before doing anything, going to update brew"
`brew update`

brews.each do |brew|
  o = `brew install #{brew} 2>&1`
  o = `brew upgrade #{brew} 2>&1`
end

ruby_version = `ruby -v`
latest_version = "1.9.3"
latest_patch = "448"


# ruby 1.9.3p429 (2013-05-15 revision 40747) [x86_64-darwin12.4.1]
/ruby ([0-9\.]{5})p([0-9]{3})/.match(ruby_version) { |match|
  version = match[1]
  patch = match[2]

  if version != latest_version || patch != latest_patch
    puts "Installing Ruby #{latest_version}p#{latest_patch}"
    `rbenv install #{latest_version}-p#{latest_patch}`
    puts "Setting new Ruby as global"
    `rbenv global #{latest_version}-p#{latest_patch}`
  else
    puts "Ruby up to date (1.9.3)"
  end
}
