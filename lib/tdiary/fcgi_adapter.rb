require 'stringio'

module TDiary
	#
	# class FCGIAdapter
	#  bridges FastCGI requests to the Rack interface: builds a Rack env
	#  from an FCGI request and writes the Rack response triplet back to
	#  it. The request is duck-typed (env/in/out/err/finish) so that this
	#  file works without the fcgi gem.
	#
	class FCGIAdapter
		class << self
			def run( request, dispatcher )
				env = build_env( request.env.to_hash, request.in, request.err )
				write_response( request.out, *dispatcher.call( env ) )
			rescue Exception => e
				write_error( request.out, e )
			ensure
				request.finish
			end

			def build_env( fcgi_env, input, errors )
				env = fcgi_env.to_hash.dup
				env.delete( 'HTTP_CONTENT_LENGTH' )
				env['SCRIPT_NAME'] = '' if env['SCRIPT_NAME'] == '/'
				env['QUERY_STRING'] ||= ''
				env['rack.input'] = StringIO.new( (input.read || '').b )
				env['rack.errors'] = errors
				env['rack.url_scheme'] = url_scheme( env )
				# tell Request#cgi_compat that js/theme are served statically
				# by the web server, not by the Rack app
				env['tdiary.cgi_hosting'] = true
				env
			end

			def write_response( out, status, headers, body )
				out.print "Status: #{status}\r\n"
				headers.each do |key, value|
					Array( value ).each do |v|
						v.to_s.split( "\n" ).each do |line|
							out.print "#{key}: #{line}\r\n"
						end
					end
				end
				out.print "\r\n"
				body.each {|part| out.print part }
			ensure
				body.close if body.respond_to?( :close )
			end

		private

			def url_scheme( env )
				if %w(yes on 1).include?( env['HTTPS'].to_s.downcase ) || env['HTTP_X_FORWARDED_PROTO'] == 'https'
					'https'
				else
					'http'
				end
			end

			def write_error( out, e )
				body = "<h1>500 Internal Server Error</h1>\n<pre>#{CGI::escapeHTML( "#{e} (#{e.class})\n\n#{e.backtrace.join( "\n" )}" )}</pre>\n"
				write_response( out, 500, { 'content-type' => 'text/html' }, [body] )
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
