# -*- coding: utf-8 -*-
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..')).untaint
require 'tdiary/environment'
Bundler.require :test if defined?(Bundler)
require 'tdiary'

if ENV['COVERAGE'] == 'simplecov'
	require 'simplecov'
	require 'simplecov-rcov'
	class SimpleCov::Formatter::MergedFormatter
		def format(result)
			SimpleCov::Formatter::HTMLFormatter.new.format(result)
			SimpleCov::Formatter::RcovFormatter.new.format(result)
		end
	end
	SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
	SimpleCov.start do
		add_filter '/spec/'
		add_filter '/vendor/'
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
