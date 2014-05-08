# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll-page-hooks/version'

Gem::Specification.new do |gem|
  gem.name          = "jekyll-page-hooks"
  gem.version       = Jekyll::PageHooksVersion::VERSION
  gem.authors       = ["Brandon Mathis"]
  gem.email         = ["brandon@imathis.com"]
  gem.description   = %q{Monkeypatches Jekyll's Site, Post, Page and Convertible classes to allow other plugins to access page/post content before and after render, and after write.}
  gem.summary       = %q{Allows other plugins to access page/post content before and after render, and after write.}
  gem.homepage      = "http://github.com/octopress/jekyll-page-hooks"
  gem.license       = "MIT"

  gem.add_runtime_dependency 'jekyll', '>= 2.0.0'

  gem.files         = `git ls-files`.split($/)
  gem.require_paths = ["lib"]
end
