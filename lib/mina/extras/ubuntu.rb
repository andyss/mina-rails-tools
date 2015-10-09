require "mina/extras"
require "mina/extras/local"
require "mina/extras/apt"
require "mina/extras/gem"

set :platform, :ubuntu

def add_user(u)
  invoke :sudo
  queue "adduser #{u}"
end

namespace :ubuntu do
  
  task :before_check do
    to :before_hook do
      invoke :"local:check_ssh_key"
    end
  end
  
  namespace :remote do
    task :setup do
      invoke :sudo
      queue echo_cmd %{mkdir -p ~/.ssh}
      append_template(ssh_pub_key_path, ".ssh/authorized_keys")
    end
    
    task :add_deploy do
      invoke :sudo
      add_user("deploy")
      queue "sudo usermod -a -G www-data deploy"
      
      queue echo_cmd "sudo mkdir -p /home/deploy/.ssh"
      queue echo_cmd "sudo touch /home/deploy/.ssh/authorized_keys"
      append_template(ssh_pub_key_path, "/home/deploy/.ssh/authorized_keys")
      queue echo_cmd "sudo chown -R deploy:deploy /home/deploy/.ssh"
      queue echo_cmd "sudo chmod 664 /home/deploy/.ssh/authorized_keys"
    end
    
    task :add_ubuntu do
      invoke :sudo
      add_user("ubuntu")
      queue echo_cmd "sudo groupadd admin"
      queue echo_cmd "sudo usermod -a -G admin ubuntu"
      queue echo_cmd "sudo mkdir -p /home/ubuntu/.ssh"
      queue echo_cmd "sudo touch /home/ubuntu/.ssh/authorized_keys"
      append_template(ssh_pub_key_path, "/home/ubuntu/.ssh/authorized_keys")
      queue echo_cmd "sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh"
      queue echo_cmd "sudo chmod 664 /home/ubuntu/.ssh/authorized_keys"
    end
  end
  
  namespace :locale do
    task :setup do
      invoke :sudo
      queue echo_cmd %{sudo locale-gen en_US en_US.UTF8}
      queue echo_cmd %{sudo sh -c "echo 'LC_ALL=\"en_US.utf8\"' >> /etc/environment"}
    end
  end
    
  namespace :install do
    task :prepare do
      invoke :"apt:get:update"
      invoke :"apt:get:build-essential"
      invoke :"apt:get:git"
    end

    task :ruby do
      in_directory '/tmp' do
        queue "wget https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz"
        queue "tar xf ruby-2.2.3.tar.gz"
      end      
      
      in_directory '/tmp/ruby-2.2.3' do
        queue "./configure"
        queue "make"
        queue "sudo make install"
        queue "sudo ln -s /usr/local/bin/ruby /usr/bin/ruby"
      end
    end
    
    task :rubygems do
      in_directory '/tmp' do
        queue "wget http://rubygems.org/rubygems/rubygems-2.4.8.tgz"
        queue "tar xf rubygems-2.4.8.tgz"
      end
      
      in_directory '/tmp/rubygems-2.4.8' do
        queue "sudo ruby setup.rb install"
      end
    end 
        
    task :www do
      invoke :sudo
      queue echo_cmd "sudo mkdir -p /var/www"
      queue echo_cmd "sudo chown -R deploy:www-data /var/www"
    end
    
    task :ssh_key do
      queue "ssh-keygen -t rsa"
    end   
  end    
end