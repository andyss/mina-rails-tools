require "mina/extras"

set_default :nginx_conf_path, "/etc/nginx/sites-enabled"
set_default :nginx_port, 80
set_default :nginx_default, false

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
    
    queue echo_cmd %{sudo ln -fs "#{deploy_to}/shared/nginx.conf" "#{nginx_conf_path}/#{app!}.conf"}
    # queue check_symlink nginx_conf_path
  end
    
  desc "Current nginx config"
  task :config do
    invoke :sudo
    
    queue_echo("#"*80)
    queue_echo("# File: #{nginx_conf_path}/#{app!}.conf")
    queue %{sudo cat "#{nginx_conf_path}/#{app!}.conf"}
    queue_echo("#"*80)
  end
  
  %w(stop start restart reload status).each do |action|
    desc "#{action.capitalize} Nginx"
    task action.to_sym do
      invoke :sudo
      extra_echo("Nginx: #{action.capitalize}")
      queue echo_cmd "sudo service nginx #{action}"
    end
  end
end
