#!/usr/bin/env ruby
$KCODE= 'e'
#
# convert2: convert diary data file format tDiary1 to tDiary2. $Revision: 1.6 $
#
# Copyright (C) 2001,2002, All right reserved by TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.

=begin How to usage
ruby convert2.rb [-p <tDiary path>] [-c <tdiary.conf path>]

-p <tDiary path>     : tDiaryのインストールパス。未指定時はカレントディレクトリ
                       例: -p /usr/local/tdiary
-c <tdiary.conf path>: tdiary.confが存在するパス。未指定時はカレントディレクトリ
                       例: -c /home/hoge/public_html/diary
=end

=begin ChangeLog
2002-10-08 TADA Tadashi <sho@spc.gr.jp>
	* for tDiary 1.5.0.20021003.

2002-08-16 TADA Tadashi <sho@spc.gr.jp>
	* follow new IO classes specification.

2002-07-25 TADA Tadashi <sho@spc.gr.jp>
	* display progress.

2002-07-23 TADA Tadashi <sho@spc.gr.jp>
	* fix some bugs.

2002-05-30 TADA Tadashi <sho@spc.gr.jp>
	* created.
=end

def usage
	puts "convert2: convert diary data file format tDiary1 to tDiary2."
	puts "usage: ruby convert2.rb [-p <tDiary path>] [-c <tdiary.conf path>]"
	exit
end

require 'getoptlong'
parser = GetoptLong::new
tdiary_path = '.'
tdiary_conf = nil
parser.set_options(
	['--path', '-p', GetoptLong::REQUIRED_ARGUMENT],
	['--conf', '-c', GetoptLong::REQUIRED_ARGUMENT]
)
begin
	parser.each do |opt, arg|
		case opt
		when '--path'
			tdiary_path = arg
		when '--conf'
			tdiary_conf = arg
		else
			usage
		end
	end
rescue
	usage
end

tdiary_conf = tdiary_path unless tdiary_conf
Dir::chdir( tdiary_conf )

begin
	ARGV << '' # dummy argument against cgi.rb offline mode.
	$:.unshift tdiary_path
	require "#{tdiary_path}/tdiary"
rescue LoadError
	$stderr.puts 'convert.rb: cannot load tdiary.rb. try -p option.'
	exit
end


module TDiary
	class TDiaryConvert2 < TDiaryBase
		def initialize
			super( nil, 'day.rhtml', Config::new )
			require "#{PATH}/tdiary/pstoreio"
			@io_old = PStoreIO::new( self )
			@years = @io_old.calendar
			@years.keys.sort.each do |year|
				@years[year.to_s].sort.each do |month|
					puts "#{year}-#{month}"
					date = Time::local( year.to_i, month.to_i )
					@io_old.transaction( date ) do |diaries|
						@diaries = diaries
						false
					end
	
					require 'tdiary/defaultio'
					DefaultIO::new( self ).transaction( date ) do |diaries|
						diaries.update( @diaries )
						TDiaryBase::DIRTY_DIARY | TDiaryBase::DIRTY_COMMENT | TDiaryBase::DIRTY_REFERER
					end
					clear_parser_cache( date )
				end
			end
		end
	
	protected
		def cookie_name
			''
		end
	
		def cookie_mail
			''
		end
	end
end

TDiary::TDiaryConvert2::new

