# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git_cloner/version'

Gem::Specification.new do |spec|
  spec.name          = "git_cloner"
  spec.version       = GitCloner::VERSION
  spec.authors       = ["tbpgr"]
  spec.email         = ["tbpgr@tbpgr.jp"]
  spec.description   = %q{GitCloner clone git repositoris from Gitclonerfile settings}
  spec.summary       = %q{GitCloner clone git repositoris from Gitclonerfile settings}
  spec.homepage      = "https://github.com/tbpgr/git_cloner"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", "~> 4.0.1"
  spec.add_runtime_dependency "activemodel", "~> 4.0.2"
  spec.add_runtime_dependency "thor", "~> 0.18.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency "simplecov", "~> 0.8.2"
end
