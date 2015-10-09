#!/usr/bin/env ruby


puts "Running Node version: #{`node --version`}"
npms = {
  # module name => module command
  # leave command blank if they are the same
  "serve" => "",
  "pulldown" => "",
  "express" => "",
  "nodemon" => "",
}

npms.each do |mod, command|
  cmd = (command == "" ? mod : command)
  if `which #{cmd}` == ""
    puts "Installing #{mod}"
    `npm install #{mod} -g --silent`
  end
end
