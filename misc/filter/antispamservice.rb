# -*- coding: utf-8; -*-
#
# antispamservice.rb: tDiary comment spam filter using Antispam API $Revision: 1.4 $
#
# usage:
#    1) Get your free API Key from:
#         a. Akismet API from http://akismet.com/personal/
#    2) Set the API key and enable filter in your tdiary.conf. See below.
#          @options['antispam.service'] = 'rest.akismet.com'
#          @options['antispam.key'] = '1234567890ab'
#
# Copyright (C) TADA Tadashi <sho@spc.gr.jp> 2007.
# Modified by SHIBATA Hiroshi <shibata.hiroshi@gmail.com> 2008.
# Distributed under GPL2.
#

require 'net/http'
require 'uri'

module TDiary::Filter
	class AntispamserviceFilter < Filter
		def comment_filter( diary, comment )

			@antispam_service_list = {
				# Service => ServiceHost
				'Akismet' => 'rest.akismet.com',
			}

			host  = @antispam_service_list[@conf['antispam.service']]
			return true unless (host || '' ).length > 0
			debug("#{host}")

			key = @conf['antispam.key']
			return true unless (key || '' ).length > 0

			blog = @conf.index.dup
			blog[0, 0] = base_url unless %r|^https?://|i =~ blog
			blog.gsub!( %r|/\./|, '/' )
			permalink = "#{blog}?date=#{diary.date.strftime('%Y%m%d')}"

			if comment.name == 'TrackBack' then
				comment_type = 'trackback'
				comment_author_url = comment.body.split[0]
			else
				comment_type = 'comment'
				comment_author_url = nil
			end

			uri = URI::parse( "http://#{key}.#{host}/1.1/comment-check" )
			data =  "blog=#{blog}"
			data << "&user_ip=#{@cgi.remote_addr}"
			data << "&user_agent=#{u @cgi.user_agent}"
			data << "&permalink=#{permalink}"
			data << "&comment_type=#{comment_type}"
			data << "&comment_author=#{u comment.name}"
			data << "&comment_author_email=#{u comment.mail}"
			data << "&comment_author_url=#{u comment_author_url}" if comment_author_url
			data << "&comment_content=#{u comment.body}"

			unless check( uri, data ) then
				debug( "antispam judged spam." )
				comment.show = false
				#
				# NOTICE: force hide TSUKKOMIs. because Antispam judge
				#         Japanese TSUKKOMI to spam sometime.
				#
				return true # (@conf['spamfilter.filter_mode'] || true)
			end
			debug( "antispam judged ham.", DEBUG_FULL )
			return true
		end

		def check( uri, data )
			header = {
				'User-Agent' => "tDiary/#{TDIARY_VERSION} | Antispam filter/$Revision: 1.4 $",
				'Content-Type' => 'application/x-www-form-urlencoded'
			}
			debug( "antispam request: #{data}", DEBUG_FULL )
			proxy_h, proxy_p = (@conf['proxy'] || '').split( /:/ )
			res = ::Net::HTTP::Proxy( proxy_h, proxy_p ).start( uri.host, uri.port ) do |http|
				http.post( uri.path, data, header )
			end
			debug( "antispam result: #{res.body}", DEBUG_FULL )
			return (res.body != 'true')
		end

		def u( str )
			CGI::escape( str )
		end
	end
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
