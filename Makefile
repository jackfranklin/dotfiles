DIR=/Users/jackfranklin/dotfiles

all: symlinks ensure_brew brew ruby_env gems node
	@echo "Reminder: Vim plugins are managed within Vim with Vundle."

symlinks:
	@ln -nsf $(DIR)/zsh/zsh ~/.zsh
	@ln -sf $(DIR)/zsh/zshenv ~/.zshenv
	@ln -sf $(DIR)/zsh/zshrc ~/.zshrc
	@ln -nsf $(DIR)/vim/vim ~/.vim
	@ln -sf $(DIR)/vim/vimrc ~/.vimrc
	@ln -nsf $(DIR)/vim/plugin ~/.vim/plugin
	@ln -sf $(DIR)/tmux/tmux.conf ~/.tmux.conf
	@ln -sf $(DIR)/git/gitconfig ~/.gitconfig
	@ln -sf $(DIR)/git/gitignore_global ~/.gitignore_global
	@ln -sf $(DIR)/ctags/ctags ~/.ctags
	@ln -sf $(DIR)/gem/gemrc ~/.gemrc
	@ln -sf $(DIR)/task/taskrc ~/.taskrc

ensure_brew:
	ruby $(DIR)/scripts/ensure_homebrew.rb

ruby_env:
	ruby $(DIR)/scripts/ruby_env.rb

gems:
	ruby $(DIR)/scripts/gems.rb

brew: Brewfile
	brew bundle Brewfile

node:
	ruby $(DIR)/scripts/npm_bundles.rb

ycm:
	cd ~/.vim/bundle/YouCompleteMe && ./install.sh
