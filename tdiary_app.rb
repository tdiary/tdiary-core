# -*- coding: utf-8 -*-

require 'cgi'
require 'rack/request'
require 'rack/response'

$:.unshift( File::dirname( __FILE__ ).untaint )
require 'tdiary/dispatcher'

# FIXME too dirty hack :-<
class CGI
	def env_table_rack
		$RACK_ENV
	end

	alias :env_table_orig :env_table
	alias :env_table :env_table_rack
end

module Rack
	class TDiaryApp
		def initialize( target )
			@target = target
		end

		def call(env)
			adopt_rack_request_to_plain_old_tdiary_style(env)
			raw_result = dispatch_request
			convert_to_rack_response_from(raw_result)
		end

		private
		def fake_stdin_as_params
			stdin_spy = StringIO.new("")
			# FIXME dirty hack
			if $RACK_ENV && $RACK_ENV['rack.input']
				stdin_spy.print($RACK_ENV['rack.input'].read)
				stdin_spy.rewind
			end
			$stdin = stdin_spy
		end

		def adopt_rack_request_to_plain_old_tdiary_style(env)
			req = Request.new(env)
			$RACK_ENV = req.env
			env["rack.input"].rewind
			fake_stdin_as_params
		end

		def dispatch_request
			raw_result = StringIO.new
			dummy_stderr = StringIO.new
			dispatcher = TDiary::Dispatcher.__send__(@target)
			dispatcher.dispatch_cgi(CGI.new, raw_result, dummy_stderr)
			raw_result.rewind
			raw_result
		end

		def convert_to_rack_response_from(raw_result)
			res = ResponseHelper.parse(raw_result.read)
			STDOUT.puts res.body if $DEBUG
			return res.to_a
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
