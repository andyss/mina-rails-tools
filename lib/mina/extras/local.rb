# set_default :ssh_pub_key_path, "/home/"
# set_default :ssh_key_path, "/home/"
# 
namespace :local do
  task :check_ssh_key do
    check_key = check_file_exist?(ssh_pub_key_path!) && check_file_exist?(ssh_key_path!)

    unless check_key
      queue "ssh-keygen -t rsa"
    end 
  end
end