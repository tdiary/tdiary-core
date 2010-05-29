# -*- coding: utf-8 -*-

begin
	Encoding::default_external = 'UTF-8'
rescue NameError
	$KCODE = 'n'
end

$:.unshift(File.expand_path("lib", File.dirname(__FILE__)))
$:.unshift(File.expand_path("../", File.dirname(__FILE__)))

require 'rubygems'
require 'spec'
require 'rr'

Spec::Runner.configure do |config|
	config.mock_with :rr
end
