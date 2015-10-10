DIR=/Users/jackfranklin/dotfiles

all: symlinks brew ruby_env gems node
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
	@ln -sf $(DIR)/bin ~/.bin
	@ln -nsf $(DIR)/bundle ~/.bundle

ruby_env:
	ruby $(DIR)/scripts/ruby_env.rb

gems:
	ruby $(DIR)/scripts/gems.rb

install_brews:
	brew tap Homebrew/bundle
	brew bundle

nvm:
	curl https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | sh
	source ~/.nvm/nvm.sh && nvm install 0.12
	source ~/.nvm/nvm.sh && nvm install 4
	source ~/.nvm/nvm.sh && nvm alias default 4

node: nvm
	ruby $(DIR)/scripts/npm_bundles.rb
