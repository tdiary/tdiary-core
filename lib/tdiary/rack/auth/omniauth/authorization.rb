require 'omniauth'

module TDiary
	module Rack
		class Auth
			class OmniAuth
				class Authorization
					def initialize(app, provider, &block)
						@app = app
						@provider = provider
						@authz = block
					end

					def call(env)
						if not authenticate?(env)
							# phase 1: request phase
							login(env)
						elsif env['REQUEST_PATH'].match(%r|auth/#{@provider}/callback|)
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
						STDERR.puts "use #{@provider} authentication strategy"
						req = ::Rack::Request.new(env)
						env['rack.session']['tdiary.auth.redirect'] = "#{req.base_url}#{req.fullpath}"
						redirect = File.join("#{req.base_url}#{req.path}", "#{::OmniAuth.config.path_prefix}/#{@provider}")
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
						env['omniauth.auth'] || env['rack.session']['auth']
					end
				end
			end
		end
	end
end
