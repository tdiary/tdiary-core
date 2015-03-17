module TDiary
	module Rack
		class Auth
			autoload :Basic,         'tdiary/rack/auth/basic'
			autoload :OmniAuth,      'tdiary/rack/auth/omniauth'

			def initialize(app)
				if defined? ::OmniAuth
					@app = TDiary::Rack::Auth::OmniAuth.new(app)
				else
					@app = TDiary::Rack::Auth::Basic.new(app, '.htpasswd')
				end
			end

			def call(env)
				@app.call(env)
			end
		end
	end
end
