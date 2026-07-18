require 'stringio'
require 'tdiary'
require 'tdiary/extensions/core'
require 'rack/builder'
require 'tdiary/rack'

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
						use TDiary::Rack::Static, ["public"]
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
						run TDiary::Rack::Static.new(nil, assets_paths)
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
				[500, {'content-type' => 'text/plain'}, body]
			end
		end

		def assets_paths
			TDiary::Extensions::constants.map {|extension|
				TDiary::Extensions::const_get( extension ).assets_path
			}.flatten.uniq
		end

	protected
		def index_path
			(Pathname.new('/') + URI(TDiary.configuration.index).path).to_s
		end

		def update_path
			(Pathname.new('/') + URI(TDiary.configuration.update).path).to_s
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
			# minimal Rack env for the request handed to startup plugins
			env = {
				'REQUEST_METHOD'  => 'GET',
				'SCRIPT_NAME'     => '',
				'PATH_INFO'       => '/',
				'QUERY_STRING'    => '',
				'SERVER_NAME'     => 'localhost',
				'SERVER_PORT'     => '80',
				'rack.url_scheme' => 'http',
				'rack.input'      => StringIO.new('')
			}
			request = TDiary::Request.new(env)
			cgi = request.cgi_compat
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
