namespace :redis do
  
  desc "Connect to redis"
  task :connect do
    extra_echo "Redis: connect"
    queue "redis-cli"
  end
    
end