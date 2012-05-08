require 'rack'
require 'webrick/httpauth/htpasswd'

module TDiary
	module Rack
		module Auth
			class PasswordFileNotFound < StandardError; end

			class Basic
				def initialize( app )
					@authenticator = ::Rack::Auth::Basic.new( app ) do |user, pass|
						file = '.htpasswd'
						unless File.exist?( file )
							raise PasswordFileNotFound.new("#{file} is not found")
						end
						htpasswd = WEBrick::HTTPAuth::Htpasswd.new( file )
						crypted = htpasswd.get_passwd(nil, user, false)
						crypted == pass.crypt( crypted ) if crypted
					end
				end

				def call( env )
					begin
						@authenticator.call( env )
					rescue PasswordFileNotFound => e
						[403, {"Content-Type" => "text/plain"}, [e.message]]
					end
				end
			end
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
