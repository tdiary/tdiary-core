# -*- coding: utf-8 -*-
# stolen from okkez http://github.com/hiki/hiki/blob/rack/hiki/request.rb
module TDiary
	if Object.const_defined?( :Rack )
		Request = ::Rack::Request
		class ::Rack::Request
			alias remote_addr ip
		end
		Request.class_eval { include RequestExtension }
	else
		raise RuntimeError, 'Do not use CGI class!' if Object.const_defined?( :Rack )
		# CGI を Rack::Request っぽいインターフェイスに変換する
		class Request
			include RequestExtension

			attr_reader :env, :cgi
			def initialize( env, cgi = CGI.new )
				@cgi = cgi
				@env = env
			end

			def params
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
			end

			def []( key )
				params[key.to_s]
			end

			def []=( key, val )
				params[key.to_s] = val
			end

			def request_method
				@env['REQUEST_METHOD']
			end

			def header( header )
				@cgi.header( header )
			end

			def get?
				request_method == 'GET'
			end

			def head?
				request_method == 'HEAD'
			end

			def post?
				request_method == 'POST'
			end

			def put?
				request_method == 'PUT'
			end

			def delete?
				request_method == 'DELETE'
			end

			def xhr?
				raise NameError, 'not implemented : xhr?'
			end

			def accept_encoding
				raise NameError, 'not implemented : accept_encoding'
			end

			def body
				raise NameError, 'not implemented : body'
			end

			def content_charset
				@env['CONTENT_CHARSET']
			end

			def content_length
				@env['CONTENT_LENGTH']
			end

			def content_type
				@env['CONTENT_TYPE']
			end

			def remote_addr
				@env['REMOTE_ADDR']
			end

			def cookies
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
			end

			def form_data?
				raise NameError, 'not implemented : form_data?'
			end

			def fullpath
				raise NameError, 'not implemented : fullpath'
			end

			def host
				# Remove port number.from Rack::Response
				( @env["HTTP_HOST"] || @env["SERVER_NAME"] ).gsub( /:\d+\z/, '' )
			end

			def ip
				raise NameError, 'not implemented : ip'
			end

			def media_type
				raise NameError, 'not implemented : madia_type'
			end

			def media_type_params
				raise NameError, 'not implemented : media_type_params'
			end

			def openid_request
				raise NameError, 'not implemented : openid_request'
			end

			def openid_response
				raise NameError, 'not implemented : openid_response'
			end

			def parseable_data?
				raise NameError, 'not implemented : parseable_data?'
			end

			def path
				raise NameError, 'not implemented : path'
			end

			def path_info
				@env['PATH_INFO'].to_s
			end

			def path_info=( s )
				raise NameError, 'not implemented : path_info='
			end

			def port
				raise NameError, 'not implemented : port'
			end

			def query_string
				raise NameError, 'not implemented : query_string'
			end

			def referer
				raise NameError, 'not implemented : referer'
			end
			alias referrer referer

			def schema
				raise NameError, 'not implemented : schema'
			end

			def script_name
				@env['SCRIPT_NAME']
			end

			def session_options
				raise NameError, 'not implemented : session_options'
			end

			def url
				raise NameError, 'not implemented : url'
			end

			def user_agent
				@cgi.user_agent
			end

			def values_at( *keys )
				raise NameError, 'not implemented : values_at'
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
