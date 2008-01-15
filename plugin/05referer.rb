#
# 01referer.rb: load/save and show today's referer plugin
# $Revision: 1.13 $
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
	return if @conf.referer_day_only and @mode == 'latest'
	return if @mode !~ /^latest|day|form|edit|append|replace$/

	if @date then
		diary = @diaries[@date.strftime( '%Y%m%d' )]
		if diary then
			diary.clear_referers
			referer_update( diary )
		end
	end
end

class RefererDiary
	include ::TDiary::RefererManager

	def initialize( keep )
		init_referers
		@keep = keep
		@current_date = nil
		@refs = {}
	end

	def current_date=( date )
		@current_date = date
	end

	alias :add_referer_orig :add_referer
	def add_referer( ref, count = 1 )
		return nil unless ref
		current = @current_date || @refs.keys.sort[-1] || '00000000'
		ref_info = add_referer_orig( ref, count )
		uref = CGI::unescape( ref )
		@refs[current] = {} unless @refs[current]
		if pair = @refs[current][uref] then
			@refs[current][uref] = [pair[0] + count, ref_info[1]]
		else
			@refs[current][uref] = [count, ref_info[1]]
		end
	end

	def referer_clear_oldest( newest )
		return if (@refs.keys.sort[-1] || '') > newest
		@refs[newest] = {}
		return if @refs.keys.size <= @keep
		@refs.delete( @refs.keys.sort[0] )
	end

	alias :each_referer_orig :each_referer
	def each_referer( limit = 10 )
		if @current_date then
			@refs[@current_date].values.sort.reverse.each_with_index do |ary,idx|
				break if idx >= limit
				yield( ary[0], ary[1] )
         end
		else
			each_referer_orig( limit ) do |count, ref|
				yield( count, ref )
			end
		end
	end

	def each_date
		@refs.keys.sort.each do |date|
			yield( date )
		end
	end
end

def latest_day?( diary )
	return false unless diary
	y = @years.keys.sort[-1]
	m = @years[y].sort[-1]
	diary.date.year == y.to_i and diary.date.month == m.to_i and diary.date.day == @diaries.keys.sort[-1][6,2].to_i
end

def referer_update( diary )
	# checking saving conditions
	only_volatile = false
	if @cgi.referer then
		ref = CGI::unescape( @cgi.referer.sub( /#.*$/, '' ).sub( /\?\d{8}$/, '' ) )
		@conf.only_volatile.each do |volatile|
			if /#{volatile}/i =~ ref then
				only_volatile = true
				break
			end
		end
	end

	save_current = save_volatile = false
	if @cgi.referer then
		if @mode == 'day' then
			if latest_day?( diary ) then
				if only_volatile then
					save_volatile = true
				else
					save_current = true
				end
			else
				save_volatile = true
				save_current = true unless only_volatile
			end
		elsif @mode == 'latest'
			save_volatile = true
		end
	end

	# load and save referers of current day
	if referer_load( diary ) or save_current then
		diary.add_referer( @cgi.referer )
		referer_save( diary )
	end

	# load and save volatile
	@referer_volatile = RefererDiary::new( @conf.latest_limit )
	if referer_load( @referer_volatile ) or save_volatile then
		@referer_volatile.add_referer( @cgi.referer )
		referer_save( @referer_volatile )
	end
end

def referer_file_name( diary )
	if diary.respond_to?( :date ) then
		diary.date.strftime( "#{@conf.data_path}%Y/%Y%m%d.tdr" )
	else
		"#{@conf.data_path}volatile.tdr"
	end
end

#
# return boolean: force save on next chance
#
def referer_load( diary = nil, save = false )
	return if @conf.io_class.to_s != 'TDiary::DefaultIO'

	volatile = !diary.respond_to?( :date )
	ymd = nil
	file = referer_file_name( diary )

	begin
		File::open( file, 'r' ) do |fh|
			fh.flock( File::LOCK_SH )
			fh.gets # read magic
			fh.read.split( /\r?\n\.\r?\n/ ).each do |l|
				headers, body = ::TDiary::parse_tdiary( l )
				diary.current_date = headers['Date'] if volatile
				next unless body
				body.each do |r|
					count, ref = r.chomp.split( / /, 2 )
					next unless ref
					diary.add_referer( ref.chomp, count.to_i )
				end
			end
		end
	rescue Errno::ENOENT
	end
	diary.current_date = nil if volatile

	if @mode =~ /^(append|replace)$/ and volatile then
		diary.referer_clear_oldest( @date.strftime( '%Y%m%d' ) )
		return true
	else
		return false
	end
end

def referer_save( diary )
	volatile = !diary.respond_to?( :date )
	ymd = (volatile ? Time::now : diary.date).strftime( '%Y%m%d' )
	file = referer_file_name( diary )

	File::open( file, File::WRONLY | File::CREAT ) do |fh|
		fh.flock( File::LOCK_EX )
		fh.rewind
		fh.truncate( 0 )
		fh.puts( ::TDiary::TDIARY_MAGIC )
		if volatile then
			diary.each_date do |date|
				diary.current_date = date
				fh.puts( "Date: #{date}\n\n" )
				diary.each_referer( diary.count_referers ) do |count,ref|
					fh.puts( "#{count} #{ref}" )
				end
				fh.puts( '.' )
			end
			diary.current_date = nil
		else
			fh.puts( "Date: #{ymd}\n\n" )
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
	''
end

def referer_of_today_long( diary, limit )
	return '' if bot?
	result = ''

	if diary and diary.count_referers != 0 then
		result << %Q[<div class="caption">#{referer_today}</div>\n]
		result << %Q[<ul>\n]
		diary.each_referer( limit ) do |count,ref|
			result << %Q[<li>#{count} <a rel="nofollow" href="#{h ref}">#{h disp_referer( @referer_table, ref )}</a></li>\n]
		end
		result << '</ul>'
	end

	if @referer_volatile and latest_day?( diary ) and @referer_volatile.count_referers != 0 then
		result << %Q[<div class="caption">#{volatile_referer}</div>\n]
		result << %Q[<ul>\n]
		@referer_volatile.each_referer( limit ) do |count,ref|
			result << %Q[<li>#{count} <a rel="nofollow" href="#{h ref}">#{h disp_referer( @referer_table, ref )}</a></li>\n]
		end
		result << '</ul>'
	end
	result
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

