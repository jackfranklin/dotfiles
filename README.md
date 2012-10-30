#Jack's Dotfiles

My dotfiles for Vim and ZSH. Shamelessly stolen from tonnes of dotfile repositories I found online. 

#Plugins

Plugins are all managed with Pathogen, and added to the update_bundles script in `~/.vim/update_bundles`.

The only exception is Command T, which requires a couple of extra compiliation steps. Once the update bundles script is run, you need to:

```
rbenv local system
cd ~/.vim/bundle/command-t/ruby/command-t
ruby extconf.rb
make
```

That's if you use rbenv, if you use RVM I've no idea, and if you don't use any then you shouldn't need to do anything.



