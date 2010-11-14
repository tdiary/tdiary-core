# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler'

Bundler.setup
Bundler.require :default, :test

require 'rspec'
require 'rr'

RSpec.configure do |config|
	config.mock_with :rr
end
