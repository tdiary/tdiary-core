# -*- coding: utf-8 -*-
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..')).untaint

ENV['RACK_ENV'] = "test"

require 'tdiary/environment'

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
elsif RUBY_VERSION > '1.9'
	require 'simplecov'
	require 'coveralls'

	SimpleCov.formatter = Coveralls::SimpleCov::Formatter
	SimpleCov.start do
		add_filter '/spec/'
		add_filter '/test/'
		add_filter '/vendor/'
	end
end

require 'tdiary'

RSpec.configure do |config|
	config.treat_symbols_as_metadata_keys_with_true_values = true
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
