require "mina/extras"

set_default :sudoer, "root"
task :sudo do
  set :user, sudoer
  set :sudo, true
  set :term_mode, :system
end

task :setup => :environment  do
  invoke :create_extra_paths
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
  invoke :upload
end

# namespace :env do
task :sudoer_setup do
  invoke :sudo
  invoke :'unicorn:link'
  invoke :'nginx:link'
  invoke :'nginx:restart'
end

desc 'Create extra paths for shared configs, pids, sockets, etc.'
task :create_extra_paths do
  extra_echo("Create shared paths")
  
  shared_dirs = create_paths.map { |file| File.join("#{deploy_to}/#{shared_path}/", file) }.uniq  
  cmds = shared_dirs.map do |dir|
    queue echo_cmd %{mkdir -p "#{dir}"}
  end
  
  queue "touch #{deploy_to}/#{shared_path}/pids/unicorn.pid"
end

task :upload do
  Dir[File.join(Dir.pwd, "config", "deploy", "#{server}", "*")].map do |file|
    filename = File.basename(file)
    des = "#{deploy_to}/shared/config/#{filename.gsub(/\.erb$/, "")}"
    
    if file =~ /erb$/
      upload_template filename, file, des
    else
      upload_file filename, file, des
    end
  end  
end
