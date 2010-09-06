require File.dirname(__FILE__) + '/tdiary_app'

use Rack::ShowExceptions
use Rack::CommonLogger
use Rack::Lint
use Rack::Reloader

use Rack::Static, :urls => ["/theme"], :root => "."
use Rack::Static, :urls => ["/js"], :root => "."

map "/" do
	run Rack::TDiaryApp.new(:index)
end

map "/index.rb" do
	run Rack::TDiaryApp.new(:index)
end

map "/update.rb" do
	use Rack::Auth::Basic do |user, pass|
		user == 'user' && pass == 'pass'
	end

	run Rack::TDiaryApp.new(:update)
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
