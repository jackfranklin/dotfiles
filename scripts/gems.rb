#!/usr/bin/env ruby

gems = %w{
  rails
  rake
  bundler
  jekyll
  shotgun
}

gems.each do |gem|
  puts "Installing #{gem}"
  `gem install #{gem} --no-rdoc --no-ri`
end
