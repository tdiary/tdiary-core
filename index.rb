#!/usr/bin/env ruby
# -*- coding: ascii-8bit; -*-
#
# index.rb
#
# Copyright (C) 2001-2009, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2 or any later version.
#
BEGIN { $stdout.binmode }

begin
	if FileTest::symlink?( __FILE__ ) then
		org_path = File::dirname( File::readlink( __FILE__ ) )
	else
		org_path = File::dirname( __FILE__ )
	end
	$:.unshift( (org_path + '/lib') ) unless $:.include?( org_path + '/lib' )
	require 'tdiary'
	require 'tdiary/cgi_hosting_adapter'

	TDiary::CGIHostingAdapter.run_cgi( TDiary::Dispatcher.index )
rescue Exception
	print "Status: 500 Internal Server Error\n"
	print "content-type: text/html\n\n"
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
