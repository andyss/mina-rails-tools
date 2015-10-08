# def mv_config(source, destination)
#   queue %{mv #{deploy_to}/shared/config/#{source} #{deploy_to}/shared/config/#{destination}}
# end

def extra_echo(desc)
  queue "echo '--------> #{desc}'"
end

def extra_echo!(desc)
  queue! "echo '--------> #{desc}'"
end

def upload_file(desc, source, destination)
  # invoke :sudo
  # contents = File.read(source)
  extra_echo("Put #{desc} file to #{destination}")
  
  command = "scp "
  command << source
  command << " #{user}@#{domain!}:#{destination}"
  
  extra_echo("#{command}")
  
  result = %x[#{command}]
  puts result unless result == ""
  
  queue check_exists(destination)
end

def upload_template(desc, tpl, destination)
  contents = parse_template(tpl)
  extra_echo("Put #{desc} file to #{destination}")
  
  queue %{echo "#{contents}" > #{destination}}
  queue check_exists(destination)
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
