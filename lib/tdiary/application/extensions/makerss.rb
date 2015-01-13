# -*- coding: utf-8 -*-
require 'tdiary/application'
require 'tdiary/request'

module TDiary
	class DummyRequest
		def base_url
			'/'
		end
	end
end

TDiary::Application.after_initialize do
	conf = TDiary::Configuration.new(nil, TDiary::DummyRequest.new)
end
