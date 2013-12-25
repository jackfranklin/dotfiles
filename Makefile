DIR=/Users/jackfranklin/dotfiles

all: symlinks ruby_env ruby_gems brew node vim

update: brew node vim

symlinks:
	ln -nsf $(DIR)/zsh/zsh ~/.zsh
	ln -sf $(DIR)/zsh/zshenv ~/.zshenv
	ln -sf $(DIR)/zsh/zshrc ~/.zshrc
	ln -nsf $(DIR)/vim/vim ~/.vim
	ln -sf $(DIR)/vim/vimrc ~/.vimrc
	ln -nsf $(DIR)/vim/plugin ~/.vim/plugin
	ln -sf $(DIR)/tmux/tmux.conf ~/.tmux.conf
	ln -sf $(DIR)/git/gitconfig ~/.gitconfig
	ln -sf $(DIR)/git/gitignore_global ~/.gitignore_global
	ln -sf $(DIR)/ack/ackrc ~/.ackrc
	ln -sf $(DIR)/ctags/ctags ~/.ctags

ruby_env:
	ruby $(DIR)/scripts/ruby_env.rb

ruby_gems:
	ruby $(DIR)/scripts/gems.rb

brew: brews.txt
	brew update
	ruby $(DIR)/scripts/brewery.rb

node:
	ruby $(DIR)/scripts/npm_bundles.rb

vim: vim_plugins.json
	ruby $(DIR)/scripts/vim_bundles.rb
