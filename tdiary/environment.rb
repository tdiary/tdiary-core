# -*- coding: utf-8 -*-
require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

if defined?(Bundler)
  # workaround: ruby-1.8 is not accept to ''.intern
  env = [:default]
  env += ENV['RACK_ENV'] if ENV['RACK_ENV']

  Bundler.require *env
end
