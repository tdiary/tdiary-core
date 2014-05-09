# -*- coding: utf-8; -*-
module TDiary
	class Dispatcher
		class UpdateMain
			def self.run( request, cgi )
				new( request, cgi ).run
			end

			attr_reader :request, :cgi, :conf, :tdiary, :params

			def initialize( request, cgi )
				@request = request
				@cgi = cgi
				@conf = TDiary::Config::new( cgi, request )
				@params = request.params
			end

			def run
				@tdiary = create_tdiary
				begin
					head = {}; body = ''
					if request.mobile_agent?
						body = conf.to_mobile( tdiary.eval_rhtml( 'i.' ) )
						head = {
							'Content-Type' => 'text/html',
							'charset' => conf.mobile_encoding,
							'Content-Length' => body.bytesize.to_s,
							'Vary' => 'User-Agent'
						}
					else
						body = tdiary.eval_rhtml
						head = {
							'Content-Type' => 'text/html',
							'charset' => conf.encoding,
							'Content-Length' => body.bytesize.to_s,
							'Vary' => 'User-Agent',
							'X-Frame-Options' => 'SAMEORIGIN'
						}
					end
					body = ( request.head? ? '' : body )
					TDiary::Response.new( body, 200, head )
				rescue TDiary::ForceRedirect
					head = {
						#'Location' => $!.path
						'Content-Type' => 'text/html',
					}
					body = %Q[
								<html>
								<head>
								<meta http-equiv="refresh" content="1;url=#{$!.path}">
								<title>moving...</title>
								</head>
								<body>Wait or <a href="#{$!.path}">Click here!</a></body>
								</html>]
					head['cookie'] = tdiary.cookies if tdiary.cookies.size > 0
					# TODO return code should be 302? (current behaviour returns 200)
					TDiary::Response.new( body, 200, head )
				end
			end

		private

			def create_tdiary
				begin
					if params['plugin']
						tdiary = TDiary::TDiaryFormPlugin::new( cgi, 'update.rhtml', conf )
					elsif params['append']
						tdiary = TDiary::TDiaryAppend::new( cgi, nil, conf )
					elsif params['edit']
						tdiary = TDiary::TDiaryEdit::new( cgi, 'update.rhtml', conf )
					elsif params['replace']
						tdiary = TDiary::TDiaryReplace::new( cgi, nil, conf )
					elsif params['appendpreview'] or params['replacepreview']
						tdiary = TDiary::TDiaryPreview::new( cgi, 'preview.rhtml', conf )
					elsif params['comment']
						tdiary = TDiary::TDiaryShowComment::new( cgi, 'update.rhtml', conf )
					elsif params['saveconf']
						tdiary = TDiary::TDiarySaveConf::new( cgi, 'conf.rhtml', conf )
					elsif params['conf']
						tdiary = TDiary::TDiaryConf::new( cgi, 'conf.rhtml', conf )
					elsif params['referer']
						tdiary = TDiary::TDiaryConf::new( cgi, 'referer.rhtml', conf )
					else
						tdiary = TDiary::TDiaryForm::new( cgi, 'update.rhtml', conf )
					end
				rescue TDiary::TDiaryError
					tdiary = TDiary::TDiaryForm::new( cgi, 'update.rhtml', conf )
				end
				tdiary
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
