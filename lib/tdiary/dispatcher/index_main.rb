module TDiary
	class Dispatcher
		class IndexMain
			def self.run( request )
				new( request ).run
			end

			attr_reader :request, :cgi, :conf, :tdiary, :params

			def initialize( request )
				@request = request
				@cgi = request.cgi_compat
				@conf = TDiary::Configuration::new( request )
				@params = request.params
			end

			def run
				begin
					@tdiary = create_tdiary

					begin
						status = 200
						head = {
							'content-type' => 'text/html; charset=UTF-8',
							'vary' => 'User-Agent'
						}
						body = ''
						head['last-modified'] = tdiary.last_modified.httpdate

						if request.head?
							head['cache-control'] = 'no-cache'
							return TDiary::Response.new( '', 200, head )
						else
							require 'openssl'
							body = tdiary.eval_rhtml
							head['etag'] = %Q["#{OpenSSL::Digest::SHA256.hexdigest( body )}"]
							if request.env['HTTP_IF_NONE_MATCH'] == head['etag'] and request.get? then
								status = 304
							else
								head['content-length'] = body.bytesize.to_s
							end
							head['cache-control'] = 'no-cache'
							res = TDiary::Response.new( body, status, head )
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
					res = TDiary::Response.new( '', 303, { 'location' => $!.path } )
					res.set_header('Set-Cookie', tdiary.cookies.map(&:to_s)) if tdiary && tdiary.cookies.size > 0
					res
				end
			end

			def create_tdiary
				begin
					if params['comment']
						tdiary = TDiary::TDiaryComment::new( request, "day.rhtml", conf )
					elsif params['plugin']
						tdiary = TDiary::TDiaryPluginView::new( request, '', conf )
					elsif (date = params['date'])
						if /^\d{8}-\d+$/ =~ date
							tdiary = TDiary::TDiaryLatest::new( request, "latest.rhtml", conf )
						elsif /^\d{8}$/ =~ date
							tdiary = TDiary::TDiaryDay::new( request, "day.rhtml", conf )
						elsif /^\d{6}$/ =~ date
							tdiary = TDiary::TDiaryMonth::new( request, "month.rhtml", conf )
						elsif /^\d{4}$/ =~ date
							tdiary = TDiary::TDiaryNYear::new( request, "month.rhtml", conf )
						end
					elsif params['category']
						tdiary = TDiary::TDiaryCategoryView::new( request, "category.rhtml", conf )
					elsif params['q']
						tdiary = TDiary::TDiarySearch::new( request, "search.rhtml", conf )
					else
						tdiary = TDiary::TDiaryLatest::new( request, "latest.rhtml", conf )
					end
				rescue TDiary::PermissionError
					raise
				rescue TDiary::TDiaryError
				end
				( tdiary ? tdiary : TDiary::TDiaryLatest::new( request, "latest.rhtml", conf ) )
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
