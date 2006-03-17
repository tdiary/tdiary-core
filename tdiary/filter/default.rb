#
# default.rb: included TDiary::Filter::DefaultFilter class
#
# Copyright (C) 2001-2005, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#

module TDiary
	module Filter
		class DefaultFilter < Filter
			def comment_filter( diary, comment )
				if /post/i !~ @cgi.request_method then
					return false
				end
				if comment.name.strip.empty? or comment.body.strip.empty? then
					return false
				end
				idx = 1
				diary.each_comment( -1 ) do |com|
					return false if idx >= @conf.comment_limit_per_day
					return false if comment == com
					idx += 1
				end
				true
			end

			def referer_filter( referer )
				if not referer then
					false
				elsif /[\x00-\x20\x7f-\xff]/ =~ referer then
					false
				elsif @conf.bot?
					false
				elsif %r|^https?://|i =~ referer
					ref = CGI::unescape( referer.sub( /#.*$/, '' ).sub( /\?\d{8}$/, '' ) )
					@conf.no_referer.each do |noref|
						return false if /#{noref}/i =~ ref
					end
					true
				else
					false
				end
			end
		end
	end
end
