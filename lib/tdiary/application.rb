# -*- coding: utf-8 -*-
require 'tdiary'
require 'rack/builder'
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
		def initialize( base_dir = nil )
			index_path   = self.index_path
			update_path  = self.update_path
			assets_path  = self.assets_path
			assets_paths = self.assets_paths

			base_dir ||= self.base_dir

			@app = ::Rack::Builder.app do
				map base_dir do
					map '/' do
						use TDiary::Rack::HtmlAnchor
						use TDiary::Rack::Static, "public"
						use TDiary::Rack::ValidRequestPath
						map index_path do
							run TDiary::Dispatcher.index
						end
					end

					map update_path do
						use TDiary::Rack::Auth
						run TDiary::Dispatcher.update
					end

					map assets_path do
						environment = Sprockets::Environment.new
						assets_paths.each {|assets_path|
							environment.append_path assets_path
						}

						if TDiary.configuration.options['tdiary.assets.precompile']
							TDiary.logger.info('enable assets.precompile')
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

	protected
		def assets_paths
			TDiary::Extensions::constants.map {|extension|
				TDiary::Extensions::const_get( extension ).assets_path
			}.flatten.uniq
		end

		def index_path
			(Pathname.new('/') + TDiary.configuration.index).to_s
		end

		def update_path
			(Pathname.new('/') + TDiary.configuration.update).to_s
		end

		def assets_path
			'/assets'
		end

		def base_dir
			base_url = TDiary.configuration.base_url
			if base_url.empty?
				'/'
			else
				URI.parse(base_url).path
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

			begin
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
			rescue TDiary::ForceRedirect => e
				# 90migrate.rb raises TDiary::ForceRedirect at first startup
				TDiary::logger.warn(e)
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
