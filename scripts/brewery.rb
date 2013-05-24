#!/usr/bin/env ruby

brews = %w{
  ack
  ctags
  git
  mercurial
  mongodb
  node
  phantomjs
  rbenv
  ruby-build
  wget
  vim
}

puts "Before doing anything, going to update brew"
`brew update`


installed = `brew ls`
brews.each do |brew|
  if(installed.include? brew)
    puts "#{brew} already installed"
  else
    puts "running brew install #{brew}"
    puts `brew install #{brew}`
  end
end
