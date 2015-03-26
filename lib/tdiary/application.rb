# -*- coding: utf-8 -*-
require 'tdiary'
require 'rack/builder'
require 'tdiary/application/configuration'
require 'tdiary/rack'

# FIXME too dirty hack :-<
class CGI
	def env_table_rack
		$RACK_ENV || ENV
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
			@app = ::Rack::Builder.app do
				map base_dir do
					map Application.config.path[:index] do
						use TDiary::Rack::HtmlAnchor
						use TDiary::Rack::Static, "public"
						use TDiary::Rack::ValidRequestPath
						run TDiary::Dispatcher.index
					end

					map Application.config.path[:update] do
						use TDiary::Rack::Auth
						run TDiary::Dispatcher.update
					end

					map Application.config.path[:assets] do
						environment = Sprockets::Environment.new
						TDiary::Application.config.assets_paths.each {|assets_path|
							environment.append_path assets_path
						}

						if Application.config.assets_precompile
							require 'tdiary/rack/assets/precompile'
							use TDiary::Rack::Assets::Precompile, environment
						end

						run environment
					end	
				end
			end
			run_plugin_startup_procs
		end

		def call( env )
			begin
				@app.call( env )
			rescue Exception => e
				body = ["#{e.class}: #{e}\n"]
				body << e.backtrace.join("\n")
				[500, {'Content-Type' => 'text/plain'}, body]
			end
		end

	private
		def run_plugin_startup_procs
			# avoid offline mode at CGI.new
			ARGV.replace([""])
			cgi = RackCGI.new

			request = TDiary::Request.new(ENV, cgi)
			conf = TDiary::Configuration.new(cgi, request)
			tdiary = TDiary::TDiaryBase.new(cgi, '', conf)
			io = conf.io_class.new(tdiary)

			plugin = TDiary::Plugin.new(
				'conf' => conf,
				'mode' => 'startup',
				'diaries' => tdiary.diaries,
				'cgi' => cgi,
				'years' => nil,
				'cache_path' => io.cache_path,
				'date' => Time.now,
				'comment' => nil,
				'last_modified' => Time.now,  # FIXME
				'logger' => TDiary.logger,
				# 'debug' => true
			)

			# run startup plugin
			plugin.__send__(:startup_proc, self)
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
