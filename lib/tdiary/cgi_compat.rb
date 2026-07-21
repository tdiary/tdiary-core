module TDiary
	#
	# class CGICompat
	#  provides the CGI compatible interface consumed by plugins as @cgi on
	#  top of TDiary::Request. Behaviour is locked by the shared examples in
	#  spec/support/cgi_compat_shared_examples.rb, which are also applied to
	#  RackCGI, the subclass the dispatcher hands to plugins on the Rack path.
	#
	class CGICompat
		include TDiary::RequestExtension

		attr_reader :request

		def initialize( request )
			@request = request
			# built eagerly so that a clone (Object#clone copies instance
			# variables by reference) shares the same params Hash, like a
			# cloned CGI instance does. Plugins may still rely on this.
			@params = build_params
		end

		attr_reader :params

		def valid?( param, idx = 0 )
			params[param] and params[param][idx] and params[param][idx].length > 0
		end

		def cookies
			# CGI::Cookie keeps the multi-value cookie behaviour (00default.rb
			# reads name and mail from the two values of the tdiary cookie)
			@cookies ||= CGI::Cookie.parse( env_table['HTTP_COOKIE'] )
		end

		def env_table
			@request.env
		end

		def referer
			env_table['HTTP_REFERER']
		end

		def user_agent
			env_table['HTTP_USER_AGENT']
		end

		def remote_addr
			env_table['REMOTE_ADDR']
		end

		def request_method
			env_table['REQUEST_METHOD']
		end

		def script_name
			env_table['SCRIPT_NAME']
		end

		def remote_user
			env_table['REMOTE_USER']
		end

		def auth_type
			env_table['AUTH_TYPE']
		end

		def gateway_interface
			env_table['GATEWAY_INTERFACE']
		end

		def server_name
			env_table['SERVER_NAME']
		end

		def server_port
			env_table['SERVER_PORT'].to_i
		end

		# the URL helpers below duplicate the CGI patches in core_ext.rb,
		# which stay there for standalone scripts (misc/migrate.rb etc.)
		def https?
			return true if env_table['HTTP_X_FORWARDED_PROTO'] == 'https'
			return false if env_table['HTTPS'].nil? or /off/i =~ env_table['HTTPS'] or env_table['HTTPS'] == ''
			true
		end

		def request_uri
			_request_uri = env_table['REQUEST_URI']
			_script_name = env_table['SCRIPT_NAME']
			if !_request_uri || _request_uri == '' || _request_uri == _script_name then
				_path_info    = env_table['PATH_INFO'] || ''
				_query_string = env_table['QUERY_STRING'] || ''
				# Workaround for IIS-style PATH_INFO ('/dir/script.cgi/path', not '/path')
				# See http://support.microsoft.com/kb/184320/
				_request_uri = _path_info.include?(_script_name) ? '' : _script_name.dup
				_request_uri << _path_info
				_request_uri << '?' + _query_string if _query_string != ''
			end
			_request_uri
		end

		def redirect_url
			env_table['REDIRECT_URL']
		end

		def base_url
			return '' unless script_name
			begin
				script_dirname = script_name.empty? ? '' : File::dirname(script_name)
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

		def build_params
			source =
				if request_method == 'POST'
					if %r|\Amultipart/form-data|.match?( env_table['CONTENT_TYPE'].to_s )
						@request.POST
					else
						# Rack's nested query parser behind request.POST keeps only
						# the last of duplicated keys; CGI collects all of them
						::Rack::Utils.parse_query( read_raw_body )
					end
				else
					::Rack::Utils.parse_query( env_table['QUERY_STRING'].to_s )
				end

			params = {}
			source.each do |key, value|
				values = value.kind_of?( Array ) ? value : [value]
				params[key] = values.map {|v| normalize_value( v ) }
			end
			params.default = []
			params
		end

		def read_raw_body
			input = env_table['rack.input']
			return '' unless input
			# Rack::Request#POST leaves rack.input at EOF, so rewind first in
			# case the request params were already parsed
			input.rewind if input.respond_to?( :rewind )
			body = input.read
			input.rewind if input.respond_to?( :rewind )
			body || ''
		end

		def normalize_value( value )
			if value.kind_of?( Hash ) and value[:tempfile]
				# Rack multipart file upload: expose an object responding to
				# read, which is all the consumers use
				value[:tempfile]
			else
				repair_encoding( value.to_s )
			end
		end

		# CGI/FCGI hosting retries broken UTF-8 input as Shift_JIS (index.rb,
		# misc/lib/fcgi_patch.rb). The facade implements the same fallback on
		# each value: invalid UTF-8 is converted from Shift_JIS when possible,
		# otherwise scrubbed.
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

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
