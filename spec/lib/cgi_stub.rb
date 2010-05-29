# -*- coding: utf-8 -*-
require 'cgi'
class CGIStub
	attr_accessor :script_name, :server_name, :params
	attr_reader :header

	def initialize(method=:get, script_name = "/index.rb", options={ })
		ENV["REQUEST_METHOD"] = method.to_s.upcase
		@cgi = CGI.new
		@script_name = script_name
		@params = options.inject( Hash.new( [] ) ){ |h, ( k, v )| h[k.to_s] = [v];h }
	end

	def server_name
		"localhost"
	end

	def script_name
		@script_name
	end

	def header(options)
		@cgi.header(options)
	end

	def server_port
		10080
	end

	def referer
		"http://example.com/somewhere"
	end

	def user_agent
		"Mozila"
	end

	def request_method
		"GET"
	end

# tdiary extend
	def redirect_url
		"http://#{server_name}:#{server_port}"
#		env_table['REDIRECT_URL']
	end

	def https?
		false
	end

	def mobile_agent?
		false
	end

	def iphone?
		false
	end

	# copied from tdiary.rb
	def valid?( param, idx = 0 )
		begin
			self.params[param] and self.params[param][idx] and self.params[param][idx].length > 0
		rescue NameError # for Tempfile class of ruby 1.6
			self.params[param][idx].stat.size > 0
		end
	end

	# mod_rubyかどうかの判定に、footer.rhtml で利用している
	def gateway_interface
		"" # とりあえず空で
	end
end
