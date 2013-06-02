# -*- coding: utf-8 -*-
require 'rack/builder'
require 'tdiary/application/configuration'
require 'tdiary/rack'

module TDiary
	class Application
		class << self
			def configure(&block)
				instance_eval &block
			end

			def config
				@config ||= Configuration.new
			end
		end

		def initialize( base_dir = '/' )
			@app = ::Rack::Builder.app {
				map base_dir do
					Application.config.builder_procs.each do |builder_proc|
						instance_eval &builder_proc
					end
				end
			}
		end

		def call( env )
			@app.call( env )
		end
	end

	Application.configure do
		config.assets_paths.concat %w(js theme).map {|path|
			File.join(TDiary.root, path)
		}

		config.builder do
			map Application.config.path[:index] do
				use TDiary::Rack::HtmlAnchor
				use TDiary::Rack::Static, "public"
				use TDiary::Rack::ValidRequestPath
				run TDiary::Dispatcher.index
			end

			map Application.config.path[:update] do
				use TDiary::Rack::Auth::Basic, '.htpasswd'
				run TDiary::Dispatcher.update
			end

			map Application.config.path[:assets] do
				environment = Sprockets::Environment.new
				Application.config.assets_paths.each do |path|
					environment.append_path path
				end

				if Application.config.assets_precompile
					require 'tdiary/rack/assets/precompile'
					use TDiary::Rack::Assets::Precompile, environment
				end

				run environment
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
