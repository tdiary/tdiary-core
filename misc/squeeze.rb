#!/usr/bin/env ruby
$KCODE= 'e'
#
# squeeze: make HTML text files from tDiary's database. $Revision: 1.1 $
#
# Copyright (C) 2001,2002, All right reserved by TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.

=begin ChangeLog
2002-01-12 TADA Tadashi <sho@spc.gr.jp>
	* version 1.0.2
	* fix usage.
2001-12-21 TADA Tadashi <sho@spc.gr.jp>
	* version 1.0.1
	* follow changing spacification of TDiary#transaction.
2001-11-26 TADA Tadashi <sho@spc.gr.jp>
	* version 1.0.0
=end

def usage
	puts "squeeze: making html files from tDiary's database."
	puts "usage: ruby squeeze.rb [-p <tDiary path>] <dest path>"
	exit
end

require 'getoptlong'
parser = GetoptLong::new
tdiary_path = nil
parser.set_options( ['--path', '-p', GetoptLong::REQUIRED_ARGUMENT] )
begin
	parser.each do |opt, arg|
		tdiary_path = arg if opt == '--path'
	end
rescue
	usage
end
dest = ARGV.shift
usage unless dest
dest = File::expand_path( dest )
dest += '/' if /\/$/ !~ dest
Dir::chdir( tdiary_path ) if tdiary_path

begin
	require 'tdiary'
rescue LoadError
	$stderr.puts 'squeeze.rb: cannot load tdiary.rb. try -p option.'
	exit
end

class TDiarySqueeze < TDiary
	def initialize( dest )
		super( nil, 'day.rhtml' )
		make_years
		@years.keys.sort.each do |year|
			@years[year.to_s].sort.each do |month|
				transaction( Time::local( year.to_i, month.to_i ) ) do |diaries|
					diaries.each do |day,diary|
						@diary = diary
						@date = @diary.date
						file = "#{dest}#{day}"
						if not FileTest::exist?( file ) or File::mtime( file ) < @diary.last_modified then
							puts file
							File::open( file, 'w' ) do |f| f.write( eval_rhtml ) end
						end
					end
					false
				end
			end
		end
	end

protected
	def title
		t = @html_title
		t += "(#{@diary.date.strftime( '%Y-%m-%d' )})" if @diary
		t
	end

	def cookie_name
		''
	end

	def cookie_mail
		''
	end
end

TDiarySqueeze::new( dest )

