$:.unshift( File::dirname( __FILE__ ).untaint )
require 'tdiary/environment'
require 'tdiary'
require 'tdiary/rack/html_anchor'
require 'tdiary/rack/valid_request_path'
require 'tdiary/rack/auth/basic'
require 'omniauth'
require 'tdiary/rack/auth/omniauth'

use Rack::Reloader unless ENV['RACK_ENV'] == 'production'

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

map "#{base_dir}/update.rb" do
	# Basic Auth
	use TDiary::Rack::Auth::Basic, '.htpasswd'

	# OAuth
	# use TDiary::Rack::Auth::OmniAuth, :twitter do |auth|
	#		auth.info.nickname == 'your_twitter_screen_name'
	# end

	run TDiary::Application.new(:update)
end

map "#{base_dir}/assets" do
	environment = Sprockets::Environment.new
	%w(js theme).each {|path| environment.append_path path }

	# if you need to auto compilation for CoffeeScript
	# require 'tdiary/rack/assets/precompile'
	# use TDiary::Rack::Assets::Precompile, environment

	run environment
end

map "#{base_dir}/" do
	use TDiary::Rack::HtmlAnchor
	run Rack::Cascade.new([
		Rack::File.new("./public/"),
		TDiary::Rack::ValidRequestPath.new(TDiary::Application.new(:index))
	])
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
