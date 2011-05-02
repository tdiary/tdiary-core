# -*- coding: utf-8; -*-
module TDiary
  class Dispatcher
		class IndexMain
			def self.run( cgi )
				begin
					@cgi = cgi
					conf = TDiary::Config::new(@cgi)
					tdiary = nil
					status = nil

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
							'Content-Type' => 'text/html',
							'Vary' => 'User-Agent'
						}
						head['status'] = status if status
						body = ''
						head['Last-Modified'] = CGI::rfc1123_date( tdiary.last_modified )

						if /HEAD/i =~ @cgi.request_method then
							head['Pragma'] = 'no-cache'
							head['Cache-Control'] = 'no-cache'
							return TDiary::Response.new( '', 200, head )
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
									status = CGI::HTTP_STATUS['NOT_MODIFIED']
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
							TDiary::Response.new( body, ::TDiary::Dispatcher.extract_status_for_legacy_tdiary( status ), head )
						end
					rescue TDiary::NotFound
						body = %Q[
									<h1>404 Not Found</h1>
									<div>#{' ' * 500}</div>]
						TDiary::Response.new( body, 404, { 'Content-Type' => 'text/html' } )
					end
				rescue TDiary::ForceRedirect
					head = {
						#'Location' => $!.path
						'Content-Type' => 'text/html',
					}
					head['cookie'] = tdiary.cookies if tdiary && tdiary.cookies.size > 0
					body = %Q[
								<html>
								<head>
								<meta http-equiv="refresh" content="1;url=#{$!.path}">
								<title>moving...</title>
								</head>
								<body>Wait or <a href="#{$!.path}">Click here!</a></body>
								</html>]
					# TODO return code should be 302? (current behaviour returns 200)
					TDiary::Response.new( body, 200, head )
				end
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
# vim: ts=3
