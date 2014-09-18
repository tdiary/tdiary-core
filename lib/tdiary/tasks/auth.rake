namespace :auth do
	namespace :password do
		desc "create password"
		task :create do
			require 'webrick/httpauth/htpasswd'
			puts 'create .htpasswd file'
			print 'Username: '
			ARGV.replace([])
			username = gets().chop
			print 'New password: '
			system "stty -echo"
			password = $stdin.gets.chop
			puts
			print 'Re-type new password: '
			password2 = $stdin.gets.chop
			puts
			system "stty echo"
			if password != password2
				raise StandardError, 'password verification error'
			else
				htpasswd = WEBrick::HTTPAuth::Htpasswd.new('.htpasswd')
				htpasswd.set_passwd(nil, username, password)
				htpasswd.flush
				puts "Adding password for user #{username}"
			end
		end
	end
end
