DIR="${HOME}/dotfiles"

NEOVIM_GIT_DIR="${HOME}/git/neovim"

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

ubuntu-deps:
	sudo apt-get install silversearcher-ag fish build-essential tmux ripgrep

fisher:
	curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher

language_servers_global:
	npm install --global typescript typescript-language-server svelte-language-server diagnostic-languageserver eslint_d vscode-langservers-extracted @johnnymorganz/stylua-bin

elm_language_servers:
	npm install -g elm elm-test elm-format @elm-tooling/elm-language-server

install_rust_analyzer:
	rustup component add rust-src
	mkdir -p ~/.local/bin
	curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer
	chmod +x ~/.local/bin/rust-analyzer


kitty:
	@ln -nsf ${DIR}/kitty ~/.config/kitty


update_neovim:
	cd ${NEOVIM_GIT_DIR} && git pull
	cd ${NEOVIM_GIT_DIR} && make
	cd ${NEOVIM_GIT_DIR} && make install
