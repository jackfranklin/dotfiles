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
  tree
  tmux
  reattach-to-user-namespace
  leiningen
  cmake
  redis
  gnu-sed
}

after_commands = {
  "mongo" => "ln -sfv /usr/local/opt/mongodb/*.plist ~/Library/LaunchAgents",
  "redis" => "ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents && launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist"
}

puts "Making sure Homebrew exists"
if `which brew` == ""
  puts "Installing Homebrew"
  `ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"`
end

puts "Before doing anything, going to update brew"
`brew update`


installed = `brew ls`
brews.each do |brew|
  if installed.include?(brew)
    puts "#{brew} already installed"
  else
    puts "running brew install #{brew}"
    puts `brew install #{brew}`
    puts "running after_commands for #{brew}"
    puts `#{after_commands[brew]}` unless after_commands[brew].nil?
  end
end

`rbenv rehash`
