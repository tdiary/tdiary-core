# -*- coding: utf-8; -*-
#
# default.rb: included TDiary::Filter::DefaultFilter class
#
# Copyright (C) 2001-2005, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2 or any later version.
#

module TDiary
	module Filter
		class DefaultFilter < Filter
			def comment_filter( diary, comment )
				if 'POST' != @cgi.request_method then
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
				#elsif /[\x00-\x20\x7f-\xff]/ =~ referer then
				#	false
				elsif @conf.bot =~ @cgi.user_agent
					false
				elsif %r|^https?://|i =~ referer
					ref = CGI::unescape( referer.sub( /#.*$/, '' ).sub( /\?\d{8}$/, '' ) ).force_encoding('ASCII-8BIT')
					@conf.no_referer.each do |noref|
						return false if /#{noref.dup.force_encoding('ASCII-8BIT')}/i =~ ref
					end
					true
				else
					false
				end
			end
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
