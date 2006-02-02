#
# 01referer.rb: load/save and show today's referer plugin
# $Revision: 1.1 $
#
# Copyright (C) 2005, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#

#
# saving referer
#
add_header_proc do
	referer_save_trigger
	''
end

def referer_save_trigger
	return if @conf.io_class != TDiary::DefaultIO
	return if @mode !~ /^day|form|edit|append|replace$/

	if @date then
		diary = @diaries[@date.strftime( '%Y%m%d' )]
		referer_save( diary ) if diary
	end
end

class RefererDiary
	include TDiary::RefererManager
	def initialize
		init_referers
	end
end

def latest_day?( diary )
	y = @years.keys.sort[-1]
	m = @years[y].sort[-1]
	diary.date.year == y.to_i and diary.date.month == m.to_i and diary.date.day == @diaries.keys.sort[-1][6,2].to_i
end

def referer_save( diary )
	# save to volatile only?
	save = false
	ref = CGI::unescape( @cgi.referer.sub( /#.*$/, '' ).sub( /\?\d{8}$/, '' ) )
	@conf.only_volatile.each do |volatile|
		if /#{volatile}/i =~ ref then
			save = true
			break
		end
	end

	# load and save volatile
	@referer_volatile = RefererDiary::new
	if !save and @cgi.referer and !latest_day?( diary ) then
		save = true
	end
	@referer_volatile.add_referer( @cgi.referer ) if save
	referer_transaction( @referer_volatile, save ) do |ref, count|
		@referer_volatile.add_referer( ref, count )
	end

	# load and save referers of current day
	if !save and @cgi.referer and @mode == 'day' then
		diary.add_referer( @cgi.referer )
		save = true
	end
	referer_transaction( diary, save ) do |ref, count|
		diary.add_referer( ref, count )
	end
end

def referer_transaction( diary = nil, save = false )
	if diary.respond_to?( :date ) then
		file = diary.date.strftime( "#{@conf.data_path}%Y/%Y%m%d.tdr" )
	else
		file = "#{@conf.data_path}volatile.tdr"
	end
	ymd = nil

	begin
		File::open( file, 'r' ) do |fh|
			fh.flock( File::LOCK_SH )
			fh.gets # read magic
			fh.read.split( /\r?\n\.\r?\n/ ).each do |l|
				headers, body = TDiary::parse_tdiary( l )
				ymd = headers['Date']
				next unless body
				body.each do |r|
					count, ref = r.chomp.split( / /, 2 )
					next unless ref
					yield( ref.chomp, count.to_i )
				end
			end
		end
	rescue Errno::ENOENT
	end

	if @mode =~ /^(append|replace)$/ and !diary.respond_to?( :date ) then
		if !ymd or (@date.strftime( '%Y%m%d' ) > ymd) then
			ymd = nil
			diary.clear_referers
			save = true
		end
	end

	if save then
		unless ymd then
			ymd = (@date ? @date : Time::now).strftime( '%Y%m%d' )
		end
		File::open( file, File::WRONLY | File::CREAT ) do |fh|
			fh.flock( File::LOCK_EX )
			fh.rewind
			fh.truncate( 0 )
			fh.puts( TDiary::TDIARY_MAGIC )
			fh.puts( "Date: #{ymd}" )
			fh.puts 
			diary.each_referer( diary.count_referers ) do |count,ref|
				fh.puts( "#{count} #{ref}" )
			end
			fh.puts( '.' )
		end
	end
end

#
# referer of today
#
def referer_of_today_short( diary, limit )
#	return '' if not diary or diary.count_referers == 0 or bot?
#	result = %Q[#{referer_today} | ]
#	diary.each_referer( limit ) do |count,ref|
#		result << %Q[<a href="#{CGI::escapeHTML( ref )}" title="#{CGI::escapeHTML( disp_referer( @referer_table, ref ) )}">#{count}</a> | ]
#	end
#	result
	''
end

def referer_of_today_long( diary, limit )
	return '' if not diary or diary.count_referers == 0 or bot?
	result = %Q[<div class="caption">#{referer_today}</div>\n]
	result << %Q[<ul>\n]
	diary.each_referer( limit ) do |count,ref|
		result << %Q[<li>#{count} <a href="#{CGI::escapeHTML( ref )}">#{CGI::escapeHTML( disp_referer( @referer_table, ref ) )}</a></li>\n]
	end
	result << '</ul>'

	return result unless latest_day?( diary ) and @referer_volatile.count_referers != 0

	result << %Q[<div class="caption">#{volatile_referer}</div>\n]
	result << %Q[<ul>\n]
	@referer_volatile.each_referer( limit ) do |count,ref|
		result << %Q[<li>#{count} <a href="#{CGI::escapeHTML( ref )}">#{CGI::escapeHTML( disp_referer( @referer_table, ref ) )}</a></li>\n]
	end
	result << '</ul>'
end

#
# referer preference
#
def saveconf_referer
	if @mode == 'saveconf' then
		@conf.show_referer = @cgi.params['show_referer'][0] == 'true' ? true : false

		no_referer2 = []
		@conf.to_native( @cgi.params['no_referer'][0] ).each do |ref|
			ref.strip!
			no_referer2 << ref if ref.length > 0
		end
		@conf.no_referer2 = no_referer2

		only_volatile2 = []
		@conf.to_native( @cgi.params['only_volatile'][0] ).each do |ref|
			ref.strip!
			only_volatile2 << ref if ref.length > 0
		end
		@conf.only_volatile2 = only_volatile2

		referer_table2 = []
		@conf.to_native( @cgi.params['referer_table'][0] ).each do |pair|
			u, n = pair.sub( /[\r\n]+/, '' ).split( /[ \t]+/, 2 )
			referer_table2 << [u,n] if u and n
		end
		@conf.referer_table2 = referer_table2
	end
end

