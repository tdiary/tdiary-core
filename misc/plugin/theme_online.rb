# theme_online.rb: choice theme from online repository on tDiary.org
#
# Copyright (C) 2014 by TADA Tadashi <t@tdtds.jp>
# You can distribute and/or modify it under GPL
#
require 'json'
require 'open-uri'

def theme_list_online(list)
	begin
		online_list = JSON.load(open('http://theme.tdiary.org/themes.json', &:read))['themes']
		list + online_list.keys.map do |t|
			title = online_list[t]['title']
			label = t == title ? '' : " (#{title})"
			["online/#{t}", "#{t}#{label}"]
		end
	rescue
		@logger.error "could not get theme list from online: #$!"
		list
	end
end

def theme_url_online(theme)
	"http://theme.tdiary.org/#{h theme}/#{h theme}.css"
end
