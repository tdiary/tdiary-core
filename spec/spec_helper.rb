# -*- coding: utf-8 -*-
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..')).untaint
require 'tdiary/environment'
require 'tdiary'

# monkey patch for configatron
require 'yaml' unless defined?(YAML)
YAML::ENGINE.yamler = 'syck' if RUBY_VERSION > '1.9'

Bundler.require :test if defined?(Bundler)
