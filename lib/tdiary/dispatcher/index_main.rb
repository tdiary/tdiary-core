module TDiary
	class Dispatcher
		class IndexMain
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
				begin
					status = nil
					@tdiary = create_tdiary

					begin
						head = {
							'content-type' => 'text/html; charset=UTF-8',
							'vary' => 'User-Agent'
						}
						head['status'] = status if status
						body = ''
						head['Last-Modified'] = CGI::rfc1123_date( tdiary.last_modified )

						if request.head?
							head['pragma'] = 'no-cache'
							head['cache-control'] = 'no-cache'
							return TDiary::Response.new( '', 200, head )
						else
							require 'openssl'
							body = tdiary.eval_rhtml
							head['etag'] = %Q["#{OpenSSL::Digest::SHA256.hexdigest( body )}"]
							if ENV['HTTP_IF_NONE_MATCH'] == head['etag'] and request.get? then
								head['status'] = CGI::HTTP_STATUS['NOT_MODIFIED']
							else
								head['charset'] = conf.encoding
								head['content-length'] = body.bytesize.to_s
							end
							head['pragma'] = 'no-cache'
							head['cache-control'] = 'no-cache'
							head['x-frame-options'] = conf.x_frame_options if conf.x_frame_options
							res = TDiary::Response.new( body, ::TDiary::Dispatcher.extract_status_for_legacy_tdiary( head ), head )
							res.set_header('Set-Cookie', tdiary.cookies.map(&:to_s)) if tdiary && tdiary.cookies.size > 0
							res
						end
					rescue TDiary::NotFound
						body = %Q[
									<h1>404 Not Found</h1>
									<div>#{' ' * 500}</div>]
						TDiary::Response.new( body, 404, { 'content-type' => 'text/html' } )
					end
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

			def create_tdiary
				begin
					if params['comment']
						tdiary = TDiary::TDiaryComment::new( cgi, "day.rhtml", conf )
					elsif params['plugin']
						tdiary = TDiary::TDiaryPluginView::new( cgi, '', conf )
					elsif (date = params['date'])
						if /^\d{8}-\d+$/ =~ date
							tdiary = TDiary::TDiaryLatest::new( cgi, "latest.rhtml", conf )
						elsif /^\d{8}$/ =~ date
							tdiary = TDiary::TDiaryDay::new( cgi, "day.rhtml", conf )
						elsif /^\d{6}$/ =~ date
							tdiary = TDiary::TDiaryMonth::new( cgi, "month.rhtml", conf )
						elsif /^\d{4}$/ =~ date
							tdiary = TDiary::TDiaryNYear::new( cgi, "month.rhtml", conf )
						end
					elsif params['category']
						tdiary = TDiary::TDiaryCategoryView::new( cgi, "category.rhtml", conf )
					elsif params['q']
						tdiary = TDiary::TDiarySearch::new( cgi, "search.rhtml", conf )
					else
						tdiary = TDiary::TDiaryLatest::new( cgi, "latest.rhtml", conf )
					end
				rescue TDiary::PermissionError
					raise
				rescue TDiary::TDiaryError
				end
				( tdiary ? tdiary : TDiary::TDiaryLatest::new( cgi, "latest.rhtml", conf ) )
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
