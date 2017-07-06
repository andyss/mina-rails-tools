require "mina/extras"

set :nginx_conf_path, "/etc/nginx/sites-enabled"
set :nginx_port, 80
set :nginx_default, false

namespace :nginx do
    
  # desc "Nginx: Setup config files"
  # task :setup => [:upload, :link]
  
  desc "Nginx: Parses config file and uploads it to server"
  task :upload do
    upload_shared_file("nginx.conf")
  end
  
  desc "Nginx: Symlink config file"
  task :link do
    invoke :sudo
    extra_echo("Nginx: Symlink config file")
    
    command %{sudo ln -fs "#{deploy_to}/shared/nginx.conf" "#{nginx_conf_path}/#{fetch(:app)}.conf"}
    # command check_symlink nginx_conf_path
  end
    
  desc "Current nginx config"
  task :config do
    invoke :sudo
    
    command_echo("#"*80)
    command_echo("# File: #{nginx_conf_path}/#{fetch(:app)}.conf")
    command %{sudo cat "#{nginx_conf_path}/#{fetch(:app)}.conf"}
    command_echo("#"*80)
  end
  
  %w(stop start restart reload status).each do |action|
    desc "#{action.capitalize} Nginx"
    task action.to_sym do
      invoke :sudo
      extra_echo("Nginx: #{action.capitalize}")
      command "sudo service nginx #{action}"
    end
  end
end
