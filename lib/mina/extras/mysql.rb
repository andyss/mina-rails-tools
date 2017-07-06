set :mysql_user, :root
set :mysql_pass, true

namespace :mysql do
  
  desc "Connect to mysql"
  task :connect do
    extra_echo "Mysql: connect"
    command "mysql -u #{mysql_user} #{mysql_pass ? "-p" : ""}"
  end
    
end