# -*- coding: utf-8 -*-
require 'tdiary'
require 'rack/builder'
require 'tdiary/application/configuration'
require 'tdiary/rack'

# FIXME too dirty hack :-<
class CGI
	def env_table_rack
		$RACK_ENV
	end

	alias :env_table_orig :env_table
	alias :env_table :env_table_rack
end

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
		config.builder do
			map Application.config.path[:index] do
				use TDiary::Rack::HtmlAnchor
				use TDiary::Rack::Static, "public"
				use TDiary::Rack::ValidRequestPath
				run TDiary::Dispatcher.index
			end

			map Application.config.path[:update] do
				instance_eval &Application.config.authenticate_proc
				run TDiary::Dispatcher.update
			end

			map Application.config.path[:assets] do
				environment = Sprockets::Environment.new
				TDiary::Extensions::constants.map {|extension|
					TDiary::Extensions::const_get( extension ).assets_path
				}.flatten.uniq.each {|assets_path|
					environment.append_path assets_path
				}

				if Application.config.assets_precompile
					require 'tdiary/rack/assets/precompile'
					use TDiary::Rack::Assets::Precompile, environment
				end

				run environment
			end
		end

		config.authenticate TDiary::Rack::Auth::Basic, '.htpasswd'
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
