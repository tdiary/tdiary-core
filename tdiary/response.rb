# -*- coding: utf-8 -*-
# stolen from okkez http://github.com/hiki/hiki/blob/rack/hiki/response.rb
module TDiary
	if Object.const_defined?(:Rack)
		Response = ::Rack::Response
	else
		class Response
			attr_reader :body, :status, :headers
			def initialize(body = [], status = 200, headers = {}, &block)
				@body = body
				@status = status
				@headers = headers
				yield self if block_given?
			end

			def finish
				[status, headers, body]
			end
			alias to_a finish
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
