$:.unshift( File::dirname( __FILE__ ).untaint )
require 'tdiary/application'
require 'tdiary/rack/html_anchor'
require 'tdiary/rack/auth/basic'

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
	use TDiary::Rack::HtmlAnchor
	run Rack::Cascade.new([
		Rack::File.new("./public/"),
		TDiary::Application.new(:index)
	])
end

map "#{base_dir}/update.rb" do
	use TDiary::Rack::Auth::Basic
	run TDiary::Application.new(:update)
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
