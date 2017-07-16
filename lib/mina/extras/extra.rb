require "mina/extras"

set :sudoer, "root"
task :sudo do
  # set :user, sudoer
  set :sudo, true
end

task :user do
  # set :user, user
  set :sudo, false
end

task :setup => :environment  do
  invoke :"extra:create_shared_paths"
  invoke :"extra:upload"

  invoke :"nginx:upload"

  if fetch(:use_unicorn)
    invoke :'unicorn:upload'

    if fetch(:use_god)
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

  if fetch(:use_unicorn)
    invoke :'unicorn:link'

    if fetch(:use_god)
      invoke :'unicorn:god:link'
    end
  end
end

namespace :extra do
  task :create_shared_paths do
    if fetch(:shared_paths)
      folders = fetch(:shared_paths).map do |path|
        path.gsub(/\/\S+\.\S+\Z/, "")
      end.uniq

      folders.map do |dir|
        command %{mkdir -p "#{fetch(:deploy_to)}/shared/#{dir}"}
      end
    end
  end

  task :upload do
    base = File.join(Dir.pwd, "config", "deploy", "shared")

    Dir[File.join(base, "*")].map do |path|
      # File.directory?
      next if File.file?(path)

      upload_shared_folder(path, base)
    end

    base = File.join(Dir.pwd, "config", "deploy", "#{fetch(:server)}")

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
      args = if settings[:sudo] && fetch(:sudoer)
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
  module Backend
    class Remote

      def ssh
        ensure!(:domain)
        args = fetch(:domain)
        if fetch(:sudo) && fetch(:sudoer)
          args = "#{fetch(:sudoer)}@#{fetch(:domain)}" if set?(:user)
        else
          args = "#{fetch(:user)}@#{fetch(:domain)}" if set?(:user)
        end
        args += " -i #{fetch(:identity_file)}" if set?(:identity_file)
        args += " -p #{fetch(:port)}" if set?(:port)
        args += ' -A' if set?(:forward_agent)
        args += " #{fetch(:ssh_options)}" if set?(:ssh_options)
        args += ' -tt'
        "ssh #{args}"
      end

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
