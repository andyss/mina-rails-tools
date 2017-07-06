def gem_install(package, options=nil)
  command echo_cmd "sudo gem install #{package} #{options} --no-rdoc --no-ri"
end

namespace :gem do
  
  task :install do
    gem_install("#{ENV["i"]}", "#{ENV["o"]}")
  end
  
  namespace :source do
    task :prepare do
      if in_china?
        command echo_cmd "sudo gem source -a http://ruby.taobao.org/"
        command echo_cmd "sudo gem source -r https://rubygems.org/"
      end
    end
    
    task :list do
      command echo_cmd "sudo gem source"
    end
  end
  
  namespace :install do
    task :rails do
      gem_install("rails")
    end
    
    task :mysql2 do
      # invoke :"ubuntu:install:libmysqlclient-dev"
      gem_install("mysql2")
    end
    
    task :unicorn do
      gem_install("unicorn")
    end
    
    task :mina do
      gem_install("mina")
    end
    
    task :god do
      gem_install("god")
    end
    
    task :rmagick do
      # invoke :"ubuntu:install:imagemagick"
      # invoke :"ubuntu:install:libmagickwand-dev"
      gem_install("rmagick")
    end
    
    task :nokogiri do
      gem_install("nokogiri")
    end
    
    task :sqlite3 do
      gem_install("sqlite3")
    end
    
    task :paperclip do
      gem_install("paperclip")
    end
  end
end