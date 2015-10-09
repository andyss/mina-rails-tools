require "mina/extras"

namespace :unicorn do
  
  desc "Unicorn: Parses config file and uploads it to server"
  task :upload => [:'upload:config', :'upload:script']
  
  namespace :upload do
    desc "Parses Unicorn config file and uploads it to server"
    task :config do
      upload_shared_file("unicorn.rb")
    end
  
    desc "Parses Unicorn control script file and uploads it to server"
    task :script do
      upload_shared_file("unicorn_init.sh")
    end
  end
  
  desc "Unicron: startup"
  task :defaults do
    invoke :sudo
    queue echo_cmd %{sudo chown root:root /etc/init.d/unicorn-#{app!}}
    queue echo_cmd %{sudo chmod u+x /etc/init.d/unicorn-#{app!}}
    queue echo_cmd "sudo update-rc.d unicorn-#{app!} defaults"
  end
  
  task :god do
    invoke :sudo
    upload_shared_file("unicorn.god")
    invoke :"god:restart"
  end
  
  task :log do
    queue %{tail -f "#{deploy_to!}/#{shared_path}/log/unicorn.log" -n 200}    
  end
  
  task :err_log do
    queue %{tail -f "#{deploy_to!}/#{shared_path}/log/unicorn.error.log" -n 200}    
  end

  desc "Unicorn: Link script files"
  task :link do
    invoke :sudo
    extra_echo("Unicorn: Link script file")
    queue echo_cmd %{sudo cp '#{deploy_to}/shared/config/unicorn_init.sh' '/etc/init.d/unicorn-#{app!}'}
    
    # invoke :"unicorn:defaults"
  end

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
