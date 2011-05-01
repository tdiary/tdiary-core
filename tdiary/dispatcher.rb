# -*- coding: utf-8; -*-

require 'stringio'
require 'tdiary'
require 'tdiary/tdiary_response'

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

		def dispatch_cgi( cgi = CGI.new, raw_result = StringIO.new, dummy_stderr = StringIO.new )
			stdout_orig = $stdout; stderr_orig = $stderr
			begin
				$stdout = raw_result; $stderr = dummy_stderr
				result = @target.run( cgi )
				result.headers.reject!{|k,v| k.to_s.downcase == "status" }
				result.to_a
			ensure
				$stdout = stdout_orig
				$stderr = stderr_orig
			end
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
			def extract_status_for_legacy_tdiary( status_str )
				return 200 unless status_str
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
