#!/usr/bin/env ruby
# -*- coding: utf-8; -*-
#
# update.rb
#
# Copyright (C) 2001-2009, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2.
#
BEGIN { $stdout.binmode }

begin
	if FileTest::symlink?( __FILE__ ) then
		org_path = File::dirname( File::readlink( __FILE__ ) ).untaint
	else
		org_path = File::dirname( __FILE__ ).untaint
	end
	$:.unshift( org_path ) unless $:.include?( org_path )
	require 'tdiary'

	encoding_error = {}
	cgi = CGI::new(accept_charset: "UTF-8") do |name, value|
		encoding_error[name] = value
	end
	if encoding_error.empty?
		@cgi = cgi
	else
		@cgi = CGI::new(accept_charset: 'shift_jis')
		@cgi.params = cgi.params.dup
	end

	request = TDiary::Request.new( ENV, @cgi )
	status, headers, body = TDiary::Dispatcher.update.dispatch_cgi( request, @cgi )

	TDiary::Dispatcher.send_headers( status, headers )
	::Rack::Handler::CGI.send_body(body)
rescue Exception
	if @cgi then
		print @cgi.header( 'status' => '500 Internal Server Error', 'type' => 'text/html' )
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
