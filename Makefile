DIR=/Users/jackfranklin/dotfiles

all:
	@echo "Run things individually!"

symlinks:
	@ln -nsf $(DIR)/zsh/zsh ~/.zsh
	@ln -sf $(DIR)/zsh/zshenv ~/.zshenv
	@ln -sf $(DIR)/zsh/zshrc ~/.zshrc
	@ln -nsf $(DIR)/vim/vim ~/.vim
	@ln -sf $(DIR)/vim/vimrc ~/.vimrc
	@mkdir -p ~/.config/nvim
	@ln -nsf $(DIR)/vim/vim ~/.config/nvim
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
	@ln -nsf $(DIR)/npmrc/npmrcs ~/.npmrcs
	@ln -sf $(DIR)/npmrc/npmrc ~/.npmrc


LATEST_RUBY="2.2.3"
ruby:
	[ -d ~/.rbenv/versions/$(LATEST_RUBY) ] || rbenv install $(LATEST_RUBY)
	rbenv global $(LATEST_RUBY)

install_brews:
	brew tap Homebrew/bundle
	brew tap caskroom/versions
	brew bundle

python_modules:
	pip install neovim

nvm:
	curl https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | sh
	source ~/.nvm/nvm.sh && nvm install 6
	source ~/.nvm/nvm.sh && nvm alias default 6

antigen:
	cd ~ && git clone https://github.com/zsh-users/antigen.git

tmux:
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

term_info:
	tic term-config/xterm-256color-italic.terminfo
	tic -x term-config/tmux-256color.terminfo
