#!/usr/bin/env ruby

puts "Checking if you have command-line tools installed"
if `pkgutil --pkg-info=com.apple.pkg.DeveloperToolsCLI` == ""
	puts "Please install the latest Xcode, then navigate to preferences->downloads and install command-line tools"
	abort
else
	puts "Pre-checks complete, your ready to go!"
	# need to put in a script line that quits the script
	`exit`
end

# maybe check to make sure curl is installed (it should be)