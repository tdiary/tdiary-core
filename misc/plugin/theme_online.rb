# theme_online.rb: choice theme from online repository on tDiary.org
#
# options:
#    @options['theme_online.url']: top level URL of another theme site
#
# Copyright (C) 2014 by TADA Tadashi <t@tdtds.jp>
# You can distribute and/or modify it under GPL2 or any later version.
#
require 'json'
require 'open-uri'

def theme_list_online(list)
	url = @options['theme_online.url'] || '//tdiary.github.io/tdiary-theme/'
	url = "http:#{url}" if url =~ %r|\A//|
	begin
		online_list = JSON.load(open(File.join(url, 'themes.json'), &:read))['themes']
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
	url = @options['theme_online.url'] || '//tdiary.github.io/tdiary-theme/'
	File.join(url, "#{h theme}/#{h theme}.css")
end
