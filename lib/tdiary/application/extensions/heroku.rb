# -*- coding: utf-8 -*-
require 'tdiary/application'

TDiary::Application.after_initialize do
	# avoid offline mode at CGI.new
	ARGV.replace([""])
	cgi = RackCGI.new

	request = TDiary::Request.new(ENV, cgi)
	conf = TDiary::Configuration.new(cgi, request)
	tdiary = TDiary::TDiaryBase.new(cgi, '', conf)
	io = conf.io_class.new(tdiary)

	plugin = TDiary::Plugin.new(
		'conf' => conf,
		'mode' => 'startup',
		'diaries' => tdiary.diaries,
		'cgi' => cgi,
		'years' => nil,
		'cache_path' => io.cache_path,
		'date' => Time.now,
		'comment' => nil,
		'last_modified' => Time.now,  # FIXME
		'logger' => TDiary.logger
	)
	binding.pry
	plugin.makerss_write
end
