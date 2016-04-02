#
# 05referer.rb: load/save and show today's referer plugin
#
# Copyright (C) 2005, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2 or any later version.
#

#
# saving referer
#
add_header_proc do
	referer_save_trigger
	''
end

def referer_save_trigger
	return unless @conf.io_class.to_s == 'TDiary::IO::Default'
	return unless @mode =~ /^(latest|day|edit|append|replace)$/

	if @date then
		diary = @diaries[@date.strftime( '%Y%m%d' )]
		diary.clear_referers if diary
	end
	referer_update( diary )
end

#
# fake diary class for volatile referer
#
class RefererDiary
	include ::TDiary::RefererManager

	def initialize( keep )
		init_referers
		@keep = keep
		@current_date = nil
		@refs = {}
	end

	# return Time object
	def date
		if @current_date then
			Time::local( *(@current_date.scan( /^(\d{4})(\d\d)(\d\d)$/ )[0]) )
		else
			@date
		end
	end

	# date as String 'YYYYMMDD'
	def current_date=( d )
		@current_date = d
		@refs[d] ||= {} if d
	end

	alias :add_referer_orig :add_referer
	def add_referer( ref, count = 1 )
		return nil unless ref
		current = @current_date || @refs.keys.sort[-1] || '00000101'
		ref_info = add_referer_orig( ref, count )
		uref = CGI::unescape( ref )
		@refs[current] ||= {}
		if pair = @refs[current][uref] then
			@refs[current][uref] = [pair[0] + count, ref_info[1]]
		else
			@refs[current][uref] = [count, ref_info[1]]
		end
	end

	def clear_oldest_referer( newest )
		return if (@refs.keys.sort[-1] || '') > newest
		@refs[newest] = {} unless @refs[newest]
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
		@refs.keys.sort.each do |d|
			@current_date = d
			yield( self )
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
	# ignore an invalid URL including a non-ASCII character
	return if @cgi.referer && !@cgi.referer.match(/^[!-~]+$/)

	@referer_volatile = RefererDiary::new( @conf.latest_limit )

	case @mode
	when 'latest'
		if @cgi.referer and !@conf.referer_day_only then
			referer_load_volatile( @referer_volatile )
			referer_save_volatile( @referer_volatile, @cgi.referer )
		end

	when 'day'
		if diary
			referer_load_current( diary )
			referer_save_current( diary, @cgi.referer )
			if latest_day?( diary ) then
				referer_load_volatile( @referer_volatile )
			elsif @cgi.referer
				referer_load_volatile( @referer_volatile )
				referer_save_volatile( @referer_volatile, @cgi.referer )
			end
		end

	when "edit"
		referer_load_current( diary )
		referer_load_volatile( @referer_volatile ) if latest_day?( diary )

	when /^(append|replace)$/
		referer_load_volatile( @referer_volatile )
		@referer_volatile.clear_oldest_referer( @date.strftime( '%Y%m%d' ) )
		referer_save_volatile( @referer_volatile, nil )
	end
end

def referer_file_name( diary )
	diary.date.strftime( "#{@conf.data_path}%Y/%Y%m%d.tdr" )
end

def referer_volatile_file_name
	"#{@conf.data_path}volatile.tdr"
end

def referer_load( file, diary )
	begin
		File::open( file, 'rb' ) do |fh|
			fh.flock( File::LOCK_SH )
			fh.gets # read magic
			fh.read.split( /\r?\n\.\r?\n/ ).each do |l|
				headers, body = @conf.io_class.parse_tdiary( l )
				yield( headers, @conf.to_native( body ) )
			end
		end
	rescue Errno::ENOENT
	end
end

def referer_add_to_diary( diary, body )
	return unless body
	body.lines.each do |r|
		count, ref = r.chomp.split( / /, 2 )
		next unless ref
		diary.add_referer( ref.chomp, count.to_i )
	end
end

def referer_load_current( diary )
	return unless diary
	referer_load( referer_file_name( diary ), diary ) do |headers, body|
		referer_add_to_diary( diary, body )
	end
end

def referer_load_volatile( diary )
	referer_load( referer_volatile_file_name, diary ) do |headers, body|
		diary.current_date = headers['Date']
		referer_add_to_diary( diary, body )
	end
	diary.current_date = nil
end

def referer_save( file, diary )
	File::open( file, File::WRONLY | File::CREAT ) do |fh|
		fh.flock( File::LOCK_EX )
		fh.rewind
		fh.truncate( 0 )
		fh.puts( ::TDiary::TDIARY_MAGIC )
		yield( fh )
	end
end

def referer_write_from_diary( fh, diary )
	fh.puts( "Date: #{diary.date.strftime( '%Y%m%d' )}\n\n" )
	diary.each_referer( diary.count_referers ) do |count,ref|
		fh.puts( "#{count} #{ref}" )
	end
	fh.puts( '.' )
end

def referer_save_current( diary, referer )
	return unless referer

	# checking only volatile list
	ref = CGI::unescape( referer.sub( /#.*$/, '' ).sub( /\?\d{8}$/, '' ) )
	@conf.only_volatile.each do |volatile|
		return if /#{volatile}/i =~ ref
	end

	diary.add_referer( referer )
	referer_save( referer_file_name( diary ), diary ) do |fh|
		referer_write_from_diary( fh, diary )
	end
end

def referer_save_volatile( diary, referer )
	# to prevend the increase in file size
	return if diary.count_referers > 10000
	diary.add_referer( referer ) if referer
	referer_save( referer_volatile_file_name, diary ) do |fh|
		diary.each_date do |date|
			referer_write_from_diary( fh, diary )
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
			result << %Q[<li>#{count} <a rel="nofollow" href="#{h ref}">#{h disp_referer( @conf.referer_table, ref )}</a></li>\n]
		end
		result << '</ul>'
	end

	if @referer_volatile and latest_day?( diary ) and @referer_volatile.count_referers != 0 then
		result << %Q[<div class="caption">#{volatile_referer}</div>\n]
		result << %Q[<ul>\n]
		@referer_volatile.each_referer( limit ) do |count,ref|
			result << %Q[<li>#{count} <a rel="nofollow" href="#{h ref}">#{h disp_referer( @conf.referer_table, ref )}</a></li>\n]
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
		@conf.to_native( @cgi.params['no_referer'][0] ).lines.each do |ref|
			ref.strip!
			no_referer2 << ref if ref.length > 0
		end
		@conf.no_referer2 = no_referer2

		only_volatile2 = []
		@conf.to_native( @cgi.params['only_volatile'][0] ).lines.each do |ref|
			ref.strip!
			only_volatile2 << ref if ref.length > 0
		end
		@conf.only_volatile2 = only_volatile2

		referer_table2 = []
		@conf.to_native( @cgi.params['referer_table'][0] ).lines.each do |pair|
			u, n = pair.sub( /[\r\n]+/, '' ).split( /[ \t]+/, 2 )
			referer_table2 << [u,n] if u and n
		end
		@conf.referer_table2 = referer_table2
	end
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
