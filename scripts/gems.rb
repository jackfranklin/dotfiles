#!/usr/bin/env ruby

gems = %w{
  rails
  rake
  bundler
  jekyll
  shotgun
}

gems.each do |gem|
  unless `gem list --local`.include?(gem)
    puts "Installing #{gem}"
    `gem install #{gem} --no-rdoc --no-ri`
  end
end
