DIR=/Users/jackfranklin/dotfiles

all: symlinks ensure_brew brew ruby_env gems node clone_vundle
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
	@ln -nsf $(DIR)/bundle ~/.bundle

ensure_brew:
	ruby $(DIR)/scripts/ensure_homebrew.rb

clone_vundle: symlinks
	git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

ruby_env:
	ruby $(DIR)/scripts/ruby_env.rb

gems:
	ruby $(DIR)/scripts/gems.rb

brew: ensure_brew
	ruby $(DIR)/scripts/install_brews.rb

nvm:
	curl https://raw.githubusercontent.com/creationix/nvm/v0.8.0/install.sh | sh
	source ~/.nvm/nvm.sh && nvm install 0.10
	source ~/.nvm/nvm.sh && nvm install 0.8
	source ~/.nvm/nvm.sh && nvm alias default 0.10

node: nvm
	ruby $(DIR)/scripts/npm_bundles.rb

neovim: brew
	brew tap neovim/homebrew-neovim
	brew install --HEAD neovim
	pip install neovim

