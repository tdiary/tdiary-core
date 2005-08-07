# Copyright (C) 2005  akira yamada
# You can redistribute it and/or modify it under GPL2.

require 'uri'
require 'resolv'

module TDiary
	module Filter
		class SpamFilter < Filter
			TLD = %w(com net org edu gov mil int info biz name pro museum aero coop [a-z]{2})

			def initialize( *args )
				super( *args )
				@debug_mode = false
				@debug_file = nil
				@max_uris = nil
				@max_rate = nil
				@resolv_check = true
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
			end

			def update_config
				if @conf.options.include?('spamfilter.debug_mode')
					@debug_mode = @conf.options['spamfilter.debug_mode']
				else
					@debug_mode = false
				end

				if @conf.options.include?('spamfilter.debug_file')
					@debug_file = @conf.options['spamfilter.debug_file']
				else
					@debug_file = nil
				end

				if @conf.options.include?('spamfilter.max_uris')
					@max_uris = @conf.options['spamfilter.max_uris'].to_i
				else
					@max_uris = nil
				end

				if @conf.options.include?('spamfilter.max_rate')
					@max_rate = @conf.options['spamfilter.max_rate'].to_f
				else
					@max_rate = nil
				end

				if @conf.options.include?('spamfilter.resolv_check')
					@resolv_check = @conf.options['spamfilter.resolv_check']
				else
					@resolv_check = true
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
							%r<^[a-z]*://[^/]+\.(?!#{TLD.join('|')}\b)[^.]+(?:/|$)>i,
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
					@bad_mails = tmp.collect {|t| %r!#{t}! }
				end

				unless @conf.options.include?('spamfilter.bad_comment_patts')
					@conf.options['spamfilter.bad_comment_patts'] = ''
				end
				if @bad_comment_patts != @conf.options['spamfilter.bad_comment_patts']
					@bad_comment_patts = @conf.options['spamfilter.bad_comment_patts']
					tmp = @bad_comment_patts.split(/[\r\n]+/)
					tmp.delete_if {|t| t.empty?}
					@bad_comments = tmp.collect {|t| %r!#{t}! }
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
							%r!#{Regexp.quote(t[0..-2]) + '.*'}!
						else
							%r!#{Regexp.quote(t)}!
						end
					end
				end

				nil
			end

			def debug( msg )
				return unless @debug_mode
				require 'time'
				File.open(@debug_file, 'a') do |io|
					io.flock(File::LOCK_EX)
					io.puts "#{Time.now.iso8601}: #{ENV['REMOTE_ADDR']}: #{msg}"
				end
			end

			def comment_filter( diary, comment )
				update_config
				#debug( "comment_filter start" )

				if %r{/\.\/} =~ ENV['REQUEST_URI']
					debug( "REQUEST_URI contains %r{/\./}: #{ENV['REQUEST_URI']}" )
					comment.show = false
					return true
				end

				if /^[\x20-\x7f]*$/io !~ comment.mail
					# メールアドレスにASCII文字以外が含まれていた
					debug( "invalid mail address: #{comment.mail.dump}" )
					comment.show = false
					return true
				end

				p = nil
				if @bad_mails.detect {|p| p =~ comment.mail} ||
						@bad_mails_ext.detect {|p| p =~ comment.mail}
					# ブラックリストされたメールアドレス
					debug( "mail address blacklisted: /#{p}/ =~ #{comment.mail.dump}" )
					comment.show = false
					return true
				end

				if @bad_comments.detect {|p| p =~ comment.body}
					# NGワードを含んだコメント
					debug( "comment contains bad words: /#{p}/" )
					comment.show = false
					return true
				end
				
				if @bad_ips.detect {|p| p =~ @cgi.remote_addr}
					# ブラックリストされたIPアドレス
					debug( "ip address blacklisted: /#{p}/ =~ #{@cgi.remote_addr}" )
					comment.show = false
					return true
				end

				if comment.name == 'TrackBack'
					# トラックバックについてのチェック

					uri = comment.body.split(/[\r\n]/).first
					if %r!\A[^:]+://[^/]+/?\z! =~ uri
						# トップページからのTrackBackはなさそう
						debug( "trackback from top page: #{uri}" )
						comment.show = false
						return true
					end

					begin
						uri = URI.parse(uri)
						unless /\A(?:https?)\z/i =~ uri.scheme
							# HTTP(S)以外のURIだった
							debug( "not http/https: #{uri}" )
							comment.show = false
							return true
						end
					rescue URI::Error
						# URIとして解釈できなかった
						debug( "invalid URI: #{uri.dump} (#{$!.message})" )
						comment.show = false
						return true
					end

					if @resolv_check
						chance = 2
						begin
							addrs = Resolv.getaddresses(uri.host)

						rescue Resolv::ResolvTimeout, Resolv::ResolvError
							if chance > 0
								chance -= 1
								retry
							end
							# 名前解決上のエラー
							debug( "resolv error: #{uri.host.dump} (#{$!.message})" )
							comment.show = false
							return true
						rescue Exception
							# その他のエラー
							debug( "unknown resolv error: #{uri.host.dump} (#{$!.message})" )
							comment.show = false
							return true
						end

						if addrs.empty?
							# IPアドレスを得られなかった
							debug( "couldn't get addresses: #{uri.host}" )
							comment.show = false
							return true
						end

						unless addrs.include?(@cgi.remote_addr)
							unless /\A(.*[:.])/ =~ @cgi.remote_addr &&
									addrs.detect {|a| a.index($1) == 0}
									# webサイトのIPアドレスとTrackBack元のIPアドレスがマッチしない
								debug( "addresses don't match URI: #{uri.host}: #{addrs.join(', ')}" )
								comment.show = false
								return true
							end
						end
					end
				end

				if comment.name == 'TrackBack'
					comment_body = comment.body.sub(/\A[^\r\n]*/, '')
				else
					comment_body = comment.body
				end

				uris = URI.extract(comment_body)
				unless uris.empty?
					if @max_uris && @max_uris >= 0 && uris.size > @max_uris
						# コメント中のURIが多すぎる
						debug( "too many URIs" )
						comment.show = false
						return true
					end

					if @max_rate && @max_rate > 0 &&
							uris.join('').size.to_f/comment_body.gsub(/\s+/, '').size.to_f > @max_rate
						# コメントがURIでいっぱい
						debug( "too many URI-chars" )
						comment.show = false
						return true
					end

					uris.each do |uri|
						uri = uri.sub(/^ur[il]:/io, '')
						@bad_uris.each do |bad_uri|
							if bad_uri =~ uri
								# NGワードを含むURIが見付かった
								debug( "comment contains bad words: #{uri}: #{bad_uri}" )
								comment.show = false
								return true
							end
						end
					end
				end

				return true
			end

			def referer_filter( referer )
				return true unless referer

				update_config
				#debug( "referer_filter start" )

				if %r{\A[^:]+://[^/]*\z} =~ referer
					# パス部がまったくない
					debug( "referer has no path: #{uri}: #{bad_uri}" )
					return false
				end

				@bad_uris.each do |bad_uri|
					if bad_uri =~ referer
						# NGワードを含むURIが見付かった
						debug( "referer contains bad words: #{uri}: #{bad_uri}" )
						return false
					end
				end

				return true
			end
		end
	end
end

# vim: ts=3
