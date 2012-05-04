$:.unshift( File::dirname( __FILE__ ).untaint )
require 'tdiary/application'

use Rack::Reloader

base_dir = ''

map "#{base_dir}/assets" do
	environment = Sprockets::Environment.new
	['js', 'theme', '../tdiary-contrib/js', '../tdiary-theme'].each do |path|
		environment.append_path path
	end
	run environment
end

map "#{base_dir}/" do
	run TDiary::Application.new(:index)
end

map "#{base_dir}/index.rb" do
	run TDiary::Application.new(:index)
end

map "#{base_dir}/update.rb" do
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
