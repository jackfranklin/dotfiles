#!/usr/bin/env ruby
require 'fileutils'
require 'open-uri'

REINSTALL_ALL = ARGV[0] == "new"

# shamelessly stolen and altered from https://github.com/tsaleh/dotfiles/blob/master/vim/update_bundles
git_bundles = %w{
  git://github.com/kchmck/vim-coffee-script.git
  git://github.com/pangloss/vim-javascript.git
  git://github.com/tpope/vim-endwise.git
  git://github.com/tpope/vim-git.git
  git://github.com/tpope/vim-markdown.git
  git://github.com/tpope/vim-rails.git
  git://github.com/tpope/vim-surround.git
  git://github.com/tomtom/tcomment_vim.git
  git://github.com/ervandew/supertab.git
  git@github.com:Lokaltog/vim-easymotion.git
  git@github.com:tpope/vim-abolish.git
  git@github.com:tpope/vim-repeat.git
  git@github.com:duff/vim-scratch.git
  git@github.com:kien/ctrlp.vim.git
  git://github.com/altercation/vim-colors-solarized.git
  git@github.com:nono/vim-handlebars.git
}

bundles_dir = File.join(File.expand_path("~/dotfiles/vim/.vim"), "bundle")

if REINSTALL_ALL
  puts "Reinstalling all Vim plugins"
  FileUtils.rm_rf(bundles_dir)
  FileUtils.mkdir(bundles_dir)
end

FileUtils.cd(bundles_dir)

git_bundles.each do |url|
  name = url.split("/").last.gsub(".git", "")
  if REINSTALL_ALL
      puts "Installing #{name}"
      `git clone -q #{url}`
  else
    puts "Checking for #{name} #{url}"
    folder_exists = File.directory? name
    if folder_exists
      puts "Plugin already installed"
    else
      puts "Installing #{name} as it doesn't exist"
      `git clone -q #{url}`
    end
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

