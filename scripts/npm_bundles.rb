#!/usr/bin/env ruby


puts "Running Node version: #{`node --version`}"
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
  "mocha" => "",
  "gulp" => ""
}

npms.each do |mod, command|
  cmd = (command == "" ? mod : command)
  if `which #{cmd}` == ""
    puts "Installing #{mod}"
    `npm install #{mod} -g --silent`
  end
end

# always run the very latest npm, not just the one that was bundled into Node
`npm install npm -g --silent`
