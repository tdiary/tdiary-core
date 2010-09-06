# -*- coding: utf-8; -*-

class ResponseHelper
	class HTTPStatus
		attr_reader :code, :message
		def initialize(code, message)
			@code, @message = code.to_i, message
		end
	end

	class << self
		def parse(raw_result)
			response_spy = new(raw_result)
			response_spy.parse_raw_result
			response_spy
		end
		private :new
	end

	attr_reader :body

	def initialize(raw = StringIO.new)
		@raw = raw
		@body = ""
	end

	def body
		@body
	end

	def headers
		@headers
	end
	alias :header :headers

	def status
		@status
	end

	def status_code
		@status.code
	end

	def parse_raw_result
		raw_header, @body = @raw.split(CGI::EOL * 2, 2)
		@headers ||= parse_headers(raw_header)
		@status = extract_status
	end

	def to_a
		[status_code, headers, body]
	end

	private
	def parse_headers(raw_header)
		raw_header.split(CGI::EOL).inject({}) do |headers, entry|
			if (pair = /(.+?):\s(.+?)\Z/.match(entry))
				key, val = pair[1..-1]
				headers[key] = val
			end
			headers.delete("Status") # for rack lint
			headers
		end
	end

	def extract_status
		if status = @headers["Status"]
			m = status.match(/(\d+)\s(.+)\Z/)
			HTTPStatus.new(*m[1..2])
		else
			HTTPStatus.new(200, "OK")
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
