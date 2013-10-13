#!/usr/bin/env ruby

brews = %w{
  ack
  ctags
  git
  mercurial
  mongodb
  node
  phantomjs
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
