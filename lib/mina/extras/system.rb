task :health do
  queue 'ps aux | grep -v grep | grep -v bash | grep -e "bin\/god" -e "unicorn_rails" -e "mongod" -e "nginx" -e "redis" -e "STAT START   TIME COMMAND" -e "bash"'
end

task :uptime do
  queue 'uptime'
end