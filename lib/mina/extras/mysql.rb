set_default :mysql_user, :root
set_default :mysql_pass, true

namespace :mysql do
  
  desc "Login to mysql"
  task :login do
    extra_echo "Mysql: login"
    queue "mysql -u #{mysql_user} #{mysql_pass ? "-p" : ""}"
  end
end