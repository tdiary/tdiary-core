#!/usr/bin/env ruby
#
# index.rb $Revision: 1.34 $
#
# Copyright (C) 2001-2006, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#
BEGIN { $defout.binmode }
$KCODE = 'n'

begin
	if FileTest::symlink?( __FILE__ ) then
		org_path = File::dirname( File::readlink( __FILE__ ) )
	else
		org_path = File::dirname( __FILE__ )
	end
	$:.unshift( org_path.untaint )
	require 'tdiary'

	@cgi = CGI::new
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
			elsif /^\d{8}$/ =~ date
				tdiary = TDiary::TDiaryDay::new( @cgi, "day.rhtml", conf )
			elsif /^\d{6}$/ =~ date then
				tdiary = TDiary::TDiaryMonth::new( @cgi, "month.rhtml", conf )
			elsif /^\d{4}$/ =~ date then
				tdiary = TDiary::TDiaryNYear::new( @cgi, "month.rhtml", conf )
			end
		elsif @cgi.valid?( 'category' )
			tdiary = TDiary::TDiaryCategoryView::new( @cgi, "category.rhtml", conf )
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

		if /HEAD/i !~ @cgi.request_method then
			if @cgi.mobile_agent? then
				body = conf.to_mobile( tdiary.eval_rhtml( 'i.' ) )
				head['charset'] = conf.mobile_encoding
				head['Content-Length'] = body.size.to_s
			else
				require 'md5'
				body = tdiary.eval_rhtml
				head['ETag'] = %Q["#{MD5::md5( body )}"]
				if ENV['HTTP_IF_NONE_MATCH'] == head['ETag'] then
				   head['status'] = CGI::HTTP_STATUS['NOT_MODIFIED']
					body = ''
				else
					head['charset'] = conf.encoding
					head['Content-Length'] = body.size.to_s
				end
			end
			head['cookie'] = tdiary.cookies if tdiary.cookies.size > 0
			print @cgi.header( head )
			print body
		else
			head['Pragma'] = 'no-cache'
			head['Cache-Control'] = 'no-cache'
			print @cgi.header( head )
		end
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
rescue Exception
	if @cgi then
		print @cgi.header( 'status' => CGI::HTTP_STATUS['SERVER_ERROR'], 'type' => 'text/html' )
	else
		print "Status: 500 Internal Server Error\n"
		print "Content-Type: text/html\n\n"
	end
	puts "<h1>500 Internal Server Error</h1>"
	puts "<pre>"
	puts CGI::escapeHTML( "#{$!} (#{$!.class})" )
	puts ""
	puts CGI::escapeHTML( $@.join( "\n" ) )
	puts "</pre>"
	puts "<div>#{' ' * 500}</div>"
end

