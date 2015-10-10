def brew_install(package)
  queue echo_cmd "sudo brew install #{package} -y"
end


namespace :brew do
  
end