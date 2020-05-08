DIR="${HOME}/dotfiles"

.PHONY: tmux neovim alacritty fish git ag

all:
	@echo "Run things individually!"

vim:
	@ln -nsf $(DIR)/vim/vim ~/.vim
	@ln -sf $(DIR)/vim/vimrc ~/.vimrc
	@ln -sf $(DIR)/vim/gitvimrc ~/.gitvimrc
	@ln -nsf $(DIR)/vim/plugin ~/.vim/plugin

neovim:
	@ln -nsf $(DIR)/nvim ~/.config/nvim

alacritty:
	@ln -nsf $(DIR)/alacritty ~/.config/alacritty

fish:
	@ln -nsf $(DIR)/fish ~/.config/fish

tmux:
	@ln -sf $(DIR)/tmux/tmux.conf ~/.tmux.conf
	@ln -sf $(DIR)/tmux/tmux-osx.conf ~/.tmux-osx.conf

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
