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
			result = @target.run( request )
			result.headers.reject!{|k,v| k.to_s.downcase == "status" }
			result.to_a
		end

		class << self
			# FIXME temporary method during (scratch) refactoring
			def extract_status_for_legacy_tdiary( head )
				status_str = head.delete('status')
				return 200 if !status_str || status_str.empty?

				if m = status_str.match(/(\d+)\s(.+)\Z/)
					m[1].to_i
				else
					200
				end
			end

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
