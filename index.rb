#!/usr/bin/env ruby
#
# index.rb $Revision: 1.18 $
#
# Copyright (C) 2001-2003, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#
$KCODE= 'e'
BEGIN { $defout.binmode }

begin
	if FileTest::symlink?( __FILE__ ) then
		org_path = File::dirname( File::readlink( __FILE__ ) )
	else
		org_path = File::dirname( __FILE__ )
	end
	$:.unshift( org_path.untaint )
	require 'tdiary'

	@cgi = CGI::new
	conf = TDiary::Config::new
	tdiary = nil
	status = nil
	if %r[/\d{4,8}\.html?$] =~ ENV['REDIRECT_URL'] and not @cgi.valid?( 'date' ) then
		@cgi.params['date'] = [ENV['REDIRECT_URL'].sub( /.*\/(\d+)\.html$/, '\1' )]
		status = '200 OK'
	end

	begin
		if @cgi.valid?( 'comment' ) then
			tdiary = TDiary::TDiaryComment::new( @cgi, "day.rhtml", conf )
		elsif @cgi.valid?( 'date' )
			date = @cgi.params['date'][0]
			if /^\d{8}$/ =~ date then
				tdiary = TDiary::TDiaryDay::new( @cgi, "day.rhtml", conf )
			elsif /^\d{6}$/ =~ date then
				tdiary = TDiary::TDiaryMonth::new( @cgi, "month.rhtml", conf )
			elsif /^\d{4}$/ =~ date then
				tdiary = TDiary::TDiaryNYear::new( @cgi, "month.rhtml", conf )
			end
		elsif @cgi.valid?( 'category' )
			if @cgi.valid?( 'month' )
				if @cgi.params['month'][0] == 'ALL'
					tdiary = TDiary::TDiaryCategoryYear::new( @cgi, "category.rhtml", conf )
				else
					tdiary = TDiary::TDiaryCategoryMonth::new( @cgi, "category.rhtml", conf )
				end
			elsif @cgi.valid?( 'year' )
				tdiary = TDiary::TDiaryCategoryYear::new( @cgi, "category.rhtml", conf )
			else
				tdiary = TDiary::TDiaryCategoryLatest::new( @cgi, "category.rhtml", conf )
			end
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
		if @cgi.mobile_agent? then
			body = tdiary.eval_rhtml( 'i.' ).to_sjis
			head['charset'] = conf.charset( true )
			head['Content-Length'] = body.size.to_s
		else
			body = tdiary.eval_rhtml
			head['charset'] = conf.charset
			head['Content-Length'] = body.size.to_s
			head['Pragma'] = 'no-cache'
			head['Cache-Control'] = 'no-cache'
		end
		head['cookie'] = tdiary.cookies if tdiary.cookies.size > 0
		head['Last-Modified'] = CGI::rfc1123_date( tdiary.last_modified )

		# ETag testing code
		#require 'md5'
		#head['ETag'] = MD5::md5( body )

		print @cgi.header( head )
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
			<meta http-equiv="refresh" content="0;url=#{$!.path}">
			<title>moving...</title>
			</head>
			<body>Wait or <a href="#{$!.path}">Click here!</a></body>
			</html>]
	end
rescue Exception
	print "Content-Type: text/plain\n\n"
	puts "#$! (#{$!.class})"
	puts ""
	puts $@.join( "\n" )
end

