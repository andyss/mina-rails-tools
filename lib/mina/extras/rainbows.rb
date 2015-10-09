require "mina/extras"

namespace :rainbows do
  
  desc "Rainbows: Parses config file and uploads it to server"
  task :upload => [:'upload:config', :'upload:script']
  
  namespace :upload do
    desc "Parses Rainbows config file and uploads it to server"
    task :config do
      upload_shared_file("rainbows.rb")
    end
  
    desc "Parses Rainbows control script file and uploads it to server"
    task :script do
      upload_shared_file("rainbows_init.sh")
    end
  end
  
  desc "Unicron: startup"
  task :defaults do
    invoke :sudo
    queue echo_cmd %{sudo chown root:root /etc/init.d/rainbows-#{app!}}
    queue echo_cmd %{sudo chmod u+x /etc/init.d/rainbows-#{app!}}
    queue echo_cmd "sudo update-rc.d rainbows-#{app!} defaults"
  end
  
  task :log do
    queue %{tail -f "#{deploy_to!}/#{shared_path}/log/rainbows.log" -n 200}    
  end
  
  task :err_log do
    queue %{tail -f "#{deploy_to!}/#{shared_path}/log/rainbows.error.log" -n 200}    
  end

  desc "Rainbows: Link script files"
  task :link do
    invoke :sudo
    extra_echo("Rainbows: Link script file")
    queue echo_cmd %{sudo cp '#{deploy_to}/shared/config/rainbows_init.sh' '/etc/init.d/rainbows-#{app!}'}
    
    invoke :"rainbows:defaults"
  end

  desc "Start rainbows"
  task :start do
    extra_echo("Rainbows: Start")
    queue echo_cmd "/etc/init.d/rainbows-#{app!} start"
  end

  desc "Stop rainbows"
  task :stop do
    extra_echo("Rainbows: Stop")
    queue echo_cmd "/etc/init.d/rainbows-#{app!} stop"
  end

  desc "Restart rainbows using 'upgrade'"
  task :restart do
    extra_echo("Rainbows: Restart")
    queue echo_cmd "/etc/init.d/rainbows-#{app!} upgrade"
  end

end