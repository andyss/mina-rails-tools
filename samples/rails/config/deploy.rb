require "mina/bundler"
require "mina/rails"
require "mina/git"
require "mina/extras"
require "mina/extras/nginx"
require "mina/extras/unicorn"
require "mina/extras/god"

Dir[File.join(Dir.pwd, "config", "deploy", "*.rb")].each { |f| load f }

set :user, 'deploy'
set :group, "www-data"
set :sudoer, "joey"

set :keep_releases, 5
set :domain, '192.168.11.107'
set :deploy_to, "/var/www/test"
set :shared_paths, ["config/database.yml", "tmp", "log", "pids", "config/application.yml"]
set :repository, "git@xxxx:test.git"
# set :branch, "master"

set :app, 'test'

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_create'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    
    to :launch do
      invoke :'unicorn:restart'
    end
    
    invoke :'deploy:cleanup'
  end
end
