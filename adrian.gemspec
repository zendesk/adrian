# -*- encoding: utf-8 -*-
require File.expand_path('../lib/adrian/version', __FILE__)

Gem::Specification.new 'adrian', Adrian::VERSION do |gem|
  gem.authors       = ['Mick Staugaard', 'Eric Chapweske']
  gem.description   = 'A work dispatcher and some queue implementations'
  gem.summary       = 'Adrian does not do any real work, but is really good at delegating it'
  gem.homepage      = 'https://github.com/zendesk/adrian'
  gem.license       = 'Apache License Version 2.0'
  gem.files         = `git ls-files lib`.split("\n")
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'girl_friday'
end
