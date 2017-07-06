set :god_path, "/etc/god"
set :god_user, "root"
set :god_group, "root"
set :god_service_path, "/etc/init.d"
set :god_pid_path, "/var/run"
set :god_log_path, "/var/log"

set :use_god, true

namespace :god do

  task :setup do
    command "sudo mkdir -p #{fetch(:god_path)}/conf"
  end

  task :link do
    extra_echo "Relocate god script file"
    command %{sudo rm -rf "#{fetch(:god_service_path)}/god"}
    command "sudo mkdir -p #{fetch(:god_path)}/conf"
    command "sudo chown -R #{user} #{fetch(:god_path)}"
    command %{sudo cp "#{fetch(:god_path)}/god.sh" "#{fetch(:god_service_path)}/god"}
    command %{sudo chown #{god_user}:#{god_group} "#{fetch(:god_service_path)}/god"}
    command %{sudo chmod +x "#{fetch(:god_service_path)}/god"}
    command "sudo chown -R #{god_user}:#{god_group} #{fetch(:god_path)}"
    command "sudo update-rc.d god defaults"
  end

  task :tmp_add_permission do
    command "sudo chown -R #{user} #{fetch(:god_path)}"
  end

  task :set_permission do
    command "sudo chown -R #{god_user}:#{god_group} #{fetch(:god_path)}"
  end

  task :upload => [:'upload:script', :'upload:global']

  namespace :upload do
    task :script do
      command "sudo mkdir -p #{fetch(:god_path)}/conf"
      command "sudo chown -R #{user} #{fetch(:god_path)}"
      upload_file "god.sh", "#{fetch(:god_path)}/god.sh"
      command "sudo chown -R #{god_user}:#{god_group} #{fetch(:god_path)}"
    end

    task :global do
      command "sudo mkdir -p #{fetch(:god_path)}/conf"
      command "sudo chown -R #{user} #{fetch(:god_path)}"
      upload_file 'global.god', "#{fetch(:god_path)}/global.god"
      command "sudo chown -R #{god_user}:#{god_group} #{fetch(:god_path)}"
    end
  end

  %w(stop start restart status).each do |action|
    desc "#{action.capitalize} God"
    task action.to_sym do
      invoke :sudo
      command %{echo "-----> #{action.capitalize} God"}
      command "sudo #{fetch(:god_service_path)}/god #{action}"
    end
  end

  task :log do
    invoke :sudo
    command %{sudo tail -f #{god_log_path}/god.log -n #{ENV["n"] || 200}}
  end
end
