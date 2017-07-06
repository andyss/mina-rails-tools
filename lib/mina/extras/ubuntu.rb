require "mina/extras"
require "mina/extras/local"
require "mina/extras/apt"
require "mina/extras/gem"

set :platform, :ubuntu

def add_user(u)
  invoke :sudo
  command "adduser #{u}"
end

namespace :ubuntu do

  task :before_check do
    on :before_hook do
      invoke :"local:check_ssh_key"
    end
  end

  namespace :remote do
    task :setup do
      invoke :sudo
      command %{mkdir -p ~/.ssh}
      append_template(ssh_pub_key_path, ".ssh/authorized_keys")
    end

    task :add_deploy do
      invoke :sudo
      add_user("deploy")
      command "sudo usermod -a -G www-data deploy"

      command "sudo mkdir -p /home/deploy/.ssh"
      command "sudo touch /home/deploy/.ssh/authorized_keys"
      append_template(ssh_pub_key_path, "/home/deploy/.ssh/authorized_keys")
      command "sudo chown -R deploy:deploy /home/deploy/.ssh"
      command "sudo chmod 664 /home/deploy/.ssh/authorized_keys"
    end

    task :add_ubuntu do
      invoke :sudo
      add_user("ubuntu")
      command "sudo groupadd admin"
      command "sudo usermod -a -G admin ubuntu"
      command "sudo mkdir -p /home/ubuntu/.ssh"
      command "sudo touch /home/ubuntu/.ssh/authorized_keys"
      append_template(ssh_pub_key_path, "/home/ubuntu/.ssh/authorized_keys")
      command "sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh"
      command "sudo chmod 664 /home/ubuntu/.ssh/authorized_keys"
    end
  end

  namespace :locale do
    task :setup do
      invoke :sudo
      command %{sudo locale-gen en_US en_US.UTF8}
      command %{sudo sh -c "echo 'LC_ALL=\"en_US.utf8\"' >> /etc/environment"}
    end
  end

  namespace :install do
    task :prepare do
      invoke :"apt:get:update"
      invoke :"apt:get:build-essential"
      invoke :"apt:get:git"
    end

    task :ruby do
      in_path '/tmp' do
        command "wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz"
        command "tar xf ruby-2.3.1.tar.gz"
      end

      in_path '/tmp/ruby-2.3.1' do
        command "./configure"
        command "make"
        command "sudo make install"
        command "sudo ln -s /usr/local/bin/ruby /usr/bin/ruby"
      end
    end

    task :rubygems do
      in_path '/tmp' do
        command "wget https://rubygems.org/rubygems/rubygems-2.6.8.tgz"
        command "tar xf rubygems-2.6.8.tgz"
      end

      in_path '/tmp/rubygems-2.6.8' do
        command "sudo ruby setup.rb install"
      end
    end

    task :www do
      invoke :sudo
      command "sudo mkdir -p /var/www"
      command "sudo chown -R deploy:www-data /var/www"
    end

    task :ssh_key do
      command "ssh-keygen -t rsa"
    end
  end
end
