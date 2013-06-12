#!/bin/bash

rbenv install 1.9.3-p429

# silly mountain lion apple and ssl thing
brew install openssl
CONFIGURE_OPTS="--with-openssl-dir=`brew --prefix openssl`" rbenv install 2.0.0-p195

rbenv global 1.9.3-p429

# add some gems
gem install bundler
gem install rake
gem install rails
