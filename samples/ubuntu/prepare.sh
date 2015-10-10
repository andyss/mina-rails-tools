#!/usr/bin/env bash

sudo apt-get install build-essential libssl-dev libreadline-dev
cd /tmp
wget https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz
tar xf ruby-2.2.3.tar.gz
./configure && make
sudo make install
sudo ln -s /usr/local/bin/ruby /usr/bin/ruby
cd /tmp
wget http://rubygems.org/rubygems/rubygems-2.4.8.tgz
tar xf rubygems-2.4.8.tgz
sudo ruby setup.rb install

sudo gem source -a http://ruby.taobao.org/
sudo gem source -r https://rubygems.org/

sudo gem install mina --no-rdoc --no-ri
sudo gem install mina-rails-tools --no-rdoc --ri





