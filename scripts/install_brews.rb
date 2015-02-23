#!/usr/bin/env ruby

brews = %w{
  ruby-build
  rbenv
  ack
  ctags
  git
  mercurial
  mongodb
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
  the_silver_searcher
  erlang
  elixir
  youtube-dl
  hub
  z
  macvim
  python
  autoenv
}

INSTALLED_BREWS = `brew list`.split("\n")

brews.each do |brew|
  if INSTALLED_BREWS.include?(brew)
    puts "#{brew} already installed"
  else
    puts "Installing #{brew}"
    puts `brew install #{brew}`
  end

end
