# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mobiledoc_html_renderer/version'

Gem::Specification.new do |spec|
  spec.name          = "mobiledoc-html-renderer"
  spec.version       = Mobiledoc::HTMLRenderer::VERSION
  spec.authors       = ["Justin Giancola"]
  spec.email         = ["justin.giancola@gmail.com"]

  spec.summary       = %q{MobileDoc HTML Renderer for Ruby}
  spec.homepage      = "https://github.com/elucid/mobiledoc-html-renderer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"

  spec.add_dependency "nokogiri", "~> 1.6.2"
end
