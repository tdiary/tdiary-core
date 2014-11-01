# -*- coding: utf-8; -*-
# Copyright (C) 2005  akira yamada
# You can redistribute it and/or modify it under GPL2 or any later version.

require 'uri'
require 'resolv'
require 'socket'
require 'timeout'

module TDiary
	module Filter
		class SpamFilter < Filter
			TLD = %w(com net org edu gov mil int info biz name pro museum aero coop [a-z]{2})

			def initialize( *args )
				super( *args )
				@filter_mode = true
				@max_uris = nil
				@max_rate = nil
				@bad_uri_patts_for_mails = false

				@bad_uri_patts = nil
				@bad_mail_patts = nil
				@bad_comment_patts = nil
				@bad_ip_addrs = nil

				@bad_uris = []
				@bad_mails_ext = []
				@bad_mails = []
				@bad_comments = []
				@bad_ips = []

				@date_limit = nil
			end

			def update_config
				if @conf.options.include?('spamfilter.filter_mode')
					if @conf.options['spamfilter.filter_mode']
						@filter_mode = true # invisible
					else
						@filter_mode = false # drop
					end
				else
					@filter_mode = true # invisible
				end

				if @conf.options.include?('spamfilter.max_uris')
					@max_uris = @conf.options['spamfilter.max_uris'].to_i
				else
					@max_uris = nil
				end

				if @conf.options.include?('spamfilter.max_rate')
					@max_rate = @conf.options['spamfilter.max_rate'].to_i
				else
					@max_rate = nil
				end

				if @conf.options.include?('spamlookup.ip.list')
					@spamlookup_ip_list = @conf.options['spamlookup.ip.list']
				else
					@spamlookup_ip_list = "dnsbl.spam-champuru.livedoor.com"
				end

				if @conf.options.include?('spamlookup.domain.list')
					@spamlookup_domain_list = @conf.options['spamlookup.domain.list']
				else
					@spamlookup_domain_list = "bsb.spamlookup.net\nsc.surbl.org\nrbl.bulkfeeds.jp"
				end

				if @conf.options.include?('spamlookup.safe_domain.list')
					@spamlookup_safe_domain_list = @conf.options['spamlookup.safe_domain.list']
				else
					@spamlookup_safe_domain_list = "www.google.com\nwww.google.co.jp\nsearch.yahoo.co.jp\nwww.bing.com"
				end

				if @conf.options.include?('spamfilter.bad_uri_patts_for_mails')
					@bad_uri_patts_for_mails =
							@conf.options['spamfilter.bad_uri_patts_for_mails']
				else
					@bad_uri_patts_for_mails = false
				end
				unless @bad_uri_patts_for_mails
					@bad_mails_ext = []
				end

				unless @conf.options.include?('spamfilter.bad_uri_patts')
					@conf.options['spamfilter.bad_uri_patts'] = ''
				end
				if @bad_uri_patts != @conf.options['spamfilter.bad_uri_patts']
					@bad_uri_patts = @conf.options['spamfilter.bad_uri_patts']
					tmp = @bad_uri_patts.split(/[\r\n]+/)
					tmp.delete_if {|t| t.empty?}
					if tmp.empty?
						@bad_uris = []
						@bad_mails_ext = []
					else
						@bad_uris = [
							%r!^[a-z]*://(?:[^/]*(?:#{tmp.join('|')})){2}!i,
							%r!^[a-z]*://[^/]*\b(?:#{tmp.join('|')})!i,
							%r!^[a-z]*://[^/]*(?:#{tmp.join('|')})\b!i,
							%r!^[a-z]*://.*\b(?:#{tmp.join('|')})\b!i,
							%r!^[a-z]*://[^/]*?[^./]{20,}[^/]*/?$!i,
							%r!^[a-z]*://[^/.]+(?:/|$)!i,
							%r<^[a-z]*://[^/]+\.(?!(?:#{TLD.join("|")})\b\.?)[^.:/]+(?:\.?(?::\d+)?(?:/|$))>i,
						]
						if @bad_uri_patts_for_mails
							@bad_mails_ext = [
								%r!\b(?:#{tmp.join('|')})!i,
								%r!(?:#{tmp.join('|')})\b!i,
							]
						end
					end
				end

				unless @conf.options.include?('spamfilter.bad_mail_patts')
					@conf.options['spamfilter.bad_mail_patts'] = ''
				end
				if @bad_mail_patts != @conf.options['spamfilter.bad_mail_patts']
					@bad_mail_patts = @conf.options['spamfilter.bad_mail_patts']
					tmp = @bad_mail_patts.split(/[\r\n]+/)
					tmp.delete_if {|t| t.empty?}
					@bad_mails = tmp.collect {|t| %r!#{t}!i rescue nil}.compact
				end

				unless @conf.options.include?('spamfilter.bad_comment_patts')
					@conf.options['spamfilter.bad_comment_patts'] = ''
				end
				if @bad_comment_patts != @conf.options['spamfilter.bad_comment_patts']
					@bad_comment_patts = @conf.options['spamfilter.bad_comment_patts']
					tmp = @bad_comment_patts.split(/[\r\n]+/)
					tmp.delete_if {|t| t.empty?}
					@bad_comments = tmp.collect {|t| %r!#{t}!i rescue nil}.compact
				end

				unless @conf.options.include?('spamfilter.bad_ip_addrs')
					@conf.options['spamfilter.bad_ip_addrs'] = ''
				end
				if @bad_ip_addrs != @conf.options['spamfilter.bad_ip_addrs']
					@bad_ip_addrs = @conf.options['spamfilter.bad_ip_addrs']
					tmp = @bad_ip_addrs.split(/[\r\n]+/)
					tmp.delete_if {|t| t.empty?}
					@bad_ips = tmp.collect do |t|
						if /\.$/ =~ t
							%r!#{Regexp.quote(t[0..-2]) + '.*'}!i
						else
							%r!#{Regexp.quote(t)}!i
						end
					end
				end

				nil
			end

			def name_base_black_domain?( domain )
				@spamlookup_domain_list.split(/[\n\r]+/).inject(false) do |r, dnsbl|
					r || lookup(domain, dnsbl)
				end
			end

			def ip_base_black_domain?( domain )
				@spamlookup_ip_list.split(/[\n\r]+/).inject(false) do |r, dnsbl|
					r || lookup(domain, dnsbl, true)
				end
			end

			def lookup(domain, dnsbl, iplookup = false)
				timeout(5) do
					domain = IPSocket::getaddress( domain ).split(/\./).reverse.join(".") if iplookup
					address = Resolv.getaddress( "#{domain}.#{dnsbl}" )
					debug("lookup:#{domain}.#{dnsbl} address:#{address}: spam host.")
					return true
				end
			rescue TimeoutError, Resolv::ResolvTimeout
				debug("lookup:#{domain}.#{dnsbl}: safe host.")
				return false
			rescue Resolv::ResolvError, Exception
				debug("unknown error:#{domain}.#{dnsbl}", DEBUG_FULL)
				return false
			end

			def black_url?( body )
				body.scan( %r|https?://([^/:\s]+)| ) do |s|
					if @spamlookup_safe_domain_list.include?( s[0] )
						debug("#{s[0]} is safe host.", DEBUG_FULL)
						next
					end
					return true if name_base_black_domain?( s[0] ) || ip_base_black_domain?( s[0] )
				end
				return false
			end

			def comment_filter( diary, comment )
				update_config

				return false if black_url?( comment.body )

				if %r{/\.\/} =~ ENV['REQUEST_URI']
					debug( "REQUEST_URI contains %r{/\./}: #{ENV['REQUEST_URI']}" )
					comment.show = false
					return @filter_mode
				end

				if /^[\x20-\x7f]*$/io !~ comment.mail
					# mail address include not ASCII charactor
					debug( "invalid mail address: #{comment.mail.dump}" )
					comment.show = false
					return @filter_mode
				end

				if !comment.mail.empty? &&
						%r<@[^@]+\.(?:#{TLD.join("|")})$>i !~ comment.mail
					debug( "invalid domain name of mail address: #{comment.mail.dump}" )
					comment.show = false
					return @filter_mode
				end

				p = nil
				if @bad_mails.detect {|p| p =~ comment.mail} ||
						@bad_mails_ext.detect {|p| p =~ comment.mail}
					debug( "mail address blacklisted: /#{p}/ =~ #{comment.mail.dump}" )
					comment.show = false
					return @filter_mode
				end

				if @bad_comments.detect {|p| p =~ comment.body}
					debug( "comment contains bad words: /#{p}/" )
					comment.show = false
					return @filter_mode
				end

				if @bad_ips.detect {|p| p =~ @cgi.remote_addr}
					debug( "ip address blacklisted: /#{p}/ =~ #{@cgi.remote_addr}" )
					comment.show = false
					return @filter_mode
				end

				uris = URI.extract( comment.body, %w(http https ftp mailto) )
				unless uris.empty?
					if @max_uris && @max_uris >= 0 && uris.size > @max_uris
						debug( "too many URIs" )
						comment.show = false
						return @filter_mode
					end

					if @max_rate && @max_rate > 0 &&
							uris.join('').size * 100 / comment.body.gsub(/\s+/, '').size > @max_rate
						debug( "too many URI-chars" )
						comment.show = false
						return @filter_mode
					end

					uris.each do |uri|
						uri = uri.sub(/^ur[il]:/io, '')
						@bad_uris.each do |bad_uri|
							if bad_uri =~ uri
								debug( "comment contains bad words: #{uri}: #{bad_uri}" )
								comment.show = false
								return @filter_mode
							end
						end
					end
				end

				return true
			end

			def referer_filter( referer )
				return true unless referer

				update_config

				return false if black_url?( referer )

				if /#/ =~ referer then
					debug( "referer has a fragment: #{referer}" )
					return false
				end

				if %r{\A[^:]+://[^/]*\z} =~ referer
					debug( "referer has no path: #{referer}" )
					return false
				end

				@bad_uris.each do |bad_uri|
					if bad_uri =~ referer
						debug( "referer contains bad words: #{referer}: #{bad_uri}" )
						return false
					end
				end

				return true
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
# vim: ts=3
