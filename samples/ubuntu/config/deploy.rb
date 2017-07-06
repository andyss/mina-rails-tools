$: << File.join(Dir.pwd, "../../lib")

require "mina/extras"
require "mina/extras/ubuntu"
require "mina/extras/god"

set :user, 'ubuntu'
set :sudoer, "root"

set :domain, '192.168.11.107'

set :in_china, true

set :ssh_pub_key_path, "/Users/joey/.ssh/id_rsa.pub"
set :ssh_key_path, "/Users/joey/.ssh/id_rsa"

task :start do
  invoke :sudo
  command "whoami"
  invoke :"ubuntu:before_check"
  invoke :"ubuntu:remote:setup"
  invoke :"ubuntu:locale:setup"
  invoke :"ubuntu:remote:add_ubuntu"
  invoke :"ubuntu:remote:add_deploy"
  invoke :"ubuntu:install:prepare"
  mina_cleanup!
  
  clean_commands!
  
  invoke :user
  command "whoami"
  invoke :"apt:get:mysql"
  invoke :"apt:get:redis"
  invoke :"apt:get:nginx"
  invoke :"apt:get:libmysqlclient-dev"
  invoke :"apt:get:libssl-dev" 
  invoke :"apt:get:libreadline-dev"
  invoke :"gem:source:prepare"
  invoke :"gem:source:list"
  invoke :"gem:install:rails"
  invoke :"gem:install:mysql2"
  invoke :"gem:install:unicorn"
  invoke :"apt:get:imagemagick"
  invoke :"apt:get:libmagickwand-dev"
  invoke :"gem:install:rmagick"
  invoke :"ubuntu:install:www"
  invoke :"gem:install:god"
  invoke :"god:setup"
  invoke :"god:upload"
  invoke :"god:link"
end