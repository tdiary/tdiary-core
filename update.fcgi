#!/usr/bin/env ruby
#
# update.fcgi
#
# Copyright (C) 2004, Akinori MUSHA
# Copyright (C) 2006, moriq
# Copyright (C) 2011, Kazuhiko <kazuhiko@fdiary.net>
# You can redistribute it and/or modify it under GPL2 or any later version.
#
BEGIN { $stdout.binmode }

if FileTest::symlink?( __FILE__ ) then
	org_path = File::dirname( File::readlink( __FILE__ ) )
else
	org_path = File::dirname( __FILE__ )
end
$:.unshift( org_path + '/lib' ) unless $:.include?( org_path + '/lib' )
require 'tdiary'
require 'tdiary/cgi_hosting_adapter'
require 'fcgi'

dispatcher = TDiary::Dispatcher.update
if FCGI::is_cgi? then
	dir = File::dirname( ENV['SCRIPT_FILENAME'] || __FILE__ )
	Dir.chdir( dir ) do
		TDiary::CGIHostingAdapter.run_cgi( dispatcher )
	end
else
	FCGI::each do |request|
		dir = File::dirname( request.env['SCRIPT_FILENAME'] || __FILE__ )
		Dir.chdir( dir ) do
			TDiary::CGIHostingAdapter.run( request, dispatcher )
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
