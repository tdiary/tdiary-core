#!/usr/bin/env ruby
# index.rb $Revision: 1.3 $
$KCODE= 'e'
BEGIN { $defout.binmode }

begin
	if FileTest::symlink?( __FILE__ ) then
		org_path = File::dirname( File::readlink( __FILE__ ) )
	else
		org_path = File::dirname( __FILE__ )
	end
	$:.unshift org_path
	require 'tdiary'

	@cgi = CGI::new
	tdiary = nil

	begin
		if @cgi.valid?( 'comment' ) then
			tdiary = TDiaryComment::new( @cgi, "day.rhtml" )
		elsif @cgi.valid?( 'date' )
			date, = @cgi['date']
			if /^\d{8}$/ =~ date then
				tdiary = TDiaryDay::new( @cgi, "day.rhtml" )
			elsif /^\d{6}$/ =~ date then
				tdiary = TDiaryMonth::new( @cgi, "month.rhtml" )
			end
		else
			tdiary = TDiaryLatest::new( @cgi, "latest.rhtml" )
		end
	rescue TDiary::PermissionError
		raise
	rescue TDiary::TDiaryError
	end
	tdiary = TDiaryLatest::new( @cgi, "latest.rhtml" ) if not tdiary

	head = body = ''
	if @cgi.mobile_agent? then
		body = tdiary.eval_rhtml( 'i.' ).to_sjis
		head = @cgi.header(
			'type' => 'text/html',
			'charset' => 'Shift_JIS',
			'Last-Modified' => CGI::rfc1123_date( tdiary.last_modified ),
			'Content-Length' => body.size.to_s,
			'Vary' => 'User-Agent'
		)
	else
		body = tdiary.eval_rhtml
		hash = {
			'type' => 'text/html',
			'charset' => 'EUC-JP',
			'Last-Modified' => CGI::rfc1123_date( tdiary.last_modified ),
			'Content-Length' => body.size.to_s,
			'Pragma' => 'no-cache',
			'Cache-Control' => 'no-cache',
			'Vary' => 'User-Agent',
		}
		hash['cookie'] = tdiary.cookies if tdiary.cookies.size > 0
		head = @cgi.header( hash )
	end
	print head
	print body if /HEAD/i !~ @cgi.request_method
rescue Exception
	print "Content-Type: text/plain\n\n"
	puts "#$! (#{$!.type})"
	puts ""
	puts $@.join( "\n" )
end

