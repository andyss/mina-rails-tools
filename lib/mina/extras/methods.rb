# def mv_config(source, destination)
#   queue %{mv #{deploy_to}/shared/config/#{source} #{deploy_to}/shared/config/#{destination}}
# end

def extra_echo(desc)
  queue "echo '--------> #{desc}'"
end

def extra_echo!(desc)
  queue! "echo '--------> #{desc}'"
end

def scp_file(desc, source, destination)
  to :after_hook do
    extra_echo("Put #{desc} file to #{destination}")

    command = "scp "
    command << source
    command << " #{user}@#{domain!}:#{destination}"

    extra_echo("#{command}")

    result = %x[#{command}]
    puts result unless result == ""
  end
end

# def upload_file(desc, source, destination)
#   contents = File.read(source)
#   extra_echo("Put #{desc} file to #{destination}")
# 
#   queue %{echo "#{contents}" > #{destination}}
#   queue check_exists(destination)
# end

def upload_template(tpl, destination)
  desc = File.basename(destination)
  
  if tpl =~ /erb$/
    contents = parse_template(tpl)
  else
    contents = File.read(source)
  end
  
  extra_echo("Put #{desc} file to #{destination}")
  
  queue %{echo "#{contents}" > #{destination}}
  queue check_exists(destination)
end

def upload_shared_folder(folder, base)
  Dir[File.join(folder, "*")].map do |path|    
    if File.directory?(path)
      upload_shared_folder(path)
    else
      filename = File.basename(path)
      shared_folder = path.gsub(base, "").gsub(filename, "").gsub(/\A\//, "").gsub(/\/\Z/, "")
      des = "#{deploy_to}/shared/#{shared_folder}/#{filename.gsub(/\.erb$/, "")}"
      upload_template path, des      
    end
  end
  
end

def parse_template(file)
  erb(file).gsub('"','\\"').gsub('`','\\\\`').gsub('$','\\\\$')
end

def check_response
  'then echo "----->   SUCCESS"; else echo "----->   FAILED"; fi'
end

def check_exists(destination)
  %{if [[ -s "#{destination}" ]]; #{check_response}}
end

def check_ownership(u, g, destination)
  %{
    file_info=(`ls -l #{destination}`)
    if [[ -s "#{destination}" ]] && [[ ${file_info[2]} == '#{u}' ]] && [[ ${file_info[3]} == '#{g}' ]]; #{check_response}
    }
end

def check_exec_and_ownership(u, g, destination)
  %{
    file_info=(`ls -l #{destination}`)
    if [[ -s "#{destination}" ]] && [[ -x "#{destination}" ]] && [[ ${file_info[2]} == '#{u}' ]] && [[ ${file_info[3]} == '#{g}' ]]; #{check_response}
    }
end

def check_symlink(destination)
  %{if [[ -h "#{destination}" ]]; #{check_response}}
end

def custom_conf?(conf)
  Dir[File.join(Dir.pwd, "config", "deploy", "#{server}", "*")].map do |file|
    filename = File.basename(file)
    if filename.gsub(/.erb\Z/, "") == conf.to_s
      return true
    end
  end
  
  false
end

def custom_conf_path(conf)
  Dir[File.join(Dir.pwd, "config", "deploy", "#{server}", "*")].map do |file|
    filename = File.basename(file)
    if filename.gsub(/.erb\Z/, "") == conf.to_s
      return file
    end
  end
  
  Dir[File.join(Dir.pwd, "config", "deploy", "shared", "*")].map do |file|
    filename = File.basename(file)
    if filename.gsub(/.erb\Z/, "") == conf.to_s
      return file
    end
  end
  
  false
end

def queue_echo(s)
  queue %{echo '#{s}'}
end

# Allow to run some tasks as different (sudoer) user when sudo required
module Mina
  module Helpers
    def ssh_command
      args = domain!
      args = if sudo? && sudoer?
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
