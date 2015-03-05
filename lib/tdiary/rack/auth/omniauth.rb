require 'omniauth'

module TDiary
	module Rack
		module Auth
			class OmniAuth
				def initialize(app, provider, &block)
					@app = app
					@provider = provider
					@authz = block
				end

				def call(env)
					if not authenticate?(env)
						# phase 1: request phase
						login(env)
					elsif env['REQUEST_PATH'].match(/callback$/)
						# phase 2: callback phase
						callback(env)
					else
						# phase 3: authorization phase
						auth = env['rack.session']['auth']
						env['REMOTE_USER'] = "#{auth.uid}@#{auth.provider}"
						return forbidden unless @authz.call(auth)
						@app.call(env)
					end
				end

				def login(env)
					env['rack.session']['tdiary.auth.redirect'] =
						"#{env['REQUEST_PATH']}?#{env['QUERY_STRING']}"
					redirect = File.join(env['REQUEST_PATH'], "#{::OmniAuth.config.path_prefix}/#{@provider}")
					[302, {'Content-Type' => 'text/plain', 'Location' => redirect}, []]
				end

				def logout(env)
					env['rack.session']['user_id'] = nil
				end

				def forbidden
					[403, {'Content-Type' => 'text/plain'}, ['forbidden']]
				end

				def callback(env)
					# reset sesstion to prevend session fixation attack
					# see: http://www.ipa.go.jp/security/vuln/documents/website_security.pdf (section 1.4)
					env['rack.session.options'][:renew] = true
					auth = env['omniauth.auth']
					env['rack.session']['auth'] = auth
					env['REMOTE_USER'] = "#{auth.uid}@#{auth.provider}"
					redirect = env['rack.session']['tdiary.auth.redirect'] || '/'
					[302, {'Content-Type' => 'text/plain', 'Location' => redirect}, []]
				end

				def authenticate?(env)
					env['rack.session']['oauth'] && env['rack.session']['oauth'][@provider.to_s]['callback_confirmed']
				end
			end
		end
	end
end
