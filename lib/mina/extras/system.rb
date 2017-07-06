task :health do
  command 'ps aux | grep -v grep | grep -v bash | grep -e "bin\/god" -e "unicorn_rails" -e "mongod" -e "nginx" -e "redis" -e "STAT START   TIME COMMAND" -e "bash"'
end

task :uptime do
  command 'uptime'
end

task :gp do
  command "ps aux | grep #{ENV["p"]}"
end