# -*- coding: utf-8 -*-

module TDiary
	module Rack
		class HtmlAnchor
			def initialize( app )
				@app = app
			end

			def call( env )
				if env['PATH_INFO'].match(/([0-9\-]+)\.html$/)
					env["QUERY_STRING"] += "&" unless env["QUERY_STRING"].empty?
					env["QUERY_STRING"] += "date=#{$1}"
				end
				@app.call( env )
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
