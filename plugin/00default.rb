#
# 00default.rb: default plugins 
# $Revision: 1.68 $
#

#
# make navigation buttons
#
def navi
	result = %Q[<div class="adminmenu">\n]
	result << navi_user
	result << navi_admin
	result << %Q[</div>]
end

def navi_user
	result = ''
	result << %Q[<span class="adminmenu"><a href="#{@index_page}">#{navi_index}</a></span>\n] unless @index_page.empty?
	if @mode == 'day' then
		if @prev_day then
			result << %Q[<span class="adminmenu"><a href="#{@index}#{anchor @prev_day}">&laquo;#{navi_prev_diary Time::local(*@prev_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0])}</a></span>\n]
		end

		result << %Q[<span class="adminmenu"><a href="#{@index}">#{navi_latest}</a></span>\n] unless @mode == 'latest'

		if @next_day
			result << %Q[<span class="adminmenu"><a href="#{@index}#{anchor @next_day}">#{navi_next_diary Time::local(*@next_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0])}&raquo;</a></span>\n]
		end
	elsif @mode == 'nyear'
		result << %Q[<span class="adminmenu"><a href="#{@index}#{anchor @prev_day[4,4]}">&laquo;#{navi_prev_nyear Time::local(*@prev_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0])}</a></span>\n] if @prev_day
		result << %Q[<span class="adminmenu"><a href="#{@index}">#{navi_latest}</a></span>\n] unless @mode == 'latest'
		result << %Q[<span class="adminmenu"><a href="#{@index}#{anchor @next_day[4,4]}">#{navi_next_nyear Time::local(*@next_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0])}&raquo;</a></span>\n] if @next_day
	else
		result << %Q[<span class="adminmenu"><a href="#{@index}">#{navi_latest}</a></span>\n] unless @mode == 'latest'
	end
	result
end

def navi_admin
	if @mode == 'day' then
		result = %Q[<span class="adminmenu"><a href="#{@update}?edit=true;year=#{@date.year};month=#{@date.month};day=#{@date.day}">#{navi_edit}</a></span>\n]
	else
		result = %Q[<span class="adminmenu"><a href="#{@update}">#{navi_update}</a></span>\n]
	end
	result << %Q[<span class="adminmenu"><a href="#{@update}?conf=default">#{navi_preference}</a></span>\n] if /^(latest|month|day|comment|conf|nyear|category.*)$/ !~ @mode
	result
end

def mobile_navi
	calc_links
	result = []
	i = 1
	if @prev_day
		result << %Q[<A HREF="#{@index}#{anchor @prev_day}" ACCESSKEY="#{i}">[#{i}]#{mobile_navi_prev_diary}</A>]
		i += 1
	end
	if @mode != 'latest'
		result << %Q[<A HREF="#{@index}" ACCESSKEY="#{i}">[#{i}]#{mobile_navi_latest}</A>]
		i += 1
	end
	if @next_day
		result << %Q[<A HREF="#{@index}#{anchor @next_day}" ACCESSKEY="#{i}">[#{i}]#{mobile_navi_next_diary}</A>]
	end
	result << %Q[<A HREF="#{@update}" ACCESSKEY="0">[0]#{mobile_navi_update}</A>]
	result << %Q[<A HREF="#{@update}?conf=default" ACCESSKEY="9">[9]#{mobile_navi_preference}</A>] unless /^(latest|month|day|conf|nyear)$/ === @mode
	result.join('|')
end

#
# make calendar
#
def calendar
	result = %Q[<div class="calendar">\n]
	@years.keys.sort.each do |year|
		result << %Q[<div class="year">#{year}|]
		@years[year.to_s].sort.each do |month|
			m = "#{year}#{month}"
			result << %Q[<a href="#{@index}#{anchor m}">#{month}</a>|]
		end
		result << "</div>\n"
	end
	result << "</div>"
end

#
# insert file. only enable unless @secure.
#
def insert( file )
	begin
		File::readlines( file ).join
	rescue
		%Q[<p class="message">#$! (#{$!.class})<br>cannot read #{file}.</p>]
	end
end

#
# define DOCTYPE
#
def doctype
	%Q[<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">]
end

#
# default HTML header
#
add_header_proc do
	calc_links
	<<-HEADER
	<meta http-equiv="Content-Type" content="text/html; charset=#{charset}">
	<meta name="generator" content="tDiary #{TDIARY_VERSION}">
	#{last_modified_header}
	#{content_script_type}
	#{author_name_tag}
	#{author_mail_tag}
	#{index_page_tag}
	#{css_tag.chomp}
	#{title_tag.chomp}
	HEADER
end

def calc_links
	if @mode == 'day' or (@conf.mobile_agent? and /(latest|month|nyear)/ === @mode) then
		years = []
		@years.each do |k, v|
			v.each do |m|
				years << k + m
			end
		end
		this_month = @date.strftime('%Y%m')
		years |= [this_month]
		years.sort!
		years.unshift(nil).push(nil)
		prev_month, dummy, next_month = years[years.index(this_month) - 1, 3]

		days = []
		if /(latest|month|nyear)/ === @mode
			today = @diaries.keys.sort[-1]
		else
			today = @date.strftime('%Y%m%d')
		end
		days += @diaries.keys
		days |= [today]
		days.sort!
		days.unshift(nil).push(nil)

		days.index( today ).times do |i|
			@prev_day = days[days.index( today ) - i - 1]
			break unless @prev_day
			break if @diaries[@prev_day].visible?
		end
		if not @prev_day and prev_month then
			y, m = prev_month.scan(/(\d{4})(\d\d)/)[0]
			if m == "12"
				y, m = y.to_i + 1, 1
			else
				y, m = y.to_i, m.to_i + 1
			end
			@prev_day = (Time.local(y, m, 1) - 24*60*60).strftime( '%Y%m%d' )
		end

		days.index( today ).times do |i|
			@next_day = days[days.index( today ) + i + 1]
			break unless @next_day
			break if @diaries[@next_day].visible?
		end
		if not @next_day and next_month then
			y, m = next_month.scan(/(\d{4})(\d\d)/)[0]
			@next_day = Time.local(y, m, 1).strftime( '%Y%m%d' )
		end
	elsif @mode == 'nyear'
		y = 2000 # specify leam year
		m, d = @cgi.params['date'][0].scan(/^(\d\d)(\d\d)$/)[0]
		@prev_day = (Time.local(y, m, d) - 24*60*60).strftime( '%Y%m%d' )
		@next_day = (Time.local(y, m, d) + 24*60*60).strftime( '%Y%m%d' )
	end
end

def charset
	if @conf.mobile_agent? then
		@conf.mobile_encoding
	else
		@conf.encoding
	end
end

def last_modified_header
	if @last_modified then
		%Q|<meta http-equiv="Last-Modified" content="#{CGI::rfc1123_date( @last_modified )}">|
	else
		''
	end
end

def content_script_type
	%Q[<meta http-equiv="Content-Script-Type" content="text/javascript; charset=#{charset}">]
end

def author_name_tag
	if @author_name then
		%Q[<meta name="author" content="#{@author_name}">]
	else
		''
	end
end

def author_mail_tag
	if @author_mail then
		%Q[<link rev="made" href="mailto:#{@author_mail}">]
	else
		''
	end
end

def index_page_tag
	result = ''
	if @index_page and @index_page.size > 0 then
		result << %Q[<link rel="index" title="#{navi_index}" href="#{@index_page}">\n\t]
	end
	if @prev_day then
		case @mode
		when 'day'
			result << %Q[<link rel="prev" title="#{navi_prev_diary Time::local(*@prev_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0])}" href="#{@index}#{anchor @prev_day}">\n\t]
		when 'nyear'
			result << %Q[<link rel="prev" title="#{navi_prev_nyear Time::local(*@prev_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0])}" href="#{@index}#{anchor @prev_day[4,4]}">\n\t]
		end
	end
	if @next_day then
		case @mode
		when 'day'
			result << %Q[<link rel="next" title="#{navi_next_diary Time::local(*@next_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0])}" href="#{@index}#{anchor @next_day}">\n\t]
		when 'nyear'
			result << %Q[<link rel="next" title="#{navi_next_nyear Time::local(*@next_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0])}" href="#{@index}#{anchor @next_day[4,4]}">\n\t]
		end
	end
	result << %Q[<link rel="start" title="#{navi_latest}" href="#{@index}">\n\t]
	result.chop.chop
end

def theme_url; 'theme'; end

def css_tag
	if @conf.theme and @conf.theme.length > 0 then
		css = "#{theme_url}/#{@conf.theme}/#{@conf.theme}.css"
		title = css
	else
		css = @css
	end
	title = CGI::escapeHTML( File::basename( css, '.css' ) )
	<<-CSS
<meta http-equiv="content-style-type" content="text/css">
	<link rel="stylesheet" href="#{theme_url}/base.css" type="text/css" media="all">
	<link rel="stylesheet" href="#{css}" title="#{title}" type="text/css" media="all">
	CSS
end

#
# make anchor string
#
def anchor( s )
	if /^(\d+)#?([pct]\d*)?$/ =~ s then
		if $2 then
			"?date=#$1##$2"
		else
			"?date=#$1"
		end
	else
		""
	end
end

#
# make anchor tag in my diary
#
def my( a, str, title = nil )
	date, noise, frag = a.scan( /^(\d{4}|\d{6}|\d{8})([^\d]*)?#?([pct]\d\d)?$/ )[0]
	anc = frag ? "#{date}#{frag}" : date
	if title then
		%Q[<a href="#{@index}#{anchor anc}" title="#{title}">#{str}</a>]
	else
		%Q[<a href="#{@index}#{anchor anc}">#{str}</a>]
	end
end

#
# referer of today
#
def referer_of_today_short( diary, limit )
	return '' if not diary or diary.count_referers == 0
	result = %Q[#{referer_today} | ]
	diary.each_referer( limit ) do |count,ref|
		result << %Q[<a href="#{CGI::escapeHTML( ref )}" title="#{CGI::escapeHTML( disp_referer( @referer_table, ref ) )}">#{count}</a> | ]
	end
	result
end

def referer_of_today_long( diary, limit )
	return '' if not diary or diary.count_referers == 0
	result = %Q[<div class="caption">#{referer_today}</div>\n]
	result << %Q[<ul>\n]
	diary.each_referer( limit ) do |count,ref|
		result << %Q[<li>#{count} <a href="#{CGI::escapeHTML( ref )}">#{CGI::escapeHTML( disp_referer( @referer_table, ref ) )}</a></li>\n]
	end
	result + '</ul>'
end

#
# other resources
#
def submit_command
	if @mode == 'form' or @cgi.valid?( 'appendpreview' ) then
		'append'
	else
		'replace'
	end
end

def preview_command
	if @mode == 'form' or @cgi.valid?( 'appendpreview' ) then
		'appendpreview'
	else
		'replacepreview'
	end
end

#
# nyear
#
def nyear(ymd)
	y, m, d = ymd.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]
	date = Time.local(y, m, d)
	years = @years.find_all {|year, months| months.include? m}
	if @mode != 'nyear' and years.length >= 2
		%Q|[<a href="#{@index}#{anchor m + d}" title="#{nyear_diary_title date, years}">#{nyear_diary_label date, years}</a>]|
	else
		""
	end
end

#
# service methods for comment_mail
#
def comment_mail_send
	return unless @comment
	return unless @conf['comment_mail.enable']

	case @conf['comment_mail.receivers']
	when Array
		# for compatibility
		receivers = @conf['comment_mail.receivers']
	when String
		receivers = @conf['comment_mail.receivers'].split( /[, ]+/ )
	else
		receivers = []
	end
	receivers = [@conf.author_mail] if receivers.compact.empty?
	return if receivers.empty?

	require 'socket'

	name = comment_mail_mime( @conf.to_mail( @comment.name ) )[0]
	body = @conf.to_mail( @comment.body.sub( /[\r\n]+\Z/, '' ) )
	mail = @comment.mail
	mail = @conf.author_mail unless mail =~ %r<[0-9a-zA-Z_.-]+@[\(\)%!0-9a-zA-Z_$@.&+-,'"*-]+>
	
	now = Time::now
	g = now.dup.gmtime
	l = Time::local( g.year, g.month, g.day, g.hour, g.min, g.sec )
	tz = (g.to_i - l.to_i) / 36
	date = now.strftime( "%a, %d %b %Y %X " ) + sprintf( "%+05d", tz )

	serial = @diaries[@date.strftime( '%Y%m%d' )].count_comments( true )
	message_id = %Q!<tdiary.#{[@conf['comment_mail.header'] || ''].pack('m').gsub(/\n/,'')}.#{now.strftime('%Y%m%d%H%M%S')}.#{serial}@#{Socket::gethostname}>!

	mail_header = (@conf['comment_mail.header'] || '').dup
	mail_header << ":#{@conf.date_format}" unless /%[a-zA-Z%]/ =~ mail_header
	mail_header = @date.strftime( mail_header )
	mail_header = comment_mail_mime( @conf.to_mail( mail_header ) ).join( "\n " ) if /[\x80-\xff]/ =~ mail_header

	rmail = ''
	begin
		rmail = File::open( "#{::TDiary::PATH}/skel/mail.rtxt.#{@conf.lang}" ){|f| f.read }
	rescue
		rmail = File::open( "#{::TDiary::PATH}/skel/mail.rtxt" ){|f| f.read }
	end
	text = ERbLight::new( rmail.untaint ).result( binding )
	receivers.each { |i| i.untaint }
	comment_mail( text, receivers )
end

def comment_mail( text )
	# no action in default.
	# override by each plugins.
end

def comment_mail_basic_setting
	if @mode == 'saveconf' then
		@conf['comment_mail.enable'] = @cgi.params['comment_mail.enable'][0] == 'true' ? true : false
		@conf['comment_mail.receivers'] = @cgi.params['comment_mail.receivers'][0].strip.gsub( /[\n\r]+/, ',' )
		@conf['comment_mail.header'] = @cgi.params['comment_mail.header'][0]
	end
end

#
# preferences (saving methods)
#

# basic (default)
def saveconf_default
	if @mode == 'saveconf' then
		@conf.author_name = @conf.to_native( @cgi.params['author_name'][0] )
		@conf.author_mail = @cgi.params['author_mail'][0]
		@conf.index_page = @cgi.params['index_page'][0]
		@conf.hour_offset = @cgi.params['hour_offset'][0].to_f
	end
end

# header/footer (header)
def saveconf_header
	if @mode == 'saveconf' then
		@conf.html_title = @conf.to_native( @cgi.params['html_title'][0] )
		@conf.header = @conf.to_native( @cgi.params['header'][0] ).gsub( /\r\n/, "\n" ).gsub( /\r/, '' ).sub( /\n+\z/, '' )
		@conf.footer = @conf.to_native( @cgi.params['footer'][0] ).gsub( /\r\n/, "\n" ).gsub( /\r/, '' ).sub( /\n+\z/, '' )
	end
end

# diaplay
def saveconf_display
	if @mode == 'saveconf' then
		@conf.section_anchor = @conf.to_native( @cgi.params['section_anchor'][0] )
		@conf.comment_anchor = @conf.to_native( @cgi.params['comment_anchor'][0] )
		@conf.date_format = @conf.to_native( @cgi.params['date_format'][0] )
		@conf.latest_limit = @cgi.params['latest_limit'][0].to_i
		@conf.latest_limit = 10 if @conf.latest_limit < 1
		@conf.show_nyear = @cgi.params['show_nyear'][0] == 'true' ? true : false
	end
end

# themes
def saveconf_theme
	# dummy
end

if @mode =~ /^(conf|saveconf)$/ and @cgi.params['conf'][0] == 'theme' then
	if @mode == 'saveconf' then
		@conf.theme = @cgi.params['theme'][0]
		@conf.css = @cgi.params['css'][0]
		$stderr.puts "saveconf: #{@conf.theme}"
	end

	@conf_theme_list = []
	Dir::glob( "#{::TDiary::PATH}/theme/*" ).sort.each do |dir|
		theme = dir.sub( %r[.*/theme/], '')
		next unless FileTest::file?( "#{dir}/#{theme}.css".untaint )
		name = theme.split( /_/ ).collect{|s| s.capitalize}.join( ' ' )
		@conf_theme_list << [theme,name]
	end
end

# comments
def saveconf_comment
	if @mode == 'saveconf' then
		@conf.show_comment = @cgi.params['show_comment'][0] == 'true' ? true : false
		@conf.comment_limit = @cgi.params['comment_limit'][0].to_i
		@conf.comment_limit = 3 if @conf.comment_limit < 1
	end
end

# referer
def saveconf_referer
	if @mode == 'saveconf' then
		@conf.show_referer = @cgi.params['show_referer'][0] == 'true' ? true : false
		@conf.referer_limit = @cgi.params['referer_limit'][0].to_i
		@conf.referer_limit = 10 if @conf.referer_limit < 1
		@conf.referer_day_only = @cgi.params['referer_day_only'][0] == 'true' ? true : false
		no_referer2 = []
		@conf.to_native( @cgi.params['no_referer'][0] ).each do |ref|
			ref.strip!
			no_referer2 << ref if ref.length > 0
		end
		@conf.no_referer2 = no_referer2
		referer_table2 = []
		@conf.to_native( @cgi.params['referer_table'][0] ).each do |pair|
			u, n = pair.sub( /[\r\n]+/, '' ).split( /[ \t]+/, 2 )
			referer_table2 << [u,n] if u and n
		end
		@conf.referer_table2 = referer_table2
	end
end

