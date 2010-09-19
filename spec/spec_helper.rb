# -*- coding: utf-8 -*-
begin
	Encoding::default_external = 'UTF-8'
rescue NameError
	$KCODE = 'n'
end

require 'rubygems'
require 'rspec'
require 'rr'

RSpec.configure do |config|
	config.mock_with :rr
end
