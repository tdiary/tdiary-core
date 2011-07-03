# -*- coding: utf-8; -*-
require 'stringio'

module TDiary
	class Dispatcher

		autoload :IndexMain,  'tdiary/dispatcher/index_main'
		autoload :UpdateMain, 'tdiary/dispatcher/update_main'

		TARGET = {
			:index => IndexMain,
			:update => UpdateMain
		}

		def initialize( target )
			@target = TARGET[target]
		end

		# FIXME rename method name to more suitable one.
		def dispatch_cgi( request, cgi = CGI.new )
			result = @target.run( request, cgi )
			result.headers.reject!{|k,v| k.to_s.downcase == "status" }
			result.to_a
		end

		class << self
			# stolen from Rack::Handler::CGI.send_headers
			def send_headers( status, headers )
				$stdout.print "Status: #{status}\r\n"
				begin
					$stdout.print CGI.new.header( headers )
				rescue EOFError
					charset = headers.delete( 'charset' )
					headers['Content-Type'] ||= headers.delete( 'type' )
					headers['Content-Type'] += "; charset=#{charset}" if charset
					$stdout.print headers.map{|k,v| "#{k}: #{v}\r\n"}.join << "\r\n"
				end
				$stdout.flush
			end

			# stolen from Rack::Handler::CGI.send_body
			def send_body( body )
				body.lines.each { |part|
					$stdout.print part
					$stdout.flush
				}
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
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
