#!/usr/bin/env ruby
require 'fileutils'
require 'open-uri'

REINSTALL_ALL = ARGV[0] == "new"

# shamelessly stolen and altered from https://github.com/tsaleh/dotfiles/blob/master/vim/update_bundles
git_bundles = %w{
  git@github.com:sheerun/vim-polyglot.git
  git://github.com/tpope/vim-endwise.git
  git://github.com/tpope/vim-git.git
  git://github.com/tpope/vim-rails.git
  git://github.com/tpope/vim-surround.git
  git://github.com/tomtom/tcomment_vim.git
  git@github.com:Lokaltog/vim-easymotion.git
  git@github.com:kien/ctrlp.vim.git
  git://github.com/altercation/vim-colors-solarized.git
  git@github.com:SirVer/ultisnips.git
  git://github.com/scrooloose/nerdtree.git
  git://github.com/kana/vim-textobj-user.git
  git://github.com/nelstrom/vim-textobj-rubyblock.git
  git://github.com/christoomey/vim-tmux-navigator.git
  git://github.com/tpope/vim-rbenv.git
  git://github.com/bling/vim-airline.git
  git://github.com/tpope/vim-eunuch.git
  git@github.com:thoughtbot/vim-rspec.git
  git://github.com/majutsushi/tagbar
  git@github.com:michaeljsmith/vim-indent-object.git
  git@github.com:junegunn/vim-easy-align.git
  git@github.com:Valloric/YouCompleteMe.git
  git@github.com:marijnh/tern_for_vim.git
  git@github.com:editorconfig/editorconfig-vim.git
  git@github.com:Yggdroot/indentLine.git
  git@github.com:mileszs/ack.vim.git
  git@github.com:osyo-manga/vim-over.git
  git@github.com:elixir-lang/vim-elixir.git
}

after_instructions = {
  "YouCompleteMe" => "cd ~/.vim/bundle/YouCompleteMe && ./install.sh",
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
      `git clone -q #{url}`
  else
    folder_exists = File.directory? name
    if folder_exists
      puts "Plugin #{name} already installed"
    else
      puts "Installing #{name} as it doesn't exist"
      `git clone -q #{url}`
      unless after_instructions[name].nil?
        puts "Running after_instructions for #{name}"
        puts `#{after_instructions[name]}`
      end
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

