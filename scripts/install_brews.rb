#!/usr/bin/env ruby

brews = %w{
  ruby-build
  rbenv
  ack
  ctags
  git
  mongodb
  wget
  vim
  tree
  tmux
  reattach-to-user-namespace
  leiningen
  gnu-sed
  the_silver_searcher
  youtube-dl
  hub
  z
  macvim
  python
  autoenv
  watchman
  fzf
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
