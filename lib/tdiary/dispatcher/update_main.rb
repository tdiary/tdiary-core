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
				@conf = TDiary::Configuration::new( cgi, request )
				@params = request.params
			end

			def run
				@tdiary = create_tdiary
				begin
					head = {}; body = ''
					body = tdiary.eval_rhtml
					head = {
						'content-type' => 'text/html; charset=UTF-8',
						'charset' => conf.encoding,
						'content-length' => body.bytesize.to_s,
						'vary' => 'User-Agent',
						'x-frame-options' => 'SAMEORIGIN'
					}
					body = ( request.head? ? '' : body )
					TDiary::Response.new( body, 200, head )
				rescue TDiary::ForceRedirect
					head = {
						#'Location' => $!.path
						'content-type' => 'text/html',
					}
					body = %Q[
								<html>
								<head>
								<meta http-equiv="refresh" content="1;url=#{$!.path}">
								<title>moving...</title>
								</head>
								<body>Wait or <a href="#{$!.path}">Click here!</a></body>
								</html>]
					# TODO return code should be 302? (current behaviour returns 200)
					res = TDiary::Response.new( body, 200, head )
					res.set_header('Set-Cookie', tdiary.cookies.map(&:to_s)) if tdiary && tdiary.cookies.size > 0
					res
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
