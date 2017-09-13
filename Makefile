DIR="${HOME}/dotfiles"

all:
	@echo "Run things individually!"

symlinks:
	@ln -nsf $(DIR)/zsh/zsh ~/.zsh
	@ln -sf $(DIR)/zsh/zshenv ~/.zshenv
	@ln -sf $(DIR)/zsh/zshrc ~/.zshrc
	@ln -nsf $(DIR)/vim/vim ~/.vim
	@ln -sf $(DIR)/vim/vimrc ~/.vimrc
	@ln -sf $(DIR)/hyper.js ~/.hyper.js
	@ln -sf $(DIR)/vim/gitvimrc ~/.gitvimrc
	@ln -nsf $(DIR)/vim/plugin ~/.vim/plugin
	@ln -sf $(DIR)/tmux/tmux.conf ~/.tmux.conf
	@ln -sf $(DIR)/ag/agignore ~/.agignore
	@ln -sf $(DIR)/git/gitconfig ~/.gitconfig
	@ln -sf $(DIR)/git/gitignore_global ~/.gitignore_global
	@ln -sf $(DIR)/ctags/ctags ~/.ctags
	@ln -sf $(DIR)/gem/gemrc ~/.gemrc
	@ln -sf $(DIR)/bin ~/.bin
	@ln -nsf $(DIR)/bundle ~/.bundle
	@ln -sf $(DIR)/rbenv ~/.rbenv
	@ln -sf $(DIR)/npmrc/npmrc ~/.npmrc
	@mkdir -p ~/.config/nvim
	@ln -s ~/.vim ~/.config/nvim
	@ln -s ~/dotfiles/vim/vimrc ~/.config/nvim/init.vim
	@ln -s ~/dotfiles/vim/vim/UltiSnips ~/.config/nvim/UltiSnips
	touch ~/dotfiles/zsh/secret


LATEST_RUBY="2.4.1"
ruby:
	[ -d ~/.rbenv/versions/$(LATEST_RUBY) ] || rbenv install $(LATEST_RUBY)
	rbenv global $(LATEST_RUBY)

install_brews:
	brew tap Homebrew/bundle
	brew tap caskroom/versions
	brew bundle

python_modules:
	pip3 install neovim
	pip3 install neovim-remote

nvm:
	curl https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | sh
	source ~/.nvm/nvm.sh && nvm install 6
	source ~/.nvm/nvm.sh && nvm alias default 6

antigen:
	cd ~ && git clone https://github.com/zsh-users/antigen.git

# See https://github.com/neovim/neovim/issues/2048#issuecomment-78045837 for info
fix_neovim_ctrl_h:
	infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > $TERM.ti
	tic $TERM.ti

install-global-npms:
	npm install --global flow-vim-quickfix yarn elm
