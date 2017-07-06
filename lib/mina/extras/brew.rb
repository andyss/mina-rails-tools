def brew_install(package)
  command "sudo brew install #{package} -y"
end


namespace :brew do
  
end