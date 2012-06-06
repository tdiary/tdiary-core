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
					%r{^/([0-9\-]+)\.html$}
				]
				valid_paths.each do |path|
					return @app.call(env) if env['PATH_INFO'].match(path)
				end
				[404, {'Content-Type' => 'text-plain'}, ["Not Found: #{env['PATH_INFO']}"]]
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
