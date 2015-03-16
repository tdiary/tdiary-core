begin
	require 'rack/session/dalli'
rescue LoadError
end

module TDiary
	module Rack
		class Session
			def initialize(app)
				@app = session_middleware(app)
			end

			def call(env)
				@app.call(env)
			end

		private

			def session_middleware(app)
				if ::Rack::Session.const_defined? :Dalli
					::Rack::Session::Dalli.new(
						app,
						cache: Dalli::Client.new,
						expire_after: 2592000
					)
				else
					::Rack::Session::Pool.new(
						app,
						expire_after: 2592000
					)
				end
			end
		end
	end
end
