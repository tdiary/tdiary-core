# -*- coding: utf-8; -*-
module TDiary
  class Dispatcher
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
						head = {
							'status' => '200 OK',
							'Content-Type' => 'text/html',
							'charset' => conf.mobile_encoding,
							'Content-Length' => body.bytesize.to_s,
							'Vary' => 'User-Agent'
						}
					else
						body = tdiary.eval_rhtml
						head = {
							'status' => '200 OK',
							'Content-Type' => 'text/html',
							'charset' => conf.encoding,
							'Content-Length' => body.bytesize.to_s,
							'Vary' => 'User-Agent'
						}
					end
					body = ( /HEAD/i !~ @cgi.request_method ? body : '' )
					TDiary::Response.new( body, 200, head )
				rescue TDiary::ForceRedirect
					head = {
						#'Location' => $!.path
						'Content-Type' => 'text/html',
					}
					head['cookie'] = tdiary.cookies if tdiary.cookies.size > 0
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
