# -*- coding: utf-8 -*-

require File.expand_path('../environment', __FILE__)
Bundler.require :default if defined?(Bundler)
require 'tdiary'

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
			req = adopt_rack_request_to_plain_old_tdiary_style( env )
			dispatch_request( req )
		end

		private
		def adopt_rack_request_to_plain_old_tdiary_style( env )
			req = TDiary::Request.new( env )
			req.params # fill params to tdiary_request
			$RACK_ENV = req.env
			env["rack.input"].rewind
			fake_stdin_as_params
			req
		end

		def dispatch_request( request )
			dispatcher = TDiary::Dispatcher.__send__( @target )
			dispatcher.dispatch_cgi( request )
		end

		def fake_stdin_as_params
			stdin_spy = StringIO.new( "" )
			# FIXME dirty hack
			if $RACK_ENV && $RACK_ENV['rack.input']
				stdin_spy.print( $RACK_ENV['rack.input'].read )
				stdin_spy.rewind
			end
			$stdin = stdin_spy
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
