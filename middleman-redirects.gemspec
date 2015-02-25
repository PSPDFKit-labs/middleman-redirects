# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'middleman/redirects/version'

Gem::Specification.new do |spec|
  spec.name          = "middleman-redirects"
  spec.version       = Middleman::Redirects::VERSION
  spec.authors       = ["Martin Schurrer"]
  spec.email         = ["martin@schuerrer.org"]

  spec.summary       = %q{Makes middleman support REDIRECT files in development}
  spec.homepage      = "https://github.com/PSPDFKit-labs/middleman-redirects"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
