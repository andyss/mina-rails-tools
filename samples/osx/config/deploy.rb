$: << File.join(Dir.pwd, "../../lib")

require "mina/extras"
require "mina/extras/osx"
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
  invoke :"osx:before_check"
  invoke :"osx:remote:setup"
  invoke :"osx:locale:setup"
  invoke :"osx:install:prepare"
  
  mina_cleanup!
  clean_commands!
  
  invoke :user
  command "whoami"
  invoke :"brew:install:mysql"
  invoke :"brew:install:redis"
  invoke :"brew:install:nginx"
  invoke :"gem:source:prepare"
  invoke :"gem:source:list"
  invoke :"gem:install:mina"
  invoke :"gem:install:rails"
  invoke :"gem:install:mysql2"
  invoke :"gem:install:unicorn"
  invoke :"brew:get:imagemagick"
  invoke :"brew:install:rmagick"
  invoke :"osx:install:www"
  invoke :"gem:install:god"
  invoke :"god:setup"
  invoke :"god:upload"
  invoke :"god:link"
end