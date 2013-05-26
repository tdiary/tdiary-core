# -*- coding: utf-8 -*-
require 'rack/builder'
require 'tdiary/rack/static'
require 'tdiary/rack/html_anchor'
require 'tdiary/rack/valid_request_path'
require 'tdiary/rack/auth/basic'

module TDiary
	class Application
		def initialize( base_dir = '' )
			@app = ::Rack::Builder.app {
				map "#{base_dir}/" do
					use TDiary::Rack::HtmlAnchor
					use TDiary::Rack::Static, "public"
					use TDiary::Rack::ValidRequestPath
					run TDiary::Dispatcher.index
				end

				map "#{base_dir}/update.rb" do
					use TDiary::Rack::Auth::Basic, '.htpasswd'
					run TDiary::Dispatcher.update
				end

				map "#{base_dir}/assets" do
					environment = Sprockets::Environment.new
					%w(js theme).each {|path| environment.append_path File.join(TDiary.root, path) }
					# FIXME: dirty hack, it should create TDiary::Server::Config.assets_path
					TDiary::Contrib::Assets.setup(environment) if defined?(TDiary::Contrib)
					run environment

					# if you need to auto compilation for CoffeeScript
					# require 'tdiary/rack/assets/precompile'
					# use TDiary::Rack::Assets::Precompile, environment
				end
			}
		end

		def call( env )
			@app.call( env )
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
