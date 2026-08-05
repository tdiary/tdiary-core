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
			main = @target.new( request )
			response = main.run
			apply_security_headers( response, request, main.conf )
			response.to_a
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

		def apply_security_headers( response, request, conf )
			response.set_header( 'x-content-type-options', 'nosniff' )
			apply_frame_restrictions( response, conf )
			response.set_header( 'referrer-policy', conf.referrer_policy ) if conf.referrer_policy
			response.set_header( 'strict-transport-security', conf.hsts ) if conf.hsts && request.ssl?
		end

		# The update target is an authenticated admin UI and always forbids
		# cross-origin framing; the index target follows conf.x_frame_options.
		# CSP frame-ancestors is the standard control, X-Frame-Options is kept
		# alongside for legacy user agents.
		def apply_frame_restrictions( response, conf )
			if @target == UpdateMain
				response.set_header( 'content-security-policy', "frame-ancestors 'self'" )
				response.set_header( 'x-frame-options', 'SAMEORIGIN' )
			elsif conf.x_frame_options
				ancestors = case conf.x_frame_options.upcase
								when 'SAMEORIGIN' then "'self'"
								when 'DENY' then "'none'"
								end
				response.set_header( 'content-security-policy', "frame-ancestors #{ancestors}" ) if ancestors
				response.set_header( 'x-frame-options', conf.x_frame_options )
			end
		end

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
