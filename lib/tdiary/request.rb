# stolen from okkez http://github.com/hiki/hiki/blob/rack/hiki/request.rb
module TDiary
	class Request < ::Rack::Request
		include RequestExtension

		# the @cgi object handed to plugins: a facade over this request.
		# Endpoints behind a web server (CGI/FCGI) set tdiary.static_assets in
		# the env to get the base CGICompat, so @cgi.is_a?(RackCGI) is false and
		# plugins keep the static js/theme URLs served by the web server.
		def cgi_compat
			@cgi_compat ||=
				if env['tdiary.static_assets']
					TDiary::CGICompat.new( self )
				else
					::RackCGI.new( self )
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
