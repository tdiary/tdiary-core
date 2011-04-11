# -*- coding: utf-8; -*-
#
# server.rb: standalone tdiary cgi server via WEBrick.
#
# Copyright (C) 2008-2010, Kakutani Shintaro <shintaro@kakutani.com>
# You can redistribute it and/or modify it under GPL2.

require 'webrick'
require 'webrick/httpservlet/cgihandler'
require 'webrick/httputils'
require 'webrick/accesslog'
require 'tempfile'

module TDiary
	class StandaloneCGIServer
		TDIARY_CORE_DIR = File.expand_path( "../../../", File.dirname( __FILE__ ) )
		DEFAULT_OPTIONS = {
			:logger => $stderr,
			:access_log => $stderr,
		}
		class << self
			def run( option )
				@@server = TDiary::StandaloneCGIServer.new( option )
				trap( "INT" ) { @@server.shutdown }
				trap( "TERM" ) { @@server.shutdown }

				unless File.exist?(TDIARY_CORE_DIR + '/tdiary.conf')
					FileUtils.cp_r(TDIARY_CORE_DIR + '/spec/fixtures/tdiary.conf.webrick',
						TDIARY_CORE_DIR + '/tdiary.conf', :verbose => false)
				end

				unless File.directory?(TDIARY_CORE_DIR + '/tmp/data/log')
					FileUtils.mkdir_p(TDIARY_CORE_DIR + '/tmp/data/log')
				end

				@@server.start
			end

			def stop
				@@server.shutdown

				if File.exist?(TDIARY_CORE_DIR + '/tdiary.conf')
					FileUtils.rm TDIARY_CORE_DIR + '/tdiary.conf'
				end
			end
		end

		def initialize( options )
			opts = DEFAULT_OPTIONS.merge( options )

			@server = WEBrick::HTTPServer.new(
				:Port => opts[:port], :BindAddress => '127.0.0.1',
				:DocumentRoot => TDIARY_CORE_DIR,
				:MimeTypes => tdiary_mime_types,
				:Logger => webrick_logger_to( opts[:logger] ),
				:AccessLog => webrick_access_log_to( opts[:access_log] ),
				:CGIInterpreter => WEBrick::HTTPServlet::CGIHandler::Ruby
				)
			@server.logger.level = WEBrick::Log::DEBUG
			@server.mount( "/", WEBrick::HTTPServlet::CGIHandler,
				File.expand_path( "index.rb", TDIARY_CORE_DIR ) )
			@server.mount( "/index.rb", WEBrick::HTTPServlet::CGIHandler,
				File.expand_path( "index.rb", TDIARY_CORE_DIR ) )
			@server.mount( "/update.rb", WEBrick::HTTPServlet::CGIHandler,
				File.expand_path( "update.rb", TDIARY_CORE_DIR ) )
			@server.mount( "/theme", WEBrick::HTTPServlet::FileHandler,
				File.expand_path( "theme", TDIARY_CORE_DIR ) )
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
