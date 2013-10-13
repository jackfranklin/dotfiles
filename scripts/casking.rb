#!/usr/bin/env ruby

casks = %w{
  fantastical
}

#   google-chrome
#   iterm2
#   alfred
#   app-cleaner
#   divvy
#   dropbox
#   mou
#   mplayerx
#   propane
#   skype
#   sparrow
#   spotify
#   sublime-text
#   u-torrent
#   x-quartz

# some apps
# visicosity - a VPN app
# one-password
# sequal-pro - mysql client
# vagrant
# evernote
# gitx


puts "Installing Homebrew Cask!"
`brew tap phinze/homebrew-cask 2>&1`
`brew install brew-cask 2>&1`

installed = `brew ls`
if installed.include?("brew-cask")
  puts "brew-cask is installed"
else
  puts "Shit brew-cask never installed itself"
end

# check if each app is already installed in brew cask list
installedApps = `brew cask list`
casks.each do |cask|
  if installedApps.include?(cask)
    puts "#{cask} already installed"
  else
    puts "running brew cask install #{cask}"
    puts `brew cask install --appdir="/Applications" #{cask}`
  end
end

puts "Linking brew cask with Alfred!"
puts `brew cask alfred link`
