# coding: utf-8
lib = File.expand_path('../', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tdiary/version'

Gem::Specification.new do |spec|
  spec.name          = "tdiary"
  spec.version       = TDiary::VERSION
  spec.authors       = ["TADA Tadashi", "SHIBATA Hiroshi", "MATSUOKA Kohei"]
  spec.email         = ["support@tdiary.org"]
  spec.summary       = %q{a TSUKKOMI-able Web-log}
  spec.description   = %q{tDiary is so called Weblog.}
  spec.homepage      = "http://www.tdiary.org/"
  spec.license       = "GPL-2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["."]

  spec.required_ruby_version = '>= 1.9.2'

  spec.add_dependency 'rack', '>= 1.0.0'
  spec.add_dependency 'rake', '>= 10.0.0'
  spec.add_dependency 'hikidoc', '>= 0.0.6'
  spec.add_dependency 'rdtool', '>= 0.6.0'
  spec.add_dependency 'imagesize', '>= 0.1.0'

  spec.add_dependency 'sprockets', '~> 2.10'

  spec.add_dependency 'thor', '~> 0.18'
  spec.add_dependency "bundler", "~> 1.3"
end
