$:.unshift 'lib'

require 'benchmark/ips'

require 'tdiary'
require 'tdiary/cache/file'
require 'tdiary/io/default'

class DummyTDiary
	attr_accessor :conf

	def initialize
		@conf = DummyConf.new
		@conf.data_path = TDiary.root + "/tmp/"
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

conf = DummyConf.new
conf.data_path = TDiary.root + '/tmp/data/'
diary = DummyTDiary.new
diary.conf = conf
io = TDiary::IO::Default.new(diary)

Benchmark.ips do |x|
	x.report('calendar') do
		io.calendar
	end

	x.report('calendar2') do
		io.calendar2
	end
end
