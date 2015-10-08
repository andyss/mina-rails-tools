set_default :mysql_user, :root
set_default :mysql_pass, true

namespace :mysql do
  desc "Login to mysql"
  task :login do
    queue_echo "mysql -u #{mysql_user} #{mysql_pass ? "-p" : ""}"
  end
end