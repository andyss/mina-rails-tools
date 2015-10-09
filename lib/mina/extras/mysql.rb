set_default :mysql_user, :root
set_default :mysql_pass, true

namespace :mysql do
  
  desc "Connect to mysql"
  task :connect do
    extra_echo "Mysql: connect"
    queue "mysql -u #{mysql_user} #{mysql_pass ? "-p" : ""}"
  end
    
end