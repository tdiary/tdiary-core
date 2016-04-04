require 'rack/file'

module TDiary
	module Rack
		class Static
			def initialize( app, base_dir )
				@app = app
				@file = ::Rack::File.new( base_dir )
			end

			def call( env )
				result = @file.call( env )
				if result[0].to_i >= 400 && result[0].to_i < 500
					@app.call( env )
				else
					result
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
