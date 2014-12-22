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

# need to prepare before require 'tdiary'
FileUtils.mkdir_p File.expand_path(File.dirname(__FILE__) + '/..') + '/misc/lib/foo-0.0.1/lib'

require 'tdiary'

RSpec.configure do |config|
	config.expect_with :rspec do |c|
		c.syntax = :expect
	end

	config.after(:suite) do
		FileUtils.rm_rf File.expand_path(File.dirname(__FILE__) + '/..') + '/misc/lib/foo-0.0.1'
	end
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
