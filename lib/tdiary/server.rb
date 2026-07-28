#
# server.rb: standalone tdiary cgi server via WEBrick.
#
# Copyright (C) 2008-2010, Kakutani Shintaro <shintaro@kakutani.com>
# You can redistribute it and/or modify it under GPL2 or any later version.

module TDiary
	class Server
		require 'webrick'
		require 'webrick/httpservlet/cgihandler'
		require 'webrick/httputils'
		require 'webrick/accesslog'
		require 'tempfile'

		# WEBrick's CGI runner clears the environment of the CGI child process
		# before exec'ing it, so the child cannot find the gems the server itself
		# runs with. Hand the RubyGems and Bundler locations back to it.
		module CGIEnvironment
			def meta_vars
				super.merge( {
					'HOME' => ENV['HOME'],
					'GEM_HOME' => Gem.dir,
					'GEM_PATH' => Gem.path.join( File::PATH_SEPARATOR ),
					'BUNDLE_GEMFILE' => ENV['BUNDLE_GEMFILE'],
				}.compact )
			end
		end

		class CGIHandler < WEBrick::HTTPServlet::CGIHandler
			def do_GET( req, res )
				req.extend( CGIEnvironment )
				super
			end
			alias do_POST do_GET
		end

		class << self
			def run( option )
				@@server = new( option )

				trap( "INT" ) { @@server.shutdown }
				trap( "TERM" ) { @@server.shutdown }

				@@server.start
			end

			def stop
				@@server.shutdown
			end
		end

		def initialize( opts )
			@server = WEBrick::HTTPServer.new(
				Port: opts[:port], BindAddress: opts[:bind],
				DocumentRoot: TDiary.root,
				MimeTypes: tdiary_mime_types,
				Logger: webrick_logger_to( opts[:logger] ),
				AccessLog: webrick_access_log_to( opts[:access_log] ),
				ServerType: opts[:daemon] ? WEBrick::Daemon : nil,
				CGIInterpreter: WEBrick::HTTPServlet::CGIHandler::Ruby
			)
			@server.logger.level = WEBrick::Log::DEBUG
			@server.mount("/", CGIHandler, TDiary.root + "/index.rb")
			@server.mount("/index.rb", CGIHandler, TDiary.root + '/index.rb')
			@server.mount("/update.rb", CGIHandler, TDiary.root + "/update.rb")
			@server.mount("/theme", WEBrick::HTTPServlet::FileHandler, TDiary.root + '/theme')
			@server.mount("/js", WEBrick::HTTPServlet::FileHandler, TDiary.root + '/js')
		end

		def start
			@server.start
		end

		def shutdown
			@server.shutdown
		end

	private

		def tdiary_mime_types
			WEBrick::HTTPUtils::DefaultMimeTypes.merge( {
					"rdf" => "application/xml",
				} )
		end

		def webrick_logger_to( io )
			io ||= Tempfile.new( "webrick_logger" )
			WEBrick::Log::new( io, WEBrick::Log::DEBUG )
		end

		def webrick_access_log_to( io )
			io ||= Tempfile.new( "webrick_access_log" )
			[
				[ io, WEBrick::AccessLog::COMMON_LOG_FORMAT ],
				[ io, WEBrick::AccessLog::REFERER_LOG_FORMAT ]
			]
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
