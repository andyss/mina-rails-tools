#!/usr/bin/env bash

sudo gem source -a http://ruby.taobao.org/
sudo gem source -r https://rubygems.org/

sudo gem install mina --no-rdoc --no-ri
sudo gem install mina-rails-tools --no-rdoc --ri
