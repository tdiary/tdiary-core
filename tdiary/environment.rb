# -*- coding: utf-8 -*-

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

if defined?(Bundler)
  env = [:default]
  env << :development if ENV['RACK_ENV'].nil? || ENV['RACK_ENV'].empty?
  env << ENV['RACK_ENV'].intern if ENV['RACK_ENV']
  env = env.reject{|e| Bundler.settings.without.include? e }
  Bundler.require *env
end
