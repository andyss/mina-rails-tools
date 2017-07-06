require "mina/extras"

set :sudoer, "root"
task :sudo do
  # set :user, sudoer
  set :sudo, true
  # set :term_mode, :system
end

task :user do
  # set :user, user
  set :sudo, false
  # set :term_mode, :system
end

task :setup => :environment  do
  invoke :"extra:create_shared_paths"
  invoke :"extra:upload"

  invoke :"nginx:upload"

  if use_unicorn
    invoke :'unicorn:upload'

    if use_god
      invoke :'unicorn:god:upload'
    end
  end

  command %{echo "-----> (!!!) You now need to run 'mina sudoer_setup' to run the parts that require sudoer user (!!!)"}

  # if sudoer?
  #   command %{echo "-----> (!!!) You now need to run 'mina sudoer_setup' to run the parts that require sudoer user (!!!)"}
  # else
  #   invoke :sudoer_setup
  # end
end

task :sudoer_setup do
  invoke :sudo
  invoke :'nginx:link'
  invoke :'nginx:restart'

  if use_unicorn
    invoke :'unicorn:link'

    if use_god
      invoke :'unicorn:god:link'
    end
  end
end

namespace :extra do
  task :create_shared_paths do
    folders = shared_paths.map do |path|
      path.gsub(/\/\S+\.\S+\Z/, "")
    end.uniq

    folders.map do |dir|
      command %{mkdir -p "#{fetch(:deploy_to)}/shared/#{dir}"}
    end
  end

  task :upload do
    base = File.join(Dir.pwd, "config", "deploy", "shared")

    Dir[File.join(base, "*")].map do |path|
      # File.directory?
      next if File.file?(path)

      upload_shared_folder(path, base)
    end

    base = File.join(Dir.pwd, "config", "deploy", "#{server}")

    Dir[File.join(base, "*")].map do |path|
      # File.directory?
      next if File.file?(path)

      upload_shared_folder(path, base)
    end
  end
end


# Allow to run some tasks as different (sudoer) user when sudo required
module Mina
  module SshHelpers
    def ssh_command
      args = domain!
      args = if settings[:sudo] && sudoer?
               "#{sudoer}@#{args}"
             elsif user?
               "#{user}@#{args}"
             end
      args << " -i #{identity_file}" if identity_file?
      args << " -p #{port}" if port?
      args << " -t"
      "ssh #{args}"
    end
  end
end


module Mina
  module Helpers
    def clean_commands!
      @commands = nil
    end
  end
end
