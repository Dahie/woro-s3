# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'woro-s3/version'

Gem::Specification.new do |spec|
  spec.name          = "woro-s3"
  spec.version       = Woro::S3::VERSION
  spec.authors       = ["Daniel Senff"]
  spec.email         = ["mail@danielsenff.de"]
  spec.summary       = %q{Adapter to Amazon S3 for use in Woro remote task management}
  spec.description   = %q{Adapter to Amazon S3 for use in Woro remote task management}
  spec.homepage      = "http://github.com/Dahie/woro-s3"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'aws-sdk-v1'
  spec.add_dependency 'woro'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
