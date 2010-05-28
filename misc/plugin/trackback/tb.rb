#!/usr/bin/env ruby
# tb.rb
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
# derived from sheepman's tb.rb. Thanks to sheepman <sheepman@tcn.zaq.ne.jp>
# 

BEGIN { $stdout.binmode }
$KCODE = 'n'

begin
	if FileTest::symlink?( __FILE__ ) then
		org_path = File::dirname( File::readlink( __FILE__ ) )
	else
		org_path = File::dirname( __FILE__ )
	end
	$:.unshift org_path.untaint
	require 'tdiary'
  
	@cgi = CGI::new
	conf = TDiary::Config::new( @cgi )
	tdiary = nil

	begin
		if /POST/i =~ @cgi.request_method and @cgi.valid?( 'url' ) and
			   ! @cgi.referer and /^Mozilla\// !~ @cgi.user_agent then
			tdiary = TDiary::TDiaryTrackBackReceive::new( @cgi, 'day.rhtml', conf )
		end
	rescue TDiary::TDiaryError
	end

	tdiary = TDiary::TDiaryTrackBackShow::new( @cgi, nil, conf ) unless tdiary
	begin
		body = tdiary.eval_rhtml
		head = {
			'type' => 'text/xml',
			'charset' => conf.encoding,
			'Content-Length' => body.size.to_s
		}
		print @cgi.header( head )
		print body
	rescue TDiary::TDiaryTrackBackError
		print @cgi.header( { 'type' => 'text/xml' } )
		print TDiary::TDiaryTrackBackBase::fail_response( $!.message )
	rescue TDiary::ForceRedirect
		head = { 'type' => 'text/html' }
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

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
