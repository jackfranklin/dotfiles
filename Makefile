DIR="${HOME}/dotfiles"

.PHONY: tmux neovim alacritty fish git ag i3 elm-language-server

all:
	@echo "Run things individually!"

neovim:
	@ln -nsf $(DIR)/nvim ~/.config/nvim
	@echo "Don't forget to install vim-plug then do :PlugInstall"
	@echo "https://github.com/junegunn/vim-plug#neovim"


alacritty:
	@ln -nsf $(DIR)/alacritty ~/.config/alacritty

fish:
	@ln -nsf $(DIR)/fish ~/.config/fish

tmux:
	@ln -sf $(DIR)/tmux/tmux.conf ~/.tmux.conf
	@ln -sf $(DIR)/tmux/tmux-osx.conf ~/.tmux-osx.conf

i3:
	@ln -nsf $(DIR)/i3 ~/.config/i3

ag:
	@ln -sf $(DIR)/ag/agignore ~/.agignore

git:
	@ln -sf $(DIR)/git/gitconfig ~/.gitconfig
	@ln -sf $(DIR)/git/gitignore_global ~/.gitignore_global

bin:
	@ln -sf $(DIR)/bin ~/.bin

zsh:
	@ln -nsf $(DIR)/zsh/zsh ~/.zsh
	@ln -sf $(DIR)/zsh/zshenv ~/.zshenv
	@ln -sf $(DIR)/zsh/zshrc ~/.zshrc
	touch ~/dotfiles/zsh/secret

antigen:
	cd ~ && git clone https://github.com/zsh-users/antigen.git

elm-language-server:
	npm install --global elm-tooling@elm-language-server

ubuntu-deps:
	sudo apt-get install neovim silversearcher-ag fish build-essential tmux

fisher:
	curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher

latest_neovim_linux:
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	chmod u+x nvim.appimage
	mv nvim.appimage ~/dotfiles/images
