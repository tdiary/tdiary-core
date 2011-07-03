$:.unshift( File::dirname( __FILE__ ).untaint )
require 'tdiary/application'

use Rack::Reloader
use Rack::Static, :urls => ["/theme"], :root => "."
use Rack::Static, :urls => ["/js"], :root => "."

map "/" do
	run TDiary::Application.new(:index)
end

map "/index.rb" do
	run TDiary::Application.new(:index)
end

map "/update.rb" do
	use Rack::Auth::Basic do |user, pass|
		if File.exist?('.htpasswd')
			require 'webrick/httpauth/htpasswd'
			htpasswd = WEBrick::HTTPAuth::Htpasswd.new('.htpasswd')
			crypted = htpasswd.get_passwd(nil, user, false)
			crypted == pass.crypt(crypted) if crypted
		else
			user == 'user' && pass == 'pass'
		end
	end

	run TDiary::Application.new(:update)
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
