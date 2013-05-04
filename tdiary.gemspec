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

  spec.add_runtime_dependency 'rack'
  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'thor'

  spec.add_development_dependency "bundler", "~> 1.3"
end
