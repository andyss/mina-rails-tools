require "mina/extras"

set :use_unicorn, true

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
    command "sudo update-rc.d unicorn-#{fetch(:app)} defaults"
  end

  namespace :god do
    task :upload do
      upload_shared_file("unicorn.god")
    end

    task :link do
      invoke :sudo
      command %{sudo cp -rf #{fetch(:deploy_to)}/#{shared_path}/unicorn.god #{god_path}/conf/unicorn-#{fetch(:app)}.god}
      invoke :"god:restart"
    end

    task :start do
      invoke :sudo
      command %{sudo god start unicorn_#{fetch(:app)}}
    end

    task :stop do
      invoke :sudo
      command %{sudo god stop unicorn_#{fetch(:app)}}
    end
  end

  task :log do
    command %{tail -f "#{fetch(:deploy_to)}/#{shared_path}/log/unicorn.log" -n 200}
  end

  task :err_log do
    command %{tail -f "#{fetch(:deploy_to)}/#{shared_path}/log/unicorn.error.log" -n 200}
  end

  desc "Unicorn: Link script files"
  task :link do
    invoke :sudo
    extra_echo("Unicorn: Link script file")
    command %{sudo cp '#{fetch(:deploy_to)}/shared/unicorn_init.sh' '/etc/init.d/unicorn-#{fetch(:app)}'}
    command %{sudo chown #{user!}:#{group!} /etc/init.d/unicorn-#{fetch(:app)}}
    command %{sudo chmod u+x /etc/init.d/unicorn-#{fetch(:app)}}
    # invoke :"unicorn:defaults"
  end

  desc "Start unicorn"
  task :start do
    extra_echo("Unicorn: Start")
    command "/etc/init.d/unicorn-#{fetch(:app)} start"
  end

  desc "Stop unicorn"
  task :stop do
    extra_echo("Unicorn: Stop")
    command "/etc/init.d/unicorn-#{fetch(:app)} stop"
  end

  desc "Restart unicorn using 'upgrade'"
  task :restart do
    extra_echo("Unicorn: Restart")
    command "/etc/init.d/unicorn-#{fetch(:app)} upgrade"
  end

end
