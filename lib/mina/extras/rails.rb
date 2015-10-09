set_default :log_line, 200

desc "Rails Log"
task :log => :environment do
  queue echo_cmd("cd #{deploy_to}/current && tail -f log/production.log -n #{ENV["n"] || log_line}")
end

desc "Rails Console"
task :console => :environment do
  queue echo_cmd("cd #{deploy_to}/current && RAILS_ENV=production bundle exec rails c")
end
