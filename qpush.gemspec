# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qpush/version'

Gem::Specification.new do |spec|
  spec.name          = "qpush"
  spec.version       = QPush::VERSION
  spec.authors       = ["Nicholas Sweeting"]
  spec.email         = ["nsweeting@gmail.com"]

  spec.summary       = 'Fast and simple job queue microservice for Ruby.'
  spec.description   = 'Fast and simple job queue microservice for Ruby.'
  spec.homepage      = 'https://github.com/nsweeting/qpush'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = %w( qpush-server qpush-web )
  spec.require_paths = %w( lib )

  spec.add_runtime_dependency     "redis", "~> 3.3"
  spec.add_runtime_dependency     "connection_pool", "~> 2.2"
  spec.add_runtime_dependency     "object_validator"
  spec.add_runtime_dependency     "sequel", "~> 4.18"
  spec.add_runtime_dependency     "sinatra", "~> 1.4"
  spec.add_runtime_dependency     "sinatra-cross_origin"
  spec.add_runtime_dependency     "parse-cron", "~> 0.1"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
