module TDiary
	module Rack
		class Auth
			autoload :Basic,         'tdiary/rack/auth/basic'
			autoload :OmniAuth,      'tdiary/rack/auth/omniauth'

			def initialize(app)
				if defined? ::OmniAuth
					@app = ::Rack::Builder.app {
						use TDiary::Rack::Session
						use ::OmniAuth::Builder do
							provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
						end
						use TDiary::Rack::Auth::OmniAuth, :twitter do |auth|
							ENV['TWITTER_NAME'].split(/,/).include?(auth.info.nickname)
						end
						run app
					}
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
