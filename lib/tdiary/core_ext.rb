require 'emot'

module TDiary
	# CGI-semantics readers shared by TDiary::Request and the CGICompat
	# facade (which forwards env to the request it wraps, so state memoized
	# in the env is visible through either object).
	module RequestExtension
		# backward compatibility, returns NOT mobile phone always
		def mobile_agent?
			false
		end

		# backward compatibility, returns NOT smartphone always
		def smartphone?
			false
		end

		# params with CGI semantics, unlike Rack::Request#params: POST reads
		# only the body, every value is an Array, unknown keys yield [],
		# duplicated keys collect all values, broken UTF-8 input is retried
		# as Shift_JIS and multipart uploads are normalized to their
		# tempfiles. Memoized so the request and its CGICompat facade (which
		# delegates here) share one Hash; plugins mutate it through
		# @cgi.params.
		def cgi_params
			@cgi_params ||= build_cgi_params
		end

		# single-value accessor over cgi_params; nil when the key is absent
		def param( key, idx = 0 )
			cgi_params[key][idx]
		end

		def valid?( param, idx = 0 )
			cgi_params[param] and cgi_params[param][idx] and cgi_params[param][idx].length > 0
		end

		# multi-value cookies, unlike Rack::Request#cookies: CGI::Cookie
		# splits each value on '&' (the tdiary cookie carries 'name&mail')
		def cgi_cookies
			@cgi_cookies ||= CGI::Cookie.parse( env['HTTP_COOKIE'] )
		end

		# TDiaryView hides the referer for the rest of the request when the
		# referer filters reject it; plugins observe nil through the @cgi
		# facade too, which delegates both methods to the request
		def hide_referer!
			@referer_hidden = true
		end

		def referer
			@referer_hidden ? nil : env['HTTP_REFERER']
		end

		def remote_addr
			env['REMOTE_ADDR']
		end

		def remote_user
			env['REMOTE_USER']
		end

		def https?
			return true if env['HTTP_X_FORWARDED_PROTO'] == 'https'
			return false if env['HTTPS'].nil? or /off/i =~ env['HTTPS'] or env['HTTPS'] == ''
			true
		end

		# not Rack::Request#base_url (scheme and host only): the CGI flavour
		# with the SCRIPT_NAME dirname and a trailing '/'
		def tdiary_base_url
			script_name = env['SCRIPT_NAME']
			return '' unless script_name
			begin
				script_dirname = script_name.empty? ? '' : File::dirname( script_name )
				server_name = env['SERVER_NAME']
				server_port = env['SERVER_PORT'].to_i
				if https?
					port = (server_port == 443) ? '' : ':' + server_port.to_s
					"https://#{server_name}#{port}#{script_dirname}/"
				else
					port = (server_port == 80) ? '' : ':' + server_port.to_s
					"http://#{server_name}#{port}#{script_dirname}/"
				end.sub(%r|/+$|, '/')
			rescue SecurityError
				''
			end
		end

	private

		def build_cgi_params
			source =
				if env['REQUEST_METHOD'] == 'POST'
					if %r|\Amultipart/form-data|.match?( env['CONTENT_TYPE'].to_s )
						self.POST
					else
						# Rack's nested query parser behind Rack::Request#POST keeps
						# only the last of duplicated keys; CGI collects all of them
						::Rack::Utils.parse_query( read_raw_body )
					end
				else
					::Rack::Utils.parse_query( env['QUERY_STRING'].to_s )
				end

			params = {}
			source.each do |key, value|
				values = value.kind_of?( Array ) ? value : [value]
				params[key] = values.map {|v| normalize_cgi_value( v ) }
			end
			params.default = []
			params
		end

		def read_raw_body
			input = env['rack.input']
			return '' unless input
			# Rack::Request#POST leaves rack.input at EOF, so rewind first in
			# case the request params were already parsed
			input.rewind if input.respond_to?( :rewind )
			body = input.read
			input.rewind if input.respond_to?( :rewind )
			body || ''
		end

		def normalize_cgi_value( value )
			if value.kind_of?( Hash ) and value[:tempfile]
				# Rack multipart file upload: expose an object responding to
				# read, which is all the consumers use
				value[:tempfile]
			else
				repair_encoding( value.to_s )
			end
		end

		# CGI/FCGI hosting retries broken UTF-8 input as Shift_JIS. The same
		# fallback is applied to each value: invalid UTF-8 is converted from
		# Shift_JIS when possible, otherwise scrubbed.
		def repair_encoding( str )
			str = str.dup.force_encoding( Encoding::UTF_8 ) unless str.encoding == Encoding::UTF_8
			return str if str.valid_encoding?
			begin
				str.dup.force_encoding( Encoding::Shift_JIS ).encode( Encoding::UTF_8 )
			rescue EncodingError
				str.scrub
			end
		end
	end
end

=begin
== String class
enhanced String class
=end
class String
	def make_link
		r = %r<(((http[s]{0,1}|ftp)://[\(\)%#!/0-9a-zA-Z_$@.&+-,'"*=;?:~-]+)|([0-9a-zA-Z_.-]+@[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+\.[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+))>
		return self.
			gsub( / /, "\001" ).
			gsub( /</, "\002" ).
			gsub( />/, "\003" ).
			gsub( /&/, '&amp;' ).
			gsub( /\"/, "\004").
			gsub( r ){ $1 == $2 ? "<a href=\"#$2\">#$2</a>" : "<a href=\"mailto:#$4\">#$4</a>" }.
			gsub( /\004/, '&quot;' ).
			gsub( /\003/, '&gt;' ).
			gsub( /\002/, '&lt;' ).
			gsub( /^\001+/ ) { $&.gsub( /\001/, '&nbsp;' ) }.
			gsub( /\001/, ' ' ).
			gsub( /\t/, '&nbsp;' * 8 )
	end

	def emojify
		self.to_str.gsub(/:([a-zA-Z0-9_+-]+):/) do |match|
			emoji_alias = $1.downcase
			emoji_url = %Q[<img src='//www.webpagefx.com/tools/emoji-cheat-sheet/graphics/emojis/%s.png' width='20' height='20' title='%s' alt='%s' class='emoji' />]
			if emoji_alias == 'plus1' or emoji_alias == '+1'
				emoji_url % (['plus1']*3)
			elsif Emot.unicode(emoji_alias)
				emoji_url % ([CGI.escape(emoji_alias)]*3)
			else
				match
			end
		end
	end
end

require 'tdiary/cgi_compat'

# the @cgi facade for Rack-hosted requests. Kept as a toplevel constant
# because plugins switch behaviour with @cgi.is_a?(RackCGI).
class RackCGI < TDiary::CGICompat; end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
