# -*- encoding: utf-8 -*-
require File.expand_path('../lib/callisto/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Daniel Mircea"]
  gem.email         = ["daniel@thegeek.ro"]
  gem.description   = "Image thumbnails on the fly"
  gem.summary       = "Callisto"
  gem.homepage      = "https://github.com/viseztrance/callisto"

  gem.add_development_dependency "minitest"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "callisto"
  gem.require_paths = ["lib"]
  gem.version       = Callisto::VERSION
end
