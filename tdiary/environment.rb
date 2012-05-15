# -*- coding: utf-8 -*-
require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

if defined?(Bundler)
  if ENV['RACK_ENV'] == 'production'
    Bundler.require :default, :production
  else
    Bundler.require :default
  end
end
