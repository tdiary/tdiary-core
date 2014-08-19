# -*- coding: utf-8 -*-
# stolen from okkez http://github.com/hiki/hiki/blob/rack/hiki/request.rb
module TDiary
	class Request < ::Rack::Request
		include RequestExtension

		attr_reader :env, :cgi

		def initialize( env, cgi = nil )
			@env = env
			@cgi = cgi
		end

		def params
			if @cgi
				return @params if @params
				@params = { }
				@cgi.params.each{|k, v|
					v = v.uniq
					case v.size
					when 0
						@params[k] = nil
					when 1
						@params[k] = v[0]
					else
						@params[k] = v
					end
				}
				@params
			else
				super
			end
		end

		def []( key )
			if @cgi
				params[key.to_s]
			else
				super
			end
		end

		def []=( key, val )
			if @cgi
				params[key.to_s] = val
			else
				super
			end
		end

		def request_method
			if @cgi
				@env['REQUEST_METHOD']
			else
				super
			end
		end

		def header( header )
			if @cgi
				@cgi.header( header )
			else
				super
			end
		end

		def get?
			if @cgi
				request_method == 'GET'
			else
				super
			end
		end

		def head?
			if @cgi
				request_method == 'HEAD'
			else
				super
			end
		end

		def post?
			if @cgi
				request_method == 'POST'
			else
				super
			end
		end

		def put?
			if @cgi
				request_method == 'PUT'
			else
				super
			end
		end

		def delete?
			if @cgi
				request_method == 'DELETE'
			else
				super
			end
		end

		def xhr?
			if @cgi
				@env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
			else
				super
			end
		end

		def accept_encoding
			if @cgi
				raise NameError, 'not implemented : accept_encoding'
			else
				super
			end
		end

		def body
			if @cgi
				raise NameError, 'not implemented : body'
			else
				super
			end
		end

		def content_charset
			if @cgi
				@env['CONTENT_CHARSET']
			else
				super
			end
		end

		def content_length
			if @cgi
				@env['CONTENT_LENGTH']
			else
				super
			end
		end

		def content_type
			if @cgi
				@env['CONTENT_TYPE']
			else
				super
			end
		end

		def remote_addr
			if @cgi
				@env['REMOTE_ADDR']
			else
				super
			end
		end

		def cookies
			if @cgi
				return @cookies if @cookies
				@cookies = { }
				@cgi.cookies.each{|k, v|
					case v.size
					when 0
						@cookies[k] = nil
					when 1
						@cookies[k] = v[0]
					else
						@cookies[k] = v
					end
				}
				@cookies
			else
				super
			end
		end

		def form_data?
			if @cgi
				raise NameError, 'not implemented : form_data?'
			else
				super
			end
		end

		def fullpath
			if @cgi
				raise NameError, 'not implemented : fullpath'
			else
				super
			end
		end

		def host
			if @cgi
				# Remove port number.from Rack::Response
				( @env["HTTP_HOST"] || @env["SERVER_NAME"] ).gsub( /:\d+\z/, '' )
			else
				super
			end
		end

		def ip
			if @cgi
				raise NameError, 'not implemented : ip'
			else
				super
			end
		end
		alias remote_addr ip

		def media_type
			if @cgi
				raise NameError, 'not implemented : madia_type'
			else
				super
			end
		end

		def media_type_params
			if @cgi
				raise NameError, 'not implemented : media_type_params'
			else
				super
			end
		end

		def openid_request
			if @cgi
				raise NameError, 'not implemented : openid_request'
			else
				super
			end
		end

		def openid_response
			if @cgi
				raise NameError, 'not implemented : openid_response'
			else
				super
			end
		end

		def parseable_data?
			if @cgi
				raise NameError, 'not implemented : parseable_data?'
			else
				super
			end
		end

		def path
			if @cgi
				raise NameError, 'not implemented : path'
			else
				super
			end
		end

		def path_info
			if @cgi
				raise NameError, 'not implemented : path'
			else
				super
			end
			w		end

		def path_info=( s )
			if @cgi
				raise NameError, 'not implemented : path_info='
			else
				super
			end
		end

		def port
			if @cgi
				raise NameError, 'not implemented : port'
			else
				super
			end
		end

		def query_string
			if @cgi
				raise NameError, 'not implemented : query_string'
			else
				super
			end
		end

		def referer
			if @cgi
				raise NameError, 'not implemented : referer'
			else
				super
			end
		end
		alias referrer referer

		def schema
			if @cgi
				raise NameError, 'not implemented : schema'
			else
				super
			end
		end

		def script_name
			if @cgi
				@env['SCRIPT_NAME']
			else
				super
			end
		end

		def session_options
			if @cgi
				raise NameError, 'not implemented : session_options'
			else
				super
			end
		end

		def url
			if @cgi
				raise NameError, 'not implemented : url'
			else
				super
			end
		end

		def user_agent
			if @cgi
				@cgi.user_agent
			else
				super
			end
		end

		def base_url
			if @cgi
				@cgi.base_url
			else
				super
			end
		end

		def values_at( *keys )
			if @cgi
				raise NameError, 'not implemented : values_at'
			else
				super
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
