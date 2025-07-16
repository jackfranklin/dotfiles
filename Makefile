DIR="${HOME}/dotfiles"

NEOVIM_GIT_DIR="${HOME}/git/neovim"

all:
	@echo "Run things individually!"

neovim:
	@ln -nsf $(DIR)/nvim ~/.config/nvim

fish:
	@ln -nsf $(DIR)/fish ~/.config/fish

git:
	@ln -sf $(DIR)/git/gitconfig ~/.gitconfig
	@ln -sf $(DIR)/git/gitignore_global ~/.gitignore_global

bin:
	@ln -sf $(DIR)/bin ~/.bin

ubuntu-deps:
	sudo apt-get install silversearcher-ag fish build-essential tmux ripgrep zip

fisher:
	curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher

language_servers_global:
	npm install --global typescript typescript-language-server svelte-language-server diagnostic-languageserver eslint_d vscode-langservers-extracted @johnnymorganz/stylua-bin @fsouza/prettierd emmet-ls

elm_language_servers:
	npm install -g elm elm-test elm-format @elm-tooling/elm-language-server

kitty:
	@ln -nsf ${DIR}/kitty ~/.config/kitty

sync_wezterm_windows:
	cp wezterm/wezterm.lua /mnt/c/Users/jack/.wezterm.lua
	mkdir -p /mnt/c/Users/jack/.wezterm/
	@test -f wezterm/per_machine.lua && cp wezterm/per_machine.lua /mnt/c/Users/jack/.wezterm/per_machine.lua

symlink_windows_linux:
	@ln -nsf $(DIR)/wezterm ~/.config/wezterm

lua_specs:
	cd nvim/lua/jack && busted "alternate-files_spec.lua"

npm_globals:
	# https://github.com/paulirish/git-recent
	npm install --global git-recent
