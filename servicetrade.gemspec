# frozen_string_literal: true

require_relative "lib/servicetrade/version"

Gem::Specification.new do |spec|
  spec.name          = "servicetrade"
  spec.version       = ServiceTrade::VERSION
  spec.authors       = ["Bryce Holcomb"]
  spec.email         = ["bryce@destilado.tech"]
  spec.summary       = "Ruby client for the ServiceTrade API"
  spec.description   = "A Ruby library for interacting with the ServiceTrade API"
  spec.homepage      = "https://github.com/destilado/servicetrade-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.files = Dir["lib/**/*", "README.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "stringio", "~> 3.1.2"
end
