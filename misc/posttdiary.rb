#!/usr/bin/env ruby
$KCODE= 'e'
#
# posttdiary: update tDiary via e-mail. $Revision: 1.1 $
#
# Copyright (C) 2002, All right reserved by TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.

=begin ChangeLog
2002-01-12 TADA Tadashi <sho@spc.gr.jp>
	* version 0.9.1
	* support null subject.

2002-01-12 TADA Tadashi <sho@spc.gr.jp>
	* version 0.9.0
=end

def usage
	"posttdiary.rb: updte tDiary via e-mail.\n" +
	"usage: ruby posttdiary.rb <url> [user] [passwd]"
end

begin
	raise usage if ARGV.length < 1
	url = ARGV.shift
	if %r|http://([^:/]*):?(\d*)(/.*)| =~ url then
		host = $1
		port = $2.to_i
		cgi = $3
		raise 'bad url.' if not host or not cgi
		port = 80 if port == 0
	else
		raise 'bad url.'
	end
	
	user = ARGV.shift
	pass = ARGV.shift
	
	mail = ARGF.read
	raise "no mail text." if not mail or mail.length == 0
	
	head, body = mail.split( "\n\n", 2 )
	raise "no text in mail." if /^Content-Type:\s*text\/plain/ !~ head

	addr = nil
	if /^To:(.*)$/ =~ head then
		to = $1.strip
		if /.*?\s*<(.*)>/ =~ to then
			addr = $1
		elsif /(.*?)\s*\(.*\)/ =~ to
			addr = $1
		else
			addr = to
		end
	end

	if /([^-]+)-(.*)@/ =~ addr then
		user = $1 unless user
		pass = $2 unless pass
	end

	raise "no user." unless user
	raise "no passwd." unless pass

	title = ''
	if /^Subject:(.*)$/ =~ head then
		title = $1.strip
	end

	require 'cgi'
	require 'nkf'
	now = Time::now
	data = "year=#{now.year}"
	data << "&month=#{now.month}"
	data << "&day=#{now.day}"
	data << "&title=#{CGI::escape NKF::nkf( '-eXd', title )}"
	data << "&body=#{CGI::escape NKF::nkf( '-m0 -eXd', body )}"
	data << "&append=true"

	require 'net/http'
	Net::HTTP.start( host, port ) do |http|
		auth = ["#{user}:#{pass}"].pack( 'm' ).strip
		res, = http.post( cgi, data, 'Authorization' => "Basic #{auth}" )
	end
rescue
	$stderr.puts $!
	exit 1
end

