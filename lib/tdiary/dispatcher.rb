require 'stringio'

module TDiary
	class Dispatcher

		autoload :IndexMain,  'tdiary/dispatcher/index_main'
		autoload :UpdateMain, 'tdiary/dispatcher/update_main'

		TARGET = {
			index: IndexMain,
			update: UpdateMain
		}

		def initialize( target )
			@target = TARGET[target]
		end

		def call( env )
			request = adopt_rack_request_to_plain_old_tdiary_style( env )
			@target.run( request ).to_a
		end

		class << self
			def index
				new( :index )
			end

			def update
				new( :update )
			end

			private :new
		end

	private

		def adopt_rack_request_to_plain_old_tdiary_style( env )
			# rebuffer rack.input into a rewindable StringIO; both
			# Rack::Request and CGICompat read the body from it
			body = env["rack.input"]&.read || ""
			env["rack.input"] = StringIO.new(body)
			req = TDiary::Request.new( env )
			req.params # fill params to tdiary_request
			req
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
