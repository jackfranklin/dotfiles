.PHONY: all neovim fish tmux tmux_deps tmux_latest git bin claude claude-mcp pi pi_deps pi_specs kitty amp hunk agent-runner

DIR="${HOME}/dotfiles"

NEOVIM_GIT_DIR="${HOME}/git/neovim"
TMUX_VERSION ?= 3.7b

all:
	@echo "Run things individually!"

neovim:
	@ln -nsf $(DIR)/nvim ~/.config/nvim

fish:
	@ln -nsf $(DIR)/fish ~/.config/fish

tmux:
	@ln -sf $(DIR)/tmux/tmux.conf ~/.tmux.conf
	@ln -sf $(DIR)/tmux/tmux.base.conf ~/.tmux.base.conf

tmux_deps:
	sudo apt-get install -y build-essential pkg-config libevent-dev ncurses-dev bison

tmux_latest: tmux_deps
	@set -eu; \
	build_dir="$$(mktemp -d)"; \
	trap 'rm -rf "$$build_dir"' EXIT; \
	curl -fsSL -o "$$build_dir/tmux.tar.gz" "https://github.com/tmux/tmux/releases/download/$(TMUX_VERSION)/tmux-$(TMUX_VERSION).tar.gz"; \
	tar -xzf "$$build_dir/tmux.tar.gz" -C "$$build_dir"; \
	cd "$$build_dir/tmux-$(TMUX_VERSION)"; \
	./configure --prefix="$$HOME/.local"; \
	make -j"$$(nproc)"; \
	make install; \
	"$$HOME/.local/bin/tmux" -V; \
	echo 'Installed tmux. Restart the server with: tmux kill-server && tmux'


git:
	@ln -sf $(DIR)/git/gitconfig ~/.gitconfig
	@ln -sf $(DIR)/git/gitignore_global ~/.gitignore_global

bin:
	@ln -sf $(DIR)/bin ~/.bin

agent-runner:
	@ln -nsf $(DIR)/agent-runner/bin/agent-run ~/.local/bin/agent-run

ubuntu-deps:
	sudo apt-get install silversearcher-ag fish build-essential tmux ripgrep zip
	sudo apt install clang libclang-dev

ubuntu-docker-deps:
	sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
	sudo apt-get update
	sudo apt-get install -y ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $$(. /etc/os-release && echo "$$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo usermod -aG docker $$USER
	@echo "Docker installed. Log out/in (or run 'newgrp docker') for group membership to take effect, then verify with: docker run hello-world"

fisher:
	curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher

language_servers_global:
	./scripts/install-npm-globals.sh

elm_language_servers:
	npm install -g elm elm-test elm-format @elm-tooling/elm-language-server

kitty:
	@ln -nsf ${DIR}/kitty ~/.config/kitty

amp:
	@ln -nsf ${DIR}/amp ~/.config/amp

hunk:
	@mkdir -p ~/.config/hunk
	@ln -sf $(DIR)/hunk/config.toml ~/.config/hunk/config.toml

claude:
	@mkdir -p ~/.claude
	@ln -sf $(DIR)/claude/settings.json ~/.claude/settings.json
	@ln -sf $(DIR)/claude/CLAUDE.md ~/.claude/CLAUDE.md
	@ln -nsf $(DIR)/claude/skills ~/.claude/skills
	@ln -sf $(DIR)/claude/statusline.sh ~/.claude/statusline.sh
	@chmod +x $(DIR)/claude/statusline.sh

claude-mcp:
	@node $(DIR)/scripts/sync-mcp.mjs

pi:
	@mkdir -p ~/.pi/agent
	@ln -sf $(DIR)/pi/settings.json ~/.pi/agent/settings.json
	@ln -sf $(DIR)/pi/keybindings.json ~/.pi/agent/keybindings.json
	@ln -nsf $(DIR)/pi/extensions ~/.pi/agent/extensions
	@ln -sf $(DIR)/pi/permissions.json ~/.pi/agent/permissions.json

pi_deps:
	cd $(DIR)/pi/extensions/web-fetch && npm install --omit=dev

sync_wezterm_windows:
	cp wezterm/wezterm.lua /mnt/c/Users/jack/.wezterm.lua
	@mkdir -p /mnt/c/Users/jack/.wezterm/
	@test -f wezterm/per_machine.lua && cp wezterm/per_machine.lua /mnt/c/Users/jack/.wezterm/per_machine.lua

symlink_windows_linux:
	@ln -nsf $(DIR)/wezterm ~/.config/wezterm

lua_specs:
	cd nvim/lua/jack && busted "alternate-files_spec.lua"

pi_specs:
	cd pi/extensions/permissions && node --test

npm_globals:
	./scripts/install-npm-globals.sh

neovim_deps:
	cargo install --locked tree-sitter-cli
