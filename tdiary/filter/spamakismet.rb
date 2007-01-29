#
# spamakismet.rb: tDiary comment spam filter using Akismet API $Revision: 1.2 $
#
# usage:
#    1) Get your Akismet free API from http://akismet.com/personal/.
#    2) Set the API key and enable filter in your tdiary.conf. See below.
#          @options['akismet.enable'] = true
#          @options['akismet.key'] = '1234567890ab'
#
# Copyright (C) TADA Tadashi <sho@spc.gr.jp> 2007.
# Distributed under GPL2.
#

require 'net/http'
require 'uri'

module TDiary::Filter
	class SpamakismetFilter < Filter
		def comment_filter( diary, comment )
			return true unless @conf['akismet.enable']

			key = @conf['akismet.key']
			return true unless (key || '' ).length > 0

			blog = @conf.index.dup
			blog[0, 0] = @conf.base_url unless %r|^https?://|i =~ blog
			blog.gsub!( %r|/\./|, '/' )
			permalink = "#{blog}?date=#{diary.date.strftime('%Y%m%d')}"

			if comment.name == 'TrackBack' then
				comment_type = 'trackback'
				comment_author_url = comment.body.split[0]
			else
				comment_type = 'comment'
				comment_author_url = nil
			end

			uri = URI::parse( "http://#{key}.rest.akismet.com/1.1/comment-check" )
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
				debug( "akismet judged spam." )
				comment.show = false
				return (@conf['spamfilter.filter_mode'] || true)
			end
			debug( "akismet judged ham.", DEBUG_FULL )
			return true
		end

		def check( uri, data )
			header = {
				'User-Agent' => "tDiary/#{TDIARY_VERSION} | Akismet filter/$Revision: 1.2 $",
				'Content-Type' => 'application/x-www-form-urlencoded'
			}
			body = nil
			debug( "akismet request: #{data}", DEBUG_FULL )
			proxy_h, proxy_p = (@conf['proxy'] || '').split( /:/ )
			::Net::HTTP::Proxy( proxy_h, proxy_p ).start( uri.host, uri.port ) do |http|
				res, body = http.post( uri.path, data, header )
			end
			debug( "akismet result: #{body}", DEBUG_FULL )
			return (body != 'true')
		end

		def u( str )
			CGI::escape( str )
		end
	end
end

