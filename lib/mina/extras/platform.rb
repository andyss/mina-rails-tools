set :platform, :ubuntu
set :webserver, :unicorn

namespace :platform do
  desc 'List support platforms'
  task :list do
    p ["ubuntu", "OS X"].join(", ")
  end
end

desc "Roll backs the lates release"
task :rollback => :environment do
  extra_echo!("Rolling back to previous release for instance: #{domain}")
  command %[echo "-----> Rolling back to previous release for instance: #{domain}"]

  # remove latest release folder (active release)
  extra_echo("Deleting active release: ")

  command %[ls "#{fetch(:deploy_to)}/releases" -Art | sort | tail -n 1]
  command %[ls "#{fetch(:deploy_to)}/releases" -Art | sort | tail -n 1 | xargs -I active rm -rf "#{fetch(:deploy_to)}/releases/active"]

  # delete existing sym link and create a new symlink pointing to the previous release
  extra_echo("Creating new symlink from the previous release: ")
  command %[ls "#{fetch(:deploy_to)}/releases" -Art | sort | tail -n 1]
  command %[rm "#{fetch(:deploy_to)}/current"]
  command %[ls -Art "#{fetch(:deploy_to)}/releases" | sort | tail -n 1 | xargs -I active ln -s "#{fetch(:deploy_to)}/releases/active" "#{fetch(:deploy_to)}/current"]
  
  invoke :'unicorn:restart'
end