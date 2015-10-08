require "mina/extras"

namespace :unicorn do
  
  desc "Unicorn: Link script files"
  task :link do
    invoke :sudo
    extra_echo("Unicorn: Link script file")
    queue echo_cmd %{sudo cp '#{deploy_to}/shared/config/unicorn_init.sh' '/etc/init.d/unicorn-#{app!}'}
    queue echo_cmd %{sudo chown #{deploy_user}:#{deploy_user} /etc/init.d/unicorn-#{app!}}
    queue echo_cmd %{sudo chmod u+x /etc/init.d/unicorn-#{app!}}
  end

  # desc "Parses all Unicorn config files and uploads them to server"
  # task :upload => [:'upload:config', :'upload:script']
  
  # namespace :upload do
  #   desc "Parses Unicorn config file and uploads it to server"
  #   task :config do
  #     upload_file 'Unicorn config', "#{Dir.pwd}/config/servers/#{unicorn_tpl}", "#{deploy_to}/shared/config/unicorn.rb"
  #   end
  # 
  #   desc "Parses Unicorn control script file and uploads it to server"
  #   task :script do
  #     upload_file 'Unicorn control script', "#{Dir.pwd}/config/servers/#{unicorn_init_tpl}", "#{deploy_to}/shared/config/unicorn_init.sh"
  #   end
  # end

  # desc "Parses all Unicorn config files and shows them in output"
  # task :parse => [:'parse:config', :'parse:script']
  # 
  # namespace :parse do
  #   desc "Parses Unicorn config file and shows it in output"
  #   task :config do
  #     puts "#"*80
  #     puts "# unicorn.rb"
  #     puts "#"*80
  #     puts erb("#{config_templates_path}/unicorn.rb.erb")
  #   end
  # 
  #   desc "Parses Unicorn control script file and shows it in output"
  #   task :script do
  #     puts "#"*80
  #     puts "# unicorn.sh"
  #     puts "#"*80
  #     puts erb("#{config_templates_path}/unicorn.sh.erb")
  #   end
  # end

  desc "Start unicorn"
  task :start do
    extra_echo("Unicorn: Start")
    queue echo_cmd "/etc/init.d/unicorn-#{app!} start"
  end

  desc "Stop unicorn"
  task :stop do
    extra_echo("Unicorn: Stop")
    queue echo_cmd "/etc/init.d/unicorn-#{app!} stop"
  end

  desc "Restart unicorn using 'upgrade'"
  task :restart do
    extra_echo("Unicorn: Restart")
    queue echo_cmd "/etc/init.d/unicorn-#{app!} upgrade"
  end

end
