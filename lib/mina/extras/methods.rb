def mv_config(source, destination)
  command %{mv #{deploy_to}/shared/config/#{source} #{deploy_to}/shared/config/#{destination}}
end

def extra_echo(desc)
  command "echo '--------> #{desc}'"
end

def extra_echo!(desc)
  command "echo '--------> #{desc}'"
end

def scp_file(desc, source, destination)
  on :after_hook do
    extra_echo("Put #{desc} file to #{destination}")

    command = "scp "
    command << source
    command << " #{user}@#{domain!}:#{destination}"

    extra_echo("#{command}")

    result = %x[#{command}]
    puts result unless result == ""
  end
end

def upload_shared_file(filename)
  src = custom_conf_path(filename)

  if src
    upload_template src, "#{deploy_to}/shared/#{filename}"
  else
    upload_default_template filename, "#{deploy_to}/shared/#{filename}"
  end
end

def upload_file(filename, destination)
  src = custom_conf_path(filename)

  if src
    upload_template src, destination
  else
    upload_default_template filename, destination
  end
end

def append_template(source, destination)
  desc = File.basename(destination)

  if source =~ /erb$/
    contents = parse_template(source)
  else
    contents = File.read(source)
  end

  extra_echo("Put #{desc} file to #{destination}")

  script = <<EOF
script=$(cat <<'EOFF'
#{contents}
EOFF
)
EOF

  command %{#{script}}
  command %{echo "$script" >> #{destination}}
  command check_exists(destination)
end

def upload_template(source, destination)
  desc = File.basename(destination)

  if source =~ /erb$/
    contents = parse_template(source)
  else
    contents = parse_template(source)
  end

  extra_echo("Put #{desc} file to #{destination}")

  script = <<EOF
script=$(cat <<'EOFF'
#{contents}
EOFF
)
EOF

  command %{#{script}}
  command %{echo "$script" > #{destination}}
  command check_exists(destination)
end

def upload_default_template(tpl, destination)
  desc = File.basename(destination)

  source = File.join(File.dirname(__FILE__), "templates", "#{tpl}.erb")

  contents = parse_template(source)

  extra_echo("Put #{desc} file to #{destination}")

  script = <<EOF
script=$(cat <<'EOFF'
#{contents}
EOFF
)
EOF

  command %{#{script}}
  command %{echo "$script" > #{destination}}
  command check_exists(destination)
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
  erb(file)
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

def command_echo(s)
  command %{echo '#{s}'}
end

def check_file_exist?(file)
  File.exist?(file)
end
