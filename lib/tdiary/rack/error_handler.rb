module TDiary
	module Rack
		#
		# class ErrorHandler
		#  catches exceptions leaked from the downstream app, reports the
		#  class, message and backtrace to rack.errors, and replaces the
		#  response with a plain 500 that does not expose the details to
		#  the client.
		#
		class ErrorHandler
			def initialize( app )
				@app = app
			end

			def call( env )
				@app.call( env )
			rescue Exception => e
				self.class.report( env['rack.errors'], e )
				[500, { 'content-type' => 'text/plain' }, ["500 Internal Server Error\n"]]
			end

			def self.report( errors, e )
				errors.puts "#{e.class}: #{e.message}"
				( e.backtrace || [] ).each {|line| errors.puts "\t#{line}" }
				errors.flush
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
