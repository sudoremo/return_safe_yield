# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'return_safe_yield/version'

Gem::Specification.new do |spec|
  spec.name          = 'return_safe_yield'
  spec.version       = ReturnSafeYield::VERSION
  spec.authors       = ['Remo Fritzsche']
  spec.email         = ['dev@remofritzsche.com']

  spec.summary       = %(
    Provides helpers for dealing with `return` statements in blocks and procs.'
  ).strip
  spec.description   = %(
    Provides helpers for dealing with `return` statements in blocks
    and procs by either disallowing them or else ensuring that some code
    runs after yielding.
  ).strip
  spec.homepage      = 'https://github.com/remofritzsche/return_safe_yield'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
