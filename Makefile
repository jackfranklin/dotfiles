DIR="${HOME}/dotfiles"

NEOVIM_GIT_DIR="${HOME}/git/neovim"

all:
	@echo "Run things individually!"

neovim:
	@ln -nsf $(DIR)/nvim ~/.config/nvim

packer:
	git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

fish:
	@ln -nsf $(DIR)/fish ~/.config/fish

git:
	@ln -sf $(DIR)/git/gitconfig ~/.gitconfig
	@ln -sf $(DIR)/git/gitignore_global ~/.gitignore_global

bin:
	@ln -sf $(DIR)/bin ~/.bin

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

sync_alacritty_windows:
	cp alacritty_windows/alacritty.yml /mnt/c/Users/jack/AppData/Roaming/alacritty/
	cp alacritty_windows/theme.yml /mnt/c/Users/jack/AppData/Roaming/alacritty/


update_neovim:
	cd ${NEOVIM_GIT_DIR} && git pull
	cd ${NEOVIM_GIT_DIR} && make
	cd ${NEOVIM_GIT_DIR} && make install
