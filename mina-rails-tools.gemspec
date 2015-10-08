# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mina/extras/version'

Gem::Specification.new do |spec|
  spec.name          = "mina-rails-tools"
  spec.version       = Mina::Extras::VERSION
  spec.authors       = ["Joey Lin"]
  spec.email         = ["joeyoooooo@gmail.com"]

  spec.summary       = %q{Extra deploy scripts for rails}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/andyss/mina-rails-tools"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "http://joeyoooooo.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "mina", "0.3.7"
end
