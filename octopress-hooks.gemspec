# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'octopress-hooks/version'

Gem::Specification.new do |gem|
  gem.name          = "octopress-hooks"
  gem.version       = Octopress::Hooks::VERSION
  gem.authors       = ["Brandon Mathis"]
  gem.email         = ["brandon@imathis.com"]
  gem.summary       = %q{Allows access to Jekyll's site, posts and pages at different points in the life cycle of a build. Formerly known as 'jekyll-page-hooks'.}
  gem.homepage      = "http://github.com/octopress/hooks"
  gem.license       = "MIT"

  gem.add_runtime_dependency 'jekyll', '>= 2.0'

  gem.add_development_dependency 'clash'
  gem.add_development_dependency 'rake'

  if RUBY_VERSION >= "2"
    gem.add_development_dependency "octopress-debugger"
  end
  
  gem.files         = `git ls-files`.split("\n").grep(%r{^(bin\/|lib\/|assets\/|local\/|changelog|readme|license)}i)
  gem.require_paths = ["lib"]
end
