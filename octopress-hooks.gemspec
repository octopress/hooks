# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'octopress-hooks/version'

Gem::Specification.new do |gem|
  gem.name          = "octopress-hooks"
  gem.version       = Octopress::Hooks::VERSION
  gem.authors       = ["Brandon Mathis"]
  gem.email         = ["brandon@imathis.com"]
  gem.description   = %q{Allows access to Jekyll's site, posts and pages at different points in the life cycle of a build. Formerly known as 'jekyll-page-hooks'.}
  gem.summary       = %q{Allows access to Jekyll's site, posts and pages at different points in the life cycle of a build. Formerly known as 'jekyll-page-hooks'.}
  gem.homepage      = "http://github.com/octopress/hooks"
  gem.license       = "MIT"

  gem.add_runtime_dependency 'jekyll', '~> 2.0'

  gem.add_development_dependency 'clash', '~> 1.0'

  gem.files         = `git ls-files`.split($/)
  gem.require_paths = ["lib"]
end
