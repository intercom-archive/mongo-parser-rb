# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongo-parser-rb/version'

Gem::Specification.new do |gem|
  gem.name          = "mongo-parser-rb"
  gem.version       = MongoParserRB::VERSION
  gem.authors       = ["Ben McRedmond"]
  gem.email         = ["ben@intercom.io"]
  gem.description   = %q{Parse and evaluate mongo queries in Ruby}
  gem.summary       = gem.description
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
