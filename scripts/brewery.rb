#!/usr/bin/env ruby

brews = File.readlines("brews.txt").map(&:chomp)

after_commands = {
  "mongodb" => "ln -sfv /usr/local/opt/mongodb/*.plist ~/Library/LaunchAgents",
  "redis" => "ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents && launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist"
}

installed = `brew ls`
brews.each do |brew|
  if installed.include?(brew)
    puts "#{brew} already installed"
  else
    puts "running brew install #{brew}"
    puts `brew install #{brew}`
    unless after_commands[brew].nil?
      puts "running after_commands for #{brew}"
      puts `#{after_commands[brew]}`
    end
  end
end

puts "Rehashing rbenv"
`rbenv rehash`
