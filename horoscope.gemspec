# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'horoscope/version'

Gem::Specification.new do |gem|
  gem.name          = "horoscope"
  gem.version       = Horoscope::VERSION
  gem.authors       = ["bragboy"]
  gem.email         = ["bragboy@gmail.com"]
  gem.description   = %q{Calculate the horoscope of a person given the birth date and time}
  gem.summary       = %q{Calculate the accurate horoscope of a person using Vedic Horoscope technique given the birth time and birth place of the subject.}
  gem.homepage      = ""
  gem.add_development_dependency "rspec"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
