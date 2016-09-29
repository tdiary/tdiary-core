lib = File.expand_path('../lib', __FILE__)
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
  spec.license       = "GPL2"

  spec.files         = Dir[
    'ChangeLog',
    'config.ru',
    'Gemfile',
    'Gemfile.lock',
    'README.md',
    'Rakefile',
    'tdiary.conf*',
    'bin/**/*',
    'doc/**/*',
    'js/**/*',
    'lib/**/*',
    'misc/**/*',
    'public/**/*',
    'theme/**/*',
    'vendor/**/*',
    'views/**/*'
  ]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1.0'

  spec.add_dependency 'emot'
  spec.add_dependency 'fastimage'
  spec.add_dependency 'hikidoc'
  spec.add_dependency 'mail'
  spec.add_dependency 'rack'
  spec.add_dependency 'rake'
  spec.add_dependency 'sprockets'
  spec.add_dependency 'thor'
  spec.add_dependency "bundler", "~> 1.3"
end
