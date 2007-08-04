#
# 00default.rb: default plugins 
# $Revision: 1.111 $
#
# Copyright (C) 2001-2005, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
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

def navi_item( link, label, rel = false )
	%Q[<span class="adminmenu"><a href="#{link}"#{rel ? " rel=\"nofollow\"" : ''}>#{label}</a></span>\n]
end

def navi_user
	result = navi_user_default

	case @mode
	when 'latest'
		result << navi_user_latest
	when 'day'
		result << navi_user_day
	when 'month'
		result << navi_user_month
	when 'nyear'
		result << navi_user_nyear
	when 'edit'
		result << navi_user_edit
	else
		result << navi_user_else
	end
	result
end

def navi_user_default
	result = ''
	result << navi_item( h(@index_page), h(navi_index) ) unless @index_page.empty?
	result
end

def navi_user_latest
	result = ''
	result << navi_item( "#{h @index}#{anchor( @conf['ndays.prev'] + '-' + @conf.latest_limit.to_s )}", "&laquo;#{navi_prev_ndays}" ) if @conf['ndays.prev'] and not bot?
	result << navi_item( h(@index), h(navi_latest) ) if @cgi.params['date'][0]
	result << navi_item( "#{h @index}#{anchor( @conf['ndays.next'] + '-' + @conf.latest_limit.to_s )}", "#{navi_next_ndays}&raquo;" ) if @conf['ndays.next'] and not bot?
	result
end

def navi_user_day
	result = ''
	result << navi_item( "#{h @index}#{anchor @prev_day}", "&laquo;#{h navi_prev_diary(Time::local(*@prev_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]))}" ) if @prev_day
	result << navi_item( @index, navi_latest )
	result << navi_item( "#{h @index}#{anchor @next_day}", "#{h navi_next_diary(Time::local(*@next_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]))}&raquo;" ) if @next_day
	result
end

def navi_user_month
	ym = []
	@years.keys.each do |y|
		ym += @years[y].collect {|m| y + m}
	end
	ym.sort!
	now = @date.strftime( '%Y%m' )
	return '' unless ym.index( now )
	prev_month = ym.index( now ) == 0 ? nil : ym[ym.index( now )-1]
	next_month = ym[ym.index( now )+1]

	result = ''
	result << navi_item( "#{h @index}#{anchor( prev_month )}", "&laquo;#{h navi_prev_month}" ) if prev_month and not bot?
	result << navi_item( h(@index), h(navi_latest) )
	result << navi_item( "#{h @index}#{anchor( next_month )}", "#{h navi_next_month}&raquo;" ) if next_month and not bot?
	result
end

def navi_user_nyear
	result = ''
	result << navi_item( "#{h @index}#{anchor @prev_day[4,4]}", "&laquo;#{h navi_prev_nyear(Time::local(*@prev_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]))}" ) if @prev_day
	result << navi_item( h(@index), h(navi_latest) ) unless @mode == 'latest'
	result << navi_item( "#{h @index}#{anchor @next_day[4,4]}", "#{h navi_next_nyear(Time::local(*@next_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]))}&raquo;" ) if @next_day
	result
end

def navi_user_edit
	result = ''
	if @prev_day then
		a = @prev_day.scan( /^(\d{4})(\d\d)(\d\d)$/ ).flatten
		result << navi_item( "#{h @update}?edit=true;year=#{a[0]};month=#{a[1]};day=#{a[2]}", "&laquo;#{h navi_prev_diary(Time::local(*@prev_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]))}" )
	end
	result << navi_item( h(@index), h(navi_latest) )
	if @next_day then
		a = @next_day.scan( /^(\d{4})(\d\d)(\d\d)$/ ).flatten
		result << navi_item( "#{h @update}?edit=true;year=#{a[0]};month=#{a[1]};day=#{a[2]}", "#{h navi_next_diary(Time::local(*@next_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]))}&raquo;" )
	end
	result
end

def navi_user_else
	navi_item( h(@index), h(navi_latest) )
end

def navi_admin
	if @mode == 'day' then
		result = navi_item( "#{h @update}?edit=true;year=#{@date.year};month=#{@date.month};day=#{@date.day}", h(navi_edit), true )
	else
		result = navi_item( h(@update), h(navi_update), true )
	end
	result << navi_item( "#{h @update}?conf=default", h(navi_preference) ) if /^(latest|month|day|comment|conf|nyear|category.*)$/ !~ @mode
	result
end

def mobile_navi
	calc_links
	result = []
	i = 1
	if @prev_day
		result << %Q[<A HREF="#{h @index}#{anchor @prev_day}" ACCESSKEY="#{i}">[#{i}]#{mobile_navi_prev_diary}</A>]
		i += 1
	end
	if @mode != 'latest'
		result << %Q[<A HREF="#{h @index}" ACCESSKEY="#{i}">[#{i}]#{mobile_navi_latest}</A>]
		i += 1
	end
	if @next_day
		result << %Q[<A HREF="#{h @index}#{anchor @next_day}" ACCESSKEY="#{i}">[#{i}]#{mobile_navi_next_diary}</A>]
	end
	result << %Q[<A HREF="#{h @update}" ACCESSKEY="0">[0]#{mobile_navi_update}</A>]
	result << %Q[<A HREF="#{h @update}?conf=default" ACCESSKEY="9">[9]#{mobile_navi_preference}</A>] unless /^(latest|month|day|conf|nyear)$/ === @mode
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
			result << %Q[<a href="#{h @index}#{anchor m}">#{month}</a>|]
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
		%Q[<p class="message">#$! (#{h $!.class})<br>cannot read #{h file}.</p>]
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
	<meta http-equiv="Content-Type" content="text/html; charset=#{h charset}">
	<meta name="generator" content="tDiary #{h TDIARY_VERSION}">
	#{last_modified_header}
	#{content_script_type}
	#{author_name_tag}
	#{author_mail_tag}
	#{index_page_tag}
	#{mobile_link_discovery}
	#{icon_tag}
	#{description_tag}
	#{css_tag.chomp}
	#{title_tag.chomp}
	#{robot_control.chomp}
	HEADER
end

def calc_links
	if /day|edit/ =~ @mode or (@conf.mobile_agent? and /latest|month|nyear/ =~ @mode) then
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

		current_date = @date.strftime( '%Y%m%d' )
		days[0 .. days.index( today ) - 1].reverse_each do |d|
		 	@prev_day = d
			next if @mode == 'latest' and current_date == d
			break unless @prev_day
			break if (@mode == 'edit') or @diaries[@prev_day].visible?
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

		days[days.index( today ) + 1 .. -1].each do |d|
			@next_day = d
			break unless @next_day
			break if (@mode == 'edit') or @diaries[@next_day].visible?
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
	%Q[<meta http-equiv="Content-Script-Type" content="text/javascript; charset=#{h charset}">]
end

def author_name_tag
	if @author_name and not(@author_name.empty?) then
		%Q[<meta name="author" content="#{h @author_name}">]
	else
		''
	end
end

def author_mail_tag
	if @author_mail and not(@author_mail.empty?) then
		%Q[<link rev="made" href="mailto:#{h @author_mail}">]
	else
		''
	end
end

def index_page_tag
	result = ''
	if @index_page and @index_page.size > 0 then
		result << %Q[<link rel="index" title="#{h navi_index}" href="#{h @index_page}">\n\t]
	end
	if @prev_day then
		case @mode
		when 'day'
			result << %Q[<link rel="prev" title="#{navi_prev_diary( Time::local(*@prev_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]) )}" href="#{h @index}#{anchor @prev_day}">\n\t]
		when 'nyear'
			result << %Q[<link rel="prev" title="#{navi_prev_nyear( Time::local(*@prev_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]) )}" href="#{h @index}#{anchor @prev_day[4,4]}">\n\t]
		end
	end
	if @next_day then
		case @mode
		when 'day'
			result << %Q[<link rel="next" title="#{navi_next_diary( Time::local(*@next_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]) )}" href="#{h @index}#{anchor @next_day}">\n\t]
		when 'nyear'
			result << %Q[<link rel="next" title="#{h navi_next_nyear( Time::local(*@next_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]) )}" href="#{h @index}#{anchor @next_day[4,4]}">\n\t]
		end
	end
	result << %Q[<link rel="start" title="#{navi_latest}" href="#{h @index}">\n\t]
	result.chop.chop
end

def mobile_link_discovery
	return '' unless /^(latest|day)$/ =~ @mode
	uri = @conf.index.dup
	uri[0, 0] = @conf.base_url if %r|^https?://|i !~ @conf.index
	uri.gsub!( %r|/\./|, '/' )
	if @mode == 'day' then
		uri += anchor( @date.strftime( '%Y%m%d' ) )
	end
	%Q[<link rel="alternate" media="handheld" type="text/html" href="#{h uri}">]
end

def icon_tag
	if @conf.icon and not(@conf.icon.empty?) then
		if /\.ico$/ =~ @conf.icon then
			%Q[<link rel="shortcut icon" href="#{h @conf.icon}">]
		else
			%Q[<link rel="icon" href="#{h @conf.icon}">]
		end
	else
		''
	end
end

def description_tag
	if @conf.description and not(@conf.description.empty?) then
		%Q[<meta name="description" content="#{h @conf.description}">]
	else
		''
	end
end

def theme_url; 'theme'; end

def css_tag
	if @mode =~ /conf$/ then
		css = "#{h theme_url}/conf.css"
	elsif @conf.theme and @conf.theme.length > 0
		css = "#{h theme_url}/#{h @conf.theme}/#{h @conf.theme}.css"
	else
		css = @css
	end
	title = File::basename( css, '.css' )
	<<-CSS
<meta http-equiv="content-style-type" content="text/css">
	<link rel="stylesheet" href="#{h theme_url}/base.css" type="text/css" media="all">
	<link rel="stylesheet" href="#{h css}" title="#{h title}" type="text/css" media="all">
	CSS
end

def robot_control
	if /^form|edit|preview|showcomment$/ =~ @mode then
		'<meta name="robots" content="noindex,nofollow">'
	else
		''
	end
end

#
# title of day
#
add_title_proc do |date, title|
	title_of_day( date, title )
end

def title_of_day( date, title )
	r = <<-HTML
	<span class="date">
	<a href="#{h @index}#{anchor( date.strftime( '%Y%m%d' ) )}">#{date.strftime @date_format}</a>
	</span> 
	<span class="title">#{title}</span>
	HTML
	return r.gsub( /^\t+/, '' ).chomp
end

add_title_proc do |date, title|
	nyear_link( date, title )
end

def nyear_link( date, title )
	if @conf.show_nyear and @mode != 'nyear' and !@conf.mobile_agent? then
		y = date.strftime( '%Y' )
		m = date.strftime( '%m' )
		d = date.strftime( '%d' )
		years = @years.find_all {|year, months| months.include? m}
		if years.length >= 2 then
			%Q|#{title} <span class="nyear">[<a href="#{h @index}#{anchor m + d}" title="#{h(nyear_diary_title(date, years))}">#{nyear_diary_label date, years}</a>]</span>|
		else
			title
		end
	else
		title
	end
end

#
# make anchor string
#
def anchor( s )
	if /^([\-\d]+)#?([pct]\d*)?$/ =~ s then
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
# subtitle
#
add_subtitle_proc do |date, index, subtitle|
	subtitle_link( date, index, subtitle )
end

def make_category_link( subtitle )
	r = ''
	if subtitle
		if respond_to?( :category_anchor ) then
			r << subtitle.sub( /^(\[([^\[]+?)\])+/ ) do
				$&.gsub( /\[(.*?)\]/ ) do
					$1.split( /,/ ).collect do |c|
						category_anchor( "#{c}" )
					end.join
				end
			end
		else
			r << subtitle
		end
	end
	r
end

def subtitle_link( date, index, subtitle )
	r = ''

	if @conf.mobile_agent? then
		r << %Q[<A NAME="p#{'%02d' % index}">*</A> ]
		r << %Q|(#{h @author})| if @multi_user and @author and subtitle
	else
		if date then
			r << "<a "
			r << %Q[name="p#{'%02d' % index}" ] if @anchor_name
			param = "#{date.strftime( '%Y%m%d' )}#p#{'%02d' % index}"
			r << %Q[href="#{h @index}#{anchor param}">#{@conf.section_anchor}</a> ]
		end
	
		r << %Q[(#{h @author}) ] if @multi_user and @author and subtitle
	end
	r << make_category_link( subtitle )
end

#
# make anchor tag in my diary
#
def my( a, str, title = nil )
	date, noise, frag = a.scan( /^(\d{4}|\d{6}|\d{8}|\d{8}-\d+)([^\d]*)?#?([pct]\d+)?$/ )[0]
	anc = frag ? "#{date}#{frag}" : date
	index = /^https?:/ =~ @index ? '' : @conf.base_url
	index += @index.sub(%r|^\./|, '')
	if title then
		%Q[<a href="#{h index}#{anchor anc}" title="#{h title}">#{str}</a>]
	else
		%Q[<a href="#{h index}#{anchor anc}">#{str}</a>]
	end
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
# make comment form
#
def comment_form
	return '' unless @mode == 'day'

	r = ''
	unless @conf.hide_comment_form then
		r = <<-FORM
			<div class="form">
		FORM
		if @diaries[@date.strftime('%Y%m%d')].count_comments( true ) >= @conf.comment_limit_per_day then
			r << <<-FORM
				<div class="caption"><a name="c">#{comment_limit_label}</a></div>
			FORM
		else
			r << <<-FORM
					<div class="caption"><a name="c">#{comment_description}</a></div>
					<form class="comment" name="comment-form" method="post" action="#{h @index}"><div>
					<input type="hidden" name="date" value="#{ @date.strftime( '%Y%m%d' )}">
					<div class="field name">
						#{comment_name_label}:<input class="field" name="name" value="#{h( @cgi.cookies['tdiary'][0] || '' )}">
					</div>
					<div class="field mail">
						#{comment_mail_label}:<input class="field" name="mail" value="#{h( @cgi.cookies['tdiary'][1] || '' )}">
					</div>
					<div class="textarea">
						#{comment_body_label}:<textarea name="body" cols="60" rows="5"></textarea>
					</div>
					<div class="button">
						<input type="submit" name="comment" value="#{h comment_submit_label}">
					</div>
					</div></form>
			FORM
		end
		r << <<-FORM
			</div>
		FORM
	end
	r
end

def comment_form_mobile_mail_field
	%Q|#{comment_mail_label_short}: <INPUT NAME="mail"><BR>|
end

def comment_form_mobile
	return '' if @conf.hide_comment_form
	return <<-FORM
		<HR>
		<FORM METHOD="POST" ACTION="#{h @index}">
			<INPUT TYPE="HIDDEN" NAME="date" VALUE="#{@date.strftime( '%Y%m%d' )}">
			<P>#{comment_description_short}<BR>
			#{comment_name_label_short}: <INPUT NAME="name"><BR>
			#{comment_form_mobile_mail_field}
			#{comment_body_label_short}:<BR>
			<TEXTAREA NAME="body" COLS="100%" ROWS="5"></TEXTAREA><BR>
			<INPUT TYPE="SUBMIT" NAME="comment" value="#{comment_submit_label_short}"></P>
		</FORM>
	FORM
end

#
# service methods for comment_mail
#
def comment_mail_send
	return unless @comment
	return unless @conf['comment_mail.enable']
	return unless @conf['comment_mail.sendhidden'] or @comment.visible?

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
	mail = receivers[0] if mail.empty?
	
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
	text = ERB::new( rmail.untaint ).result( binding )
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
		@conf['comment_mail.sendhidden'] = @cgi.params['comment_mail.sendhidden'][0] == 'true' ? true : false
	end
end

#
# preferences (saving methods)
#

# basic (default)
def saveconf_default
	if @mode == 'saveconf' then
		@conf.html_title = @conf.to_native( @cgi.params['html_title'][0] )
		@conf.author_name = @conf.to_native( @cgi.params['author_name'][0] )
		@conf.author_mail = @cgi.params['author_mail'][0]
		@conf.index_page = @cgi.params['index_page'][0]
		@conf.description = @conf.to_native( @cgi.params['description'][0] )
		@conf.icon = @cgi.params['icon'][0]
		@conf.banner = @cgi.params['banner'][0]
		@conf['base_url'] = @cgi.params['base_url'][0]
	end
end

# header/footer (header)
def saveconf_header
	if @mode == 'saveconf' then
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

# timezone
def saveconf_timezone
	if @mode == 'saveconf' then
		@conf.hour_offset = @cgi.params['hour_offset'][0].to_f
	end
end

# themes
def conf_theme_list
	r = ''
	t = 0
	@conf_theme_list.each_with_index do |theme, index|
		if theme[0] == @conf.theme then
			select = " selected"
			t = index
		end
		r << %Q|<option value="#{h theme[0]}"#{select}>#{theme[1]}</option>|
	end
	img = t == 0 ? 'nowprinting' : @conf.theme
	r << <<-HTML
	</select>
	<input name="css" size="50" value="#{h @conf.css}">
	</p>
	<p><img id="theme_thumbnail" src="http://www.tdiary.org/theme.image/#{img}.jpg" alt="#{@theme_thumbnail_label}"></p>
	<script language="JavaScript"><!--
		function changeTheme( image, list ) {
			var theme = '';
			if ( list.selectedIndex == 0 ) {
				theme = 'nowprinting';
			} else {
				theme = list.options[list.selectedIndex].value;
			}
			image.src = 'http://www.tdiary.org/theme.image/' + theme + '.jpg'
		}
	--></script>
	#{@theme_location_comment unless @conf.mobile_agent?}
	HTML
end

def saveconf_theme
	if @mode == 'saveconf' then
		@conf.theme = @cgi.params['theme'][0]
		@conf.css = @cgi.params['css'][0]
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

		@conf.comment_limit_per_day = @cgi.params['comment_limit_per_day'][0].to_i
		@conf.comment_limit_per_day = 0 if @conf.comment_limit_per_day < 0
	end
end

def saveconf_csrf_protection
	if @mode == 'saveconf' then
		err = nil
		check_method = 0
		case @cgi.params['check_enabled']
		when ['true']
		else
			err = :param
		end
		case @cgi.params['check_referer']
		when ['true']
			check_method |= 1
		when ['false']
			check_method |= 0
		else
			err = :param
		end
		case @cgi.params['check_key']
		when ['true']
			check_method |= 2
		when ['false']
			check_method |= 0
		else
			err = :param
		end
		err = :param if check_method == 0
		check_key = @cgi.params['key'][0]

		if check_method & 2 != 0 && (!check_key || check_key == '') then
			err ||= :key
		end

		unless err
			old_key = @conf['csrf_protection_key']
			old_method = @conf['csrf_protection_method']
			@conf['csrf_protection_method'] = check_method
			@conf['csrf_protection_key'] = check_key
			if (check_method & 2 == 2 &&
			    (old_method & 2 == 0 || old_key != check_key))
				@conf.save
				raise ForceRedirect, "#{h @update}?conf=csrf_protection#{@cgi.referer ? '&amp;referer_exists=true' : ''}"
			end
		end
		err
	else
		nil
	end
end
