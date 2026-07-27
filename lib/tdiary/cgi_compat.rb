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
			@params = request.cgi_params
		end

		attr_reader :params

		# the env of the wrapped request, for the stateless RequestExtension
		# readers (remote_addr, https?, tdiary_base_url, ...)
		def env
			@request.env
		end

		# the stateful RequestExtension readers delegate to the wrapped
		# request, so core code reading the request directly sees the same
		# params Hash and the same hidden-referer state as plugins do
		# through this facade
		def cgi_params
			@request.cgi_params
		end

		def cgi_cookies
			@request.cgi_cookies
		end

		def hide_referer!
			@request.hide_referer!
		end

		def referer
			@request.referer
		end

		def cookies
			# CGI::Cookie keeps the multi-value cookie behaviour (00default.rb
			# reads name and mail from the two values of the tdiary cookie)
			cgi_cookies
		end

		def env_table
			@request.env
		end

		def user_agent
			env_table['HTTP_USER_AGENT']
		end

		def request_method
			env_table['REQUEST_METHOD']
		end

		def script_name
			env_table['SCRIPT_NAME']
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

		# the URL helpers below come from the CGI patches that used to live
		# in core_ext.rb
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
			tdiary_base_url
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
