set_default :platform, :ubuntu
set_default :webserver, :unicorn

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

  command %[ls "#{deploy_to}/releases" -Art | sort | tail -n 1]
  command %[ls "#{deploy_to}/releases" -Art | sort | tail -n 1 | xargs -I active rm -rf "#{deploy_to}/releases/active"]

  # delete existing sym link and create a new symlink pointing to the previous release
  extra_echo("Creating new symlink from the previous release: ")
  command %[ls "#{deploy_to}/releases" -Art | sort | tail -n 1]
  command %[rm "#{deploy_to}/current"]
  command %[ls -Art "#{deploy_to}/releases" | sort | tail -n 1 | xargs -I active ln -s "#{deploy_to}/releases/active" "#{deploy_to}/current"]
  
  invoke :'unicorn:restart'
end