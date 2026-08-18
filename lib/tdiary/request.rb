# stolen from okkez http://github.com/hiki/hiki/blob/rack/hiki/request.rb
module TDiary
	class Request < ::Rack::Request
		include RequestExtension

		# the @cgi object handed to plugins: a facade over this request.
		# Endpoints behind a web server (CGI/FCGI) set tdiary.static_assets in
		# the env to get the base CGICompat. The RackCGI/CGICompat split only
		# serves third-party plugins that check @cgi.is_a?(RackCGI); in-repo
		# code reads the flag through RequestExtension#static_assets?.
		def cgi_compat
			@cgi_compat ||=
				if env['tdiary.static_assets']
					TDiary::CGICompat.new( self )
				else
					::RackCGI.new( self )
				end
		end

	private

		# CGI splits the query string on ';' as well as '&', and tDiary's own
		# edit links (00default.rb, edit_today.rb) still use ';'; Rack 3
		# dropped the ';' separator, so restore it for Rack::Request#params
		def parse_query( qs, d = '&' )
			super( qs, '&;' )
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
