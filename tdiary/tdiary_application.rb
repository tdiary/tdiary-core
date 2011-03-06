# -*- coding: utf-8 -*-

require File.expand_path('../environment', __FILE__)
Bundler.require :default if defined?(Bundler)
require 'rack/request'
require 'rack/response'

require 'tdiary/dispatcher'

# FIXME too dirty hack :-<
class CGI
	def env_table_rack
		$RACK_ENV
	end

	alias :env_table_orig :env_table
	alias :env_table :env_table_rack
end

module TDiary
	class Application
		def initialize( target )
			@target = target
		end

		def call( env )
			adopt_rack_request_to_plain_old_tdiary_style( env )
			dispatch_request
		end

		private
		def fake_stdin_as_params
			stdin_spy = StringIO.new( "" )
			# FIXME dirty hack
			if $RACK_ENV && $RACK_ENV['rack.input']
				stdin_spy.print( $RACK_ENV['rack.input'].read )
				stdin_spy.rewind
			end
			$stdin = stdin_spy
		end

		def adopt_rack_request_to_plain_old_tdiary_style( env )
			req = Rack::Request.new( env )
			$RACK_ENV = req.env
			env["rack.input"].rewind
			fake_stdin_as_params
		end

		def dispatch_request
			dispatcher = TDiary::Dispatcher.__send__( @target )
			dispatcher.dispatch_cgi( CGI.new )
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
