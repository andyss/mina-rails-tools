set :apt_source, :us

def apt_get(package)
  command "sudo apt-get install #{package} -y"
end

namespace :apt do
  namespace :get do

    task :install do
      apt_get("#{ENV["i"]}")
    end

    task :update do
      command "sudo apt-get update"
    end

    task :nginx do
      apt_get("nginx")
    end

    task :git do
      apt_get("git-core")
    end

    task :redis do
      apt_get("redis-server")
    end

    task :mysql do
      apt_get("mysql-server-5.6")
    end

    task :"build-essential" do
      apt_get("build-essential")
    end

    task :"libmysqlclient-dev" do
      apt_get("libmysqlclient-dev")
    end

    task :"libssl-dev" do
      apt_get("libssl-dev")
    end

    task :"libreadline-dev" do
      apt_get("libreadline-dev")
    end

    task :"libsqlite3-dev" do
      apt_get("libsqlite3-dev")
    end

    task :"python-setuptools" do
      apt_get("python-setuptools")
    end

    task :imagemagick do
      apt_get("imagemagick")
    end

    task :"libmagickwand-dev" do
      apt_get("libmagickwand-dev")
    end
  end
end
