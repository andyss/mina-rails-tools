require "mina/extras"

set_default :sudoer, "root"
task :sudo do
  set :user, sudoer
  set :sudo, true
  set :term_mode, :system
end

task :setup => :environment  do
  invoke :"extra:create_shared_paths"  
  invoke :"extra:upload"
  
  # invoke :create_extra_paths
  # invoke :'dbconfig:upload'
  # invoke :'unicorn:upload'
  # invoke :'god:setup'
  # invoke :'god:upload'
  # invoke :'unicorn:upload'
  # invoke :'nginx:upload'      
  # if sudoer?
  #   queue %{echo "-----> (!!!) You now need to run 'mina sudoer_setup' to run the parts that require sudoer user (!!!)"}
  # else
  #   invoke :sudoer_setup
  # end
end

# namespace :env do
task :sudoer_setup do
  invoke :sudo
  invoke :'unicorn:link'
  invoke :'nginx:link'
  invoke :'nginx:restart'
end

# desc 'Create extra paths for shared configs, pids, sockets, etc.'
# task :create_extra_paths do
#   extra_echo("Create shared paths")
#   
#   shared_dirs = create_paths.map { |file| File.join("#{deploy_to}/#{shared_path}/", file) }.uniq  
#   cmds = shared_dirs.map do |dir|
#     queue echo_cmd %{mkdir -p "#{dir}"}
#   end
#   
#   queue "touch #{deploy_to}/#{shared_path}/pids/unicorn.pid"
# end

namespace :extra do
  
  task :create_shared_paths do
    folders = shared_paths.map do |path|
      path.gsub(/\/\S+\.\S+\Z/, "")
    end.uniq
    
    folders.map do |dir|
      queue echo_cmd %{mkdir -p "#{deploy_to}/shared/#{dir}"}
    end
  end
  
  task :upload do
    base = File.join(Dir.pwd, "config", "deploy", "#{server}")
    
    Dir[File.join(base, "*")].map do |path|
      # File.directory?
      next if File.file?(path)

      upload_shared_folder(path, base)        
    end
  end
end