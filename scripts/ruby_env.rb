#!/usr/bin/env ruby


ruby_version = `ruby -v`
latest_version = "1.9.3"
latest_patch = "484"

versions_wanted = [
  [ '1.9.3', '484' ],
  [ '2.1.0', '']
]
versions_installed = `rbenv versions`

versions_wanted.each do |version|

  /ruby ([0-9\.]{5})(?:p([0-9]{3}))?/.match(ruby_version) { |match|
    current_version = match[1]
    current_patch = match[2]

    current_string = version[0]
    unless version[1].empty?
      current_string += "-p#{version[1]}"
    end

    unless versions_installed.include?(current_string)
      puts "Need to install #{version}"
      if version[1].empty?
         `rbenv install #{version[0]}`
      else
        `rbenv install #{version[0]}-p#{version[1]}`
      end
    end
  }

end

default_version = versions_wanted.last
install_string = default_version[0]
unless default_version[1].empty?
  install_string += "-p#{default_version[1]}"
end

`rbenv global #{install_string}`
