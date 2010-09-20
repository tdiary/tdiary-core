# -*- coding: utf-8 -*-
begin
	Encoding::default_external = 'UTF-8'
rescue NameError
	$KCODE = 'n'
end

require 'rubygems'
require 'bundler'

Bundler.setup
Bundler.require :default, :test

require 'rspec'
require 'rr'

RSpec.configure do |config|
	config.mock_with :rr
end
