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
			req = adopt_rack_request_to_plain_old_tdiary_style( env )
			dispatch_cgi(req, RackCGI.new)
		end

		# FIXME rename method name to more suitable one.
		def dispatch_cgi(request, cgi)
			result = @target.run( request, cgi )
			result.headers.reject!{|k,v| k.to_s.downcase == "status" }
			result.to_a
		end

		class << self
			# stolen from Rack::Handler::CGI.send_headers
			def send_headers(status, headers)
				begin
					headers['type'] = headers.delete('content-type')
					$stdout.print CGI.new.header({'Status'=>status}.merge(headers))
				rescue EOFError
					charset = headers.delete('charset')
					headers['content-type'] ||= headers.delete( 'type' )
					headers['content-type'] += "; charset=#{charset}" if charset
					$stdout.print headers.map{|k,v| "#{k}: #{v}\r\n"}.join << "\r\n"
				end
				$stdout.flush
			end

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
			body = env["rack.input"].read
			env["rack.input"] = StringIO.new(body)
			req = TDiary::Request.new( env )
			req.params # fill params to tdiary_request
			$RACK_ENV = req.env
			fake_stdin_as_params(body)
			req
		end

		# FIXME dirty hack
		def fake_stdin_as_params(body)
			$stdin = StringIO.new(body)
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
