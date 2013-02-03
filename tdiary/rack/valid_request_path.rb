# -*- coding: utf-8 -*-

module TDiary
	module Rack
		class ValidRequestPath
			def initialize( app )
				@app = app
			end

			def call( env )
				valid_paths = [
					%r{^/$},
					%r{^/index\.(rb|cgi)$},
					%r{^/([0-9\-p]+)\.html$}
				]
				valid_paths.each do |path|
					return @app.call(env) if env['PATH_INFO'].match(path)
				end

				body = "Not Found: #{env['PATH_INFO']}"
				if env["REQUEST_METHOD"] == "HEAD"
					[404, {'Content-Type' => 'text/plain', 'Content-Length' => body.length.to_s}, []]
				else
					[404, {'Content-Type' => 'text/plain'}, [body]]
				end
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
