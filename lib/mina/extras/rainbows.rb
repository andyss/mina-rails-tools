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
    command %{sudo chown root:root /etc/init.d/rainbows-#{fetch(:app)}}
    command %{sudo chmod u+x /etc/init.d/rainbows-#{fetch(:app)}}
    command "sudo update-rc.d rainbows-#{fetch(:app)} defaults"
  end
  
  task :log do
    command %{tail -f "#{deploy_to!}/#{shared_path}/log/rainbows.log" -n 200}    
  end
  
  task :err_log do
    command %{tail -f "#{deploy_to!}/#{shared_path}/log/rainbows.error.log" -n 200}    
  end

  desc "Rainbows: Link script files"
  task :link do
    invoke :sudo
    extra_echo("Rainbows: Link script file")
    command %{sudo cp '#{deploy_to}/shared/config/rainbows_init.sh' '/etc/init.d/rainbows-#{fetch(:app)}'}
    
    invoke :"rainbows:defaults"
  end

  desc "Start rainbows"
  task :start do
    extra_echo("Rainbows: Start")
    command "/etc/init.d/rainbows-#{fetch(:app)} start"
  end

  desc "Stop rainbows"
  task :stop do
    extra_echo("Rainbows: Stop")
    command "/etc/init.d/rainbows-#{fetch(:app)} stop"
  end

  desc "Restart rainbows using 'upgrade'"
  task :restart do
    extra_echo("Rainbows: Restart")
    command "/etc/init.d/rainbows-#{fetch(:app)} upgrade"
  end

end
