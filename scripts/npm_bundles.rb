#!/usr/bin/env ruby
#
puts "Making sure n exists"
if `which n` == ""
  puts "Install n"
  `npm install n -g --silent`
end

puts "Installing the latest stable node"
`n stable`

puts "Running Node version: #{`node --version`}"

puts "Now we'll install the listed modules"
npms = {
  # module name => module command
  # leave command blank if they are the same
  "serve" => "",
  "distra" => "",
  "gh" => "",
  "pulldown" => "",
  "coffee-script" => "coffee",
  "grunt-cli" => "grunt",
  "express" => "",
  "nodemon" => "",
  "mocha" => ""
}

npms.each do |mod, command|
  cmd = (command == "" ? mod : command)
  if `which #{cmd}` == ""
    puts "Installing #{mod}"
    `npm install #{mod} -g --silent`
  else
    puts "#{mod} is installed"
  end
end
