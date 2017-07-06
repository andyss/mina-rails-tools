set_default :god_path, "/etc/god"
set_default :god_user, "root"
set_default :god_group, "root"
set_default :god_service_path, "/etc/init.d"
set_default :god_pid_path, "/var/run"
set_default :god_log_path, "/var/log"

set :use_god, true

namespace :god do

  task :setup do
    command echo_cmd "sudo mkdir -p #{god_path}/conf"
  end
  
  task :link do
    extra_echo "Relocate god script file"
    command echo_cmd %{sudo rm -rf "#{god_service_path}/god"}
    command echo_cmd "sudo mkdir -p #{god_path}/conf"
    command echo_cmd "sudo chown -R #{user} #{god_path}"
    command echo_cmd %{sudo cp "#{god_path}/god.sh" "#{god_service_path}/god"}
    command echo_cmd %{sudo chown #{god_user}:#{god_group} "#{god_service_path}/god"}
    command echo_cmd %{sudo chmod +x "#{god_service_path}/god"}
    command echo_cmd "sudo chown -R #{god_user}:#{god_group} #{god_path}"
    command echo_cmd "sudo update-rc.d god defaults"
  end
  
  task :tmp_add_permission do
    command echo_cmd "sudo chown -R #{user} #{god_path}"
  end
  
  task :set_permission do
    command echo_cmd "sudo chown -R #{god_user}:#{god_group} #{god_path}"
  end

  task :upload => [:'upload:script', :'upload:global']
  
  namespace :upload do
    task :script do
      command echo_cmd "sudo mkdir -p #{god_path}/conf"
      command echo_cmd "sudo chown -R #{user} #{god_path}"
      upload_file "god.sh", "#{god_path}/god.sh"
      command echo_cmd "sudo chown -R #{god_user}:#{god_group} #{god_path}"
    end

    task :global do
      command echo_cmd "sudo mkdir -p #{god_path}/conf"
      command echo_cmd "sudo chown -R #{user} #{god_path}"
      upload_file 'global.god', "#{god_path}/global.god"
      command echo_cmd "sudo chown -R #{god_user}:#{god_group} #{god_path}"
    end    
  end
  
  %w(stop start restart status).each do |action|
    desc "#{action.capitalize} God"
    task action.to_sym do
      invoke :sudo
      command %{echo "-----> #{action.capitalize} God"}
      command echo_cmd "sudo #{god_service_path}/god #{action}"
    end
  end
  
  task :log do
    invoke :sudo
    command %{sudo tail -f #{god_log_path}/god.log -n #{ENV["n"] || 200}}
  end
end