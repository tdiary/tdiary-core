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
					auth = env['rack.session']['auth']
					return login(env) unless auth
					env['REMOTE_USER'] = "#{auth.uid}@#{auth.provider}"
					return forbidden unless @authz.call(auth)
					@app.call(env)
				end

				def login(env)
					env['rack.session']['tdiary.auth.redirect'] =
						"#{env['REQUEST_PATH']}?#{env['QUERY_STRING']}"
					redirect = File.join(File.dirname(env['REQUEST_PATH']), "#{::OmniAuth.config.path_prefix}/#{@provider}")
					[302, {'Content-Type' => 'text/plain', 'Location' => redirect}, []]
				end

				def logout(env)
					env['rack.session']['user_id'] = nil
				end

				def forbidden
					[403, {'Content-Type' => 'text/plain'}, ['forbidden']]
				end

				class CallbackHandler
					def call(env)
						# reset sesstion to prevend session fixation attack
						# see: http://www.ipa.go.jp/security/vuln/documents/website_security.pdf (section 1.4)
						env['rack.session.options'][:renew] = true
						auth = env['omniauth.auth']
						env['rack.session']['auth'] = auth
						env['REMOTE_USER'] = "#{auth.uid}@#{auth.provider}"
						redirect = env['rack.session']['tdiary.auth.redirect'] || '/'
						[302, {'Content-Type' => 'text/plain', 'Location' => redirect}, []]
					end
				end
			end
		end
	end
end
