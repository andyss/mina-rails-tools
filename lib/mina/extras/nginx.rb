###########################################################################
# nginx Tasks
###########################################################################

set :nginx_available,    "/etc/nginx/sites-available"
set :nginx_enabled,  "/etc/nginx/sites-enabled"

namespace :nginx do
  # desc "Create configuration and other files"
  # task :setup do
  #   invoke :sudo
  #   queue echo_cmd "mkdir -p #{nginx_log_path}"
  #   queue echo_cmd "sudo chown #{nginx_user}:#{nginx_group} #{nginx_log_path}"
  # end
  
  desc "Upload and update (link) all nginx config file"
  task :update => [:upload, :link]
  
  desc "Symlink config file"
  task :link do
    invoke :sudo
    queue %{echo "-----> Symlink nginx config file"}
    queue echo_cmd %{sudo ln -fs "#{deploy_to}/shared/config/nginx.conf" "#{nginx_available}/#{app!}.conf"}
    # queue check_symlink nginx_available
    queue echo_cmd %{sudo ln -fs "#{deploy_to}/shared/config/nginx.conf" "#{nginx_enabled}/#{app!}.conf"}
    # queue check_symlink nginx_enabled
  end

  # desc "Parses nginx config file and uploads it to server"
  # task :upload do
  #   upload_template 'nginx config', 'nginx.conf', "#{config_path}/nginx.conf"
  # end
  
  # desc "Parses config file and outputs it to STDOUT (local task)"
  # task :parse do
  #   puts "#"*80
  #   puts "# nginx.conf"
  #   puts "#"*80
  #   puts erb("#{config_templates_path}/nginx.conf.erb")
  # end
  # 
  %w(stop start restart reload status).each do |action|
    desc "#{action.capitalize} Nginx"
    task action.to_sym do
      invoke :admin
      queue %{echo "-----> #{action.capitalize} Nginx"}
      queue echo_cmd "sudo service nginx #{action}"
    end
  end
end
