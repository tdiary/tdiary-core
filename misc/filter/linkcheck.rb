# -*- coding: utf-8; -*-
#
# linkcheck.rb: tDiary filter for checking link to my site in TrackBack source site.
#
# specification:
#    * if source site has no URI of my site of top page, it's spam!
#    * reading only top of 100KB of source site.
#    * no response over 10 sec, it's mybe spam.
#
# Copyright (C) 2007 by TADA Tadashi <sho@spc.gr.jp>
# Distributed under GPL2.
#

require 'open-uri'
require 'timeout'

module TDiary::Filter
	class LinkcheckFilter < Filter
		def initialize( *args )
			super( *args )
			@filter_mode = @conf['spamfilter.filter_mode']
			@filter_mode = true if @filter_mode == nil
		end

		def comment_filter( diary, comment )
			if @conf['spamfilter.linkcheck'] == 0 then
				debug( "No linkcheck to TrackBacks.", DEBUG_FULL )
				return true
			end

			# check only TrackBack
			return true unless comment.name == 'TrackBack'

			dest_uri = @conf.index.dup
			dest_uri[0, 0] = base_url if %r|^https?://|i !~ @conf.index
			dest_uri.gsub!( %r|/\./|, '/' )

			# TrackBack URI is the 1st line of comment.body.
			src_uri, = comment.body.split( /\n/ )
			unless %r|^https?://|i =~ src_uri then
				debug( "TrackBack has bad source URI." )
				comment.show = false
				return @filter_mode
			end
			if src_uri.index( dest_uri ) == 0 then
				debug( "TrackBack was sent to myself.", DEBUG_FULL )
				return true
			end

			begin
				Timeout::timeout( 10 ) do
	      		open( src_uri ) do |f|
						if f.read( 100 * 1024 ).include?( dest_uri ) then
							debug( "TrackBack has links to me.", DEBUG_FULL )
							return true
						else
							debug( "TrackBack dose not have links to me." )
							comment.show = false
							return @filter_mode
						end
					end
				end
			rescue Timeout::Error
				debug( "TrackBack source was no response." )
				comment.show = false
				return @filter_mode
			rescue
				debug( "Cannot access to TrackBack source (#{$!})." )
				comment.show = false
				return @filter_mode
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
