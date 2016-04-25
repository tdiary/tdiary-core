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
							'Content-Type' => 'text/html',
							'Vary' => 'User-Agent'
						}
						head['status'] = status if status
						body = ''
						head['Last-Modified'] = CGI::rfc1123_date( tdiary.last_modified )

						if request.head?
							head['Pragma'] = 'no-cache'
							head['Cache-Control'] = 'no-cache'
							return TDiary::Response.new( '', 200, head )
						else
							require 'digest/md5'
							body = tdiary.eval_rhtml
							head['ETag'] = %Q["#{Digest::MD5.hexdigest( body )}"]
							if ENV['HTTP_IF_NONE_MATCH'] == head['ETag'] and request.get? then
								head['status'] = CGI::HTTP_STATUS['NOT_MODIFIED']
							else
								head['charset'] = conf.encoding
								head['Content-Length'] = body.bytesize.to_s
							end
							head['Pragma'] = 'no-cache'
							head['Cache-Control'] = 'no-cache'
							head['X-Frame-Options'] = conf.x_frame_options if conf.x_frame_options
							head['cookie'] = tdiary.cookies if tdiary.cookies.size > 0
							TDiary::Response.new( body, ::TDiary::Dispatcher.extract_status_for_legacy_tdiary( head ), head )
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
					body = %Q[
								<html>
								<head>
								<meta http-equiv="refresh" content="1;url=#{$!.path}">
								<title>moving...</title>
								</head>
								<body>Wait or <a href="#{$!.path}">Click here!</a></body>
								</html>]
					head['cookie'] = tdiary.cookies if tdiary && tdiary.cookies.size > 0
					# TODO return code should be 302? (current behaviour returns 200)
					TDiary::Response.new( body, 200, head )
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
