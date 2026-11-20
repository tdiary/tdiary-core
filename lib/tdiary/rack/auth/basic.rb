require 'rack'

module TDiary
	module Rack
		class Auth
			class PasswordFileNotFound < StandardError; end
			class UnsupportedPasswordFile < StandardError; end

			class Basic
				BCRYPT = /\A\$2[aby]\$\d{2}\$.{53}\z/
				# DES crypt(3), still verified by String#crypt until it leaves Ruby
				# (Feature #14915)
				CRYPT = %r{\A[a-zA-Z0-9./]{13}\z}
				RECREATE = 'Please remove it and create it again by `tdiary htpasswd` or `htpasswd -cB`.'

				# rewrites only the line of +user+, so the other lines keep their format
				def self.write_password(file, user, pass)
					require 'bcrypt'
					require 'tempfile'
					lines = File.exist?(file) ? File.readlines(file, chomp: true) : []
					# below the bcrypt default of 12, since every request to update.rb verifies it
					entry = "#{user}:#{BCrypt::Password.create(pass, cost: 10)}"
					if (i = lines.index {|line| line.split(':', 2).first == user })
						lines[i] = entry
					else
						lines << entry
					end
					Tempfile.create('htpasswd', File.dirname(file)) do |tmp|
						tmp.puts(lines)
						tmp.close
						File.rename(tmp.path, file)
					end
				end

				def initialize(app, file = '.htpasswd')
					@file = file
					@authenticator = ::Rack::Auth::Basic.new(app) do |user, pass|
						authenticate(user, pass)
					end
				end

				def call(env)
					begin
						@authenticator.call(env)
					rescue PasswordFileNotFound, UnsupportedPasswordFile => e
						[403, {"content-type" => "text/plain"}, [e.message]]
					end
				end

			private

				def authenticate(user, pass)
					# bcrypt and String#crypt raise on it, and no password file holds one
					return false if pass.include?("\0")
					case hashed = stored_password(user)
					when nil
						false
					when BCRYPT
						begin
							require 'bcrypt'
						rescue LoadError
							raise UnsupportedPasswordFile.new("#{@file} has a bcrypt password, but the bcrypt gem cannot be loaded. Please remove rack from BUNDLE_WITHOUT and run bundle install.")
						end
						BCrypt::Password.new(hashed) == pass
					when CRYPT
						begin
							pass.crypt(hashed) == hashed
						rescue NoMethodError, NotImplementedError, SystemCallError
							raise UnsupportedPasswordFile.new("This Ruby cannot verify the CRYPT password in #{@file}. #{RECREATE}")
						end
					else
						raise UnsupportedPasswordFile.new("#{@file} has a password in an unsupported format. #{RECREATE}")
					end
				end

				def stored_password(user)
					unless File.exist?(@file)
						raise PasswordFileNotFound.new("#{@file} is not found. Please create it by htpasswd program.")
					end
					File.foreach(@file, chomp: true) do |line|
						name, hashed = line.split(':', 2)
						return hashed if name == user
					end
					nil
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
