# -*- coding: utf-8; -*-

require 'stringio'
require 'tdiary'
require 'tdiary/response_helper'

module TDiary
	class Dispatcher
		class IndexMain
			def self.run( cgi )
				begin
					@cgi = cgi
					conf = TDiary::Config::new(@cgi)
					tdiary = nil
					status = nil

					if %r[/\d{4,8}(-\d+)?\.html?$] =~ @cgi.redirect_url and not @cgi.valid?( 'date' ) then
						@cgi.params['date'] = [@cgi.redirect_url.sub( /.*\/(\d+)(-\d+)?\.html$/, '\1\2' )]
						status = CGI::HTTP_STATUS['OK']
					end

					begin
						if @cgi.valid?( 'comment' ) then
							tdiary = TDiary::TDiaryComment::new( @cgi, "day.rhtml", conf )
						elsif @cgi.valid?( 'date' )
							date = @cgi.params['date'][0]
							if /^\d{8}-\d+$/ =~ date then
								tdiary = TDiary::TDiaryLatest::new( @cgi, "latest.rhtml", conf )
							elsif /^\d{8}$/ =~ date then
								tdiary = TDiary::TDiaryDay::new( @cgi, "day.rhtml", conf )
							elsif /^\d{6}$/ =~ date then
								tdiary = TDiary::TDiaryMonth::new( @cgi, "month.rhtml", conf )
							elsif /^\d{4}$/ =~ date then
								tdiary = TDiary::TDiaryNYear::new( @cgi, "month.rhtml", conf )
							end
						elsif @cgi.valid?( 'category' )
							tdiary = TDiary::TDiaryCategoryView::new( @cgi, "category.rhtml", conf )
						elsif @cgi.valid?( 'q' )
							tdiary = TDiary::TDiarySearch::new( @cgi, "search.rhtml", conf )
						else
							tdiary = TDiary::TDiaryLatest::new( @cgi, "latest.rhtml", conf )
						end
					rescue TDiary::PermissionError
						raise
					rescue TDiary::TDiaryError
					end
					tdiary = TDiary::TDiaryLatest::new( @cgi, "latest.rhtml", conf ) if not tdiary

					begin
						head = {
							'type' => 'text/html',
							'Vary' => 'User-Agent'
						}
						head['status'] = status if status
						body = ''
						head['Last-Modified'] = CGI::rfc1123_date( tdiary.last_modified )

						if /HEAD/i =~ @cgi.request_method then
							head['Pragma'] = 'no-cache'
							head['Cache-Control'] = 'no-cache'
							print @cgi.header( head )
						else
							if @cgi.mobile_agent? then
								body = conf.to_mobile( tdiary.eval_rhtml( 'i.' ) )
								head['charset'] = conf.mobile_encoding
								head['Content-Length'] = body.bytesize.to_s
							else
								require 'digest/md5'
								body = tdiary.eval_rhtml
								head['ETag'] = %Q["#{Digest::MD5.hexdigest( body )}"]
								if ENV['HTTP_IF_NONE_MATCH'] == head['ETag'] and /^GET$/i =~ @cgi.request_method then
									head['status'] = CGI::HTTP_STATUS['NOT_MODIFIED']
									body = ''
								else
									head['charset'] = conf.encoding
									head['Content-Length'] = body.bytesize.to_s
								end
								head['Pragma'] = 'no-cache'
								head['Cache-Control'] = 'no-cache'
								head['X-Frame-Options'] = conf.x_frame_options if conf.x_frame_options
							end
							head['cookie'] = tdiary.cookies if tdiary.cookies.size > 0
							print @cgi.header( head )
							print body
						end
					rescue TDiary::NotFound
						if @cgi then
							print @cgi.header( 'status' => CGI::HTTP_STATUS['NOT_FOUND'], 'type' => 'text/html' )
						else
							print "Status: 404 Not Found\n"
							print "Content-Type: text/html\n\n"
						end
						puts "<h1>404 Not Found</h1>"
						puts "<div>#{' ' * 500}</div>"
					end
				rescue TDiary::ForceRedirect
					head = {
						#'Location' => $!.path
						'type' => 'text/html',
					}
					head['cookie'] = tdiary.cookies if tdiary && tdiary.cookies.size > 0
					print @cgi.header( head )
					print %Q[
								<html>
								<head>
								<meta http-equiv="refresh" content="1;url=#{$!.path}">
								<title>moving...</title>
								</head>
								<body>Wait or <a href="#{$!.path}">Click here!</a></body>
								</html>]
				end
			end
		end

		class UpdateMain
			def self.run( cgi )
				@cgi = cgi
				conf = TDiary::Config::new(@cgi)
				tdiary = nil
				begin
					if @cgi.valid?( 'append' )
						tdiary = TDiary::TDiaryAppend::new( @cgi, 'show.rhtml', conf )
					elsif @cgi.valid?( 'edit' )
						tdiary = TDiary::TDiaryEdit::new( @cgi, 'update.rhtml', conf )
					elsif @cgi.valid?( 'replace' )
						tdiary = TDiary::TDiaryReplace::new( @cgi, 'show.rhtml', conf )
					elsif @cgi.valid?( 'appendpreview' ) or @cgi.valid?( 'replacepreview' )
						tdiary = TDiary::TDiaryPreview::new( @cgi, 'preview.rhtml', conf )
					elsif @cgi.valid?( 'plugin' )
						tdiary = TDiary::TDiaryFormPlugin::new( @cgi, 'update.rhtml', conf )
					elsif @cgi.valid?( 'comment' )
						tdiary = TDiary::TDiaryShowComment::new( @cgi, 'update.rhtml', conf )
					elsif @cgi.valid?( 'saveconf' )
						tdiary = TDiary::TDiarySaveConf::new( @cgi, 'conf.rhtml', conf )
					elsif @cgi.valid?( 'conf' )
						tdiary = TDiary::TDiaryConf::new( @cgi, 'conf.rhtml', conf )
					elsif @cgi.valid?( 'referer' )
						tdiary = TDiary::TDiaryConf::new( @cgi, 'referer.rhtml', conf )
					else
						tdiary = TDiary::TDiaryForm::new( @cgi, 'update.rhtml', conf )
					end
				rescue TDiary::TDiaryError
					tdiary = TDiary::TDiaryForm::new( @cgi, 'update.rhtml', conf )
				end

				begin
					head = body = ''
					if @cgi.mobile_agent? then
						body = conf.to_mobile( tdiary.eval_rhtml( 'i.' ) )
						head = @cgi.header(
							'status' => '200 OK',
							'type' => 'text/html',
							'charset' => conf.mobile_encoding,
							'Content-Length' => body.bytesize.to_s,
							'Vary' => 'User-Agent'
							)
					else
						body = tdiary.eval_rhtml
						head = @cgi.header(
							'status' => '200 OK',
							'type' => 'text/html',
							'charset' => conf.encoding,
							'Content-Length' => body.bytesize.to_s,
							'Vary' => 'User-Agent'
							)
					end
					print head
					print body if /HEAD/i !~ @cgi.request_method
				rescue TDiary::ForceRedirect
					head = {
						#'Location' => $!.path
						'type' => 'text/html',
					}
					head['cookie'] = tdiary.cookies if tdiary.cookies.size > 0
					print @cgi.header( head )
					print %Q[
								<html>
								<head>
								<meta http-equiv="refresh" content="1;url=#{$!.path}">
								<title>moving...</title>
								</head>
								<body>Wait or <a href="#{$!.path}">Click here!</a></body>
								</html>]
				end
			end
		end

		TARGET = {
			:index => IndexMain,
			:update => UpdateMain
		}

		class << self
			def index
				new( :index )
			end

			def update
				new( :update )
			end
			private :new
		end

		def initialize( target )
			@target = TARGET[target]
		end

		def dispatch_cgi( cgi = CGI.new, stdout = nil, stderr = nil )
			stdout_orig = $stdout;stderr_orig = $stderr
			begin
				$stdout = stdout if stdout
				$stderr = stderr if stderr
				@target.run( cgi )
			ensure
				$stdout = stdout_orig
				$stderr = stderr_orig
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
