#!/usr/bin/env ruby
require 'fileutils'
require 'open-uri'

REINSTALL_ALL = ARGV[0] == "new"
plugin_to_update = nil
unless REINSTALL_ALL
  plugin_to_update = ARGV[0]
end

# shamelessly stolen and altered from https://github.com/tsaleh/dotfiles/blob/master/vim/update_bundles
git_bundles = File.readlines("vim_plugins.txt").map(&:chomp)

after_instructions = {
  "YouCompleteMe" => "cd ~/.vim/bundle/YouCompleteMe && git submodule update --init --recursive && ./install.sh",
  "tern_for_vim" => "cd ~/.vim/bundle/tern_for_vim && npm install"
}

bundles_dir = File.join(File.expand_path("~/dotfiles/vim/vim"), "bundle")

if REINSTALL_ALL
  puts "Reinstalling all Vim plugins"
  FileUtils.rm_rf(bundles_dir)
end

# make sure the folder exists before writing
FileUtils.mkdir_p(bundles_dir)

FileUtils.cd(bundles_dir)

git_bundles.each do |url|
  name = url.split("/").last.gsub(".git", "")
  if REINSTALL_ALL
    puts "Installing #{name}"
    clone_and_install(url)
  elsif !plugin_to_update.nil? && name.include?(plugin_to_update)
    puts "Going to redownload #{name}"
    FileUtils.rm_rf(name)
    clone_and_install(url)
  else
    folder_exists = File.directory? name
    unless folder_exists
      puts "Installing #{name} as it doesn't exist"
      clone_and_install(url)
    end
  end
end

def clone_and_install(url)
  name = url.split("/").last.gsub(".git", "")
  `git clone -q #{url}`
  unless after_instructions[name].nil?
    puts "Running after_instructions for #{name}"
    puts `#{after_instructions[name]}`
  end
end

Dir["*/.git"].each {|f| FileUtils.rm_rf(f) }

# check if any folders exist not in the list of bundles, and remove them
bundle_names = git_bundles.map { |item|
  item.split("/").last.gsub(".git", "")
}

folder_names = Dir.glob(File.expand_path("~/.vim/bundle/*")).map { |item|
  item.split("/").last
}

to_uninstall = folder_names.select { |folder| !bundle_names.include?(folder) }
to_uninstall.each do |folder|
  puts "Uninstalling plugin: #{folder}"
  FileUtils.rm_rf(File.expand_path("~/.vim/bundle/#{folder}"))
end

