# -*- coding: utf-8 -*-
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..')).untaint

ENV['RACK_ENV'] = "test"

require 'tdiary/environment'

if ENV['COVERAGE'] = 'simplecov'
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

class DummyTDiary
	def conf
		conf = DummyConf.new
      conf.data_path = TDiary.root + "/tmp/"
      conf
	end

	def ignore_parser_cache
		false
	end
end

class DummyConf
	attr_accessor :data_path

	def cache_path
		TDiary.root + "/tmp/cache"
	end

	def options
		{}
	end

	def style
		"wiki"
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
