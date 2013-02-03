# -*- coding: utf-8 -*-
require 'rack/request'

module TDiary
	module Rack
		class HtmlAnchor
			def initialize( app )
				@app = app
			end

			def call( env )
				if env['PATH_INFO'].match(/(.*\/)([0-9\-]+)(p(\d\d))?\.html$/)
					env["PATH_INFO"] = $1
					date = $2
					anchor = $4
					env["QUERY_STRING"] += "&" unless env["QUERY_STRING"].empty?
					env["QUERY_STRING"] += "date=#{date}"
					env["QUERY_STRING"] += "&p=#{anchor}" if anchor
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
