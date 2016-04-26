module TDiary
	PATH = File::dirname( __FILE__ ).untaint
	class << self
		def root
			File.expand_path(File.join(library_root, '..'))
		end

		# directory where tDiary libraries is located
		def library_root
			File.expand_path('..', __FILE__)
		end

		# directory where the server was started
		def server_root
			Dir.pwd.untaint
		end
	end
end
require_relative '../lib/tdiary/cache/file'
require_relative '../lib/tdiary/io/default'

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

require 'benchmark/ips'

Benchmark.ips do |x|
	x.report('calendar') do
		io.calendar
	end

	x.report('calendar2') do
		io.calendar2
	end
end
