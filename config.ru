$:.unshift( File::dirname( __FILE__ ).untaint )
require 'tdiary/application'
require 'tdiary/rack/html_anchor'
require 'tdiary/rack/auth/basic'
require 'omniauth'
require 'tdiary/rack/auth/omniauth'

use Rack::Reloader

base_dir = ''

# OmniAuth settings
use Rack::Session::Pool, :expire_after => 2592000
use OmniAuth::Builder do
	configure {|conf| conf.path_prefix = "#{base_dir}/auth" }
	# provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
	# provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
end
map "#{base_dir}/auth" do
	run TDiary::Rack::Auth::OmniAuth::CallbackHandler.new
end

map "#{base_dir}/assets" do
	environment = Sprockets::Environment.new
	['js', 'theme', '../tdiary-contrib/js', '../tdiary-theme'].each do |path|
		environment.append_path path
	end
	run environment
end

map "#{base_dir}/" do
	use TDiary::Rack::HtmlAnchor
	run Rack::Cascade.new([
		Rack::File.new("./public/"),
		TDiary::Application.new(:index)
	])
end

map "#{base_dir}/update.rb" do
	use TDiary::Rack::Auth::Basic, '.htpasswd'
	# use Rack::Auth::Basic do |user, pass|
	#	user == 'user' && pass == 'pass'
	# end
	# use TDiary::Rack::Auth::OmniAuth, :twitter do |auth|
	#		auth.info.nickname == 'your_twitter_screen_name'
	# end
	run TDiary::Application.new(:update)
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
