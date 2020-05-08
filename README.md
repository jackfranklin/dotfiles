# Jack's Dotfiles

My dotfiles for Vim, ZSH, Fish (which I'm trying!) and many other things. Mostly taken from endless googling and reading of other people's dotfiles.

Note that these aren't designed to be droppable onto your machine - lots of stuff is specific to me :)

Files are symlinked into the proper location, and have the `.` added. For example:

```
~/dotfiles/vim/vim => ~/.vim
~/dotfiles/vim/vimrc => ~/.vimrc
~/dotfiles/zsh/zshrc => ~/.zshrc
~/dotfiles/git/gitignore_global => ~/.gitignore_global
...and so on
```

# New Mac machine setup steps

- Download Chrome
- Download 1Password and login
- Generate SSH key and set it up on GitHub
- Download iTerm 2
- Clone this repo into `~/dotfiles`
- Setup Vim
  - `make vim`
  - Install Vim plug (https://github.com/junegunn/vim-plug)
  - Run Vim + plug install
- Install [asdf](https://asdf-vm.com/#/)
  - install `asdf-nodejs`
- Change the default shell to Fish
- `cd fish && make symlink`
- Download VSCode
  - setup Settings Sync (1Password has the token + gist link)
- `npm adduser` to login to npm
- Generate a new token for Github and use that to authenticate with `hub`


# Setting up the ergodox keyboards

- Latest ergodox layout: https://configure.ergodox-ez.com/ergodox-ez/layouts/DZgxP/latest/1

# Linux notes

Sorting out trackpad: https://cravencode.com/post/essentials/enable-tap-to-click-in-i3wm/

`sudo touch /etc/X11/xorg.conf.d/90-touchpad.conf`

And file contains:

```
Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
	Option "NaturalScrolling" "on"
	Option "TappingButtonMap" "lrm"
EndSection

```



