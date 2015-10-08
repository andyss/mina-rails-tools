# task :setup do
#   invoke :create_extra_paths
#   # invoke :'god:setup'
#   # invoke :'god:upload'
#   # invoke :'unicorn:upload'
#   # invoke :'nginx:upload'
# 
#   # if sudoer?
#     queue %{echo "-----> (!!!) You now need to run 'mina sudoer_setup' to run the parts that require sudoer user (!!!)"}
#   # else
#     # invoke :sudoer_setup
#   # end
# end
desc "Production Log"
task :log => :environment do
  queue echo_cmd("cd #{deploy_to}/current && tail -f log/production.log -n 200")
end

desc "Rails Console"
task :console => :environment do
  queue echo_cmd("cd #{deploy_to}/current && RAILS_ENV=production bundle exec rails c")
end

task :setup => :environment  do
  invoke :create_extra_paths
  # invoke :'dbconfig:upload'
  # invoke :'unicorn:upload'
  invoke :upload
end

task :sudo do
  set :sudo, true
  set :term_mode, :system # :pretty doesn't seem to work with sudo well
end

set_default :admin, "root"

task :admin do
  set :user, admin
end

# namespace :env do
task :sudoer_setup do
  invoke :sudo
  invoke :admin
  invoke :'unicorn:link'
  invoke :'nginx:link'
  invoke :'nginx:restart'
end

desc "Roll backs the lates release"
task :rollback => :environment do
  queue! %[echo "-----> Rolling back to previous release for instance: #{domain}"]

  # remove latest release folder (active release)
  queue %[echo "-----> Deleting active release : "]
  queue %[ls "#{deploy_to}/releases" -Art | sort | tail -n 1]
  queue! %[ls "#{deploy_to}/releases" -Art | sort | tail -n 1 | xargs -I active rm -rf "#{deploy_to}/releases/active"]

  # delete existing sym link and create a new symlink pointing to the previous release
  queue %[echo "-----> Creating new symlink from the previous release: "]
  queue %[ls "#{deploy_to}/releases" -Art | sort | tail -n 1]
  queue! %[rm "#{deploy_to}/current"]
  queue! %[ls -Art "#{deploy_to}/releases" | sort | tail -n 1 | xargs -I active ln -s "#{deploy_to}/releases/active" "#{deploy_to}/current"]
  
  invoke :'unicorn:restart'
end

desc 'Create extra paths for shared configs, pids, sockets, etc.'
task :create_extra_paths do
  queue 'echo "-----> Create shared paths"'
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

task :health do
  queue 'ps aux | grep -v grep | grep -v bash | grep -e "bin\/god" -e "unicorn_rails" -e "mongod" -e "nginx" -e "redis" -e "STAT START   TIME COMMAND" -e "bash"'
end

task :uptime do
  queue 'uptime'
end

# def mv_config(source, destination)
#   queue %{mv #{deploy_to}/shared/config/#{source} #{deploy_to}/shared/config/#{destination}}
# end

def upload_file(desc, source, destination)
  # invoke :sudo
  # contents = File.read(source)
  queue %{echo "-----> Put #{desc} file to #{destination}"}
  
  command = "scp "
  command << source
  command << " #{user}@#{domain!}:#{destination}"
  queue %{echo "-------> #{command}"}
  result = %x[#{command}]
  puts result unless result == ""
  
  queue check_exists(destination)
end

def upload_template(desc, tpl, destination)
  contents = parse_template(tpl)
  queue %{echo "-----> Put #{desc} file to #{destination}"}
  queue %{echo "#{contents}" > #{destination}}
  queue check_exists(destination)
end

def parse_template(file)
  erb(file).gsub('"','\\"').gsub('`','\\\\`').gsub('$','\\\\$')
end

def check_response
  'then echo "----->   SUCCESS"; else echo "----->   FAILED"; fi'
end

def check_exists(destination)
  %{if [[ -s "#{destination}" ]]; #{check_response}}
end

def check_ownership(u, g, destination)
  %{
    file_info=(`ls -l #{destination}`)
    if [[ -s "#{destination}" ]] && [[ ${file_info[2]} == '#{u}' ]] && [[ ${file_info[3]} == '#{g}' ]]; #{check_response}
    }
end

def check_exec_and_ownership(u, g, destination)
  %{
    file_info=(`ls -l #{destination}`)
    if [[ -s "#{destination}" ]] && [[ -x "#{destination}" ]] && [[ ${file_info[2]} == '#{u}' ]] && [[ ${file_info[3]} == '#{g}' ]]; #{check_response}
    }
end

def check_symlink(destination)
  %{if [[ -h "#{destination}" ]]; #{check_response}}
end

# Allow to run some tasks as different (sudoer) user when sudo required
module Mina
  module Helpers
    def ssh_command
      args = domain!
      args = if sudo? && sudoer?
               "#{sudoer}@#{args}"
             elsif user?
               "#{user}@#{args}"
             end
      args << " -i #{identity_file}" if identity_file?
      args << " -p #{port}" if port?
      args << " -t"
      "ssh #{args}"
    end
  end
end
