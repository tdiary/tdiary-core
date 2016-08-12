#
# 00default.rb: default plugins
#
# Copyright (C) 2010, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2 or any later version.
#

#
# setting @date
#
unless @date
	if @diary then
		@date = @diary.date
	else
		@date = case @mode
		when 'day'
			Time::local( *@cgi.params['date'][0].scan( /^(\d{4})(\d\d)(\d\d)/ ).flatten )
		when 'month'
			Time::local( *@cgi.params['date'][0].scan( /^(\d{4})(\d\d)/ ).flatten )
		when 'edit'
			Time::local( @cgi.params['year'][0].to_i, @cgi.params['month'][0].to_i, @cgi.params['day'][0].to_i )
		else
			nil
		end
	end
end

#
# make navigation buttons
#
def navi
	result = %Q[<div class="adminmenu">\n]
	result << navi_user
	result << navi_admin
	result << %Q[</div>]
end

def navi_item( link, label, rel = nil )
	result = %Q[<span class="adminmenu"><a href="#{link}"]
	result << %Q[ rel="#{rel}"] if rel
	result << %Q[>#{label}</a></span>\n]
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
	result << navi_item( h(@conf.index_page), h(navi_index) ) unless @conf.index_page.empty?
	result
end

def navi_user_latest
	result = ''
	result << navi_item( "#{h @conf.index}#{anchor( @conf['ndays.prev'] + '-' + @conf.latest_limit.to_s )}", "&laquo;#{navi_prev_ndays}", "next" ) if @conf['ndays.prev'] and not bot?
	result << navi_item( h(@conf.index), h(navi_latest) ) if @cgi.params['date'][0]
	result << navi_item( "#{h @conf.index}#{anchor( @conf['ndays.next'] + '-' + @conf.latest_limit.to_s )}", "#{navi_next_ndays}&raquo;", "prev") if @conf['ndays.next'] and not bot?
	result
end

def navi_user_day
	result = ''
	if @navi_user_days then
		result << navi_item( "#{h @conf.index}#{anchor @navi_user_days[0]}", "&laquo;#{h navi_prev_diary(navi_user_format(@navi_user_days[0]))}" ) if @navi_user_days[0]
		result << navi_item( h(@conf.index), h(navi_latest) )
		result << navi_item( "#{h @conf.index}#{anchor @navi_user_days[2]}", "#{h navi_next_diary(navi_user_format(@navi_user_days[2]))}&raquo;" ) if @navi_user_days[2]
	end
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
	result << navi_item( "#{h @conf.index}#{anchor( prev_month )}", "&laquo;#{h navi_prev_month}" ) if prev_month and not bot?
	result << navi_item( h(@conf.index), h(navi_latest) )
	result << navi_item( "#{h @conf.index}#{anchor( next_month )}", "#{h navi_next_month}&raquo;" ) if next_month and not bot?
	result
end

def navi_user_nyear
	result = ''
	result << navi_item( "#{h @conf.index}#{anchor @prev_day[4,4]}", "&laquo;#{h navi_prev_nyear(Time::local(*@prev_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]))}" ) if @prev_day
	result << navi_item( h(@conf.index), h(navi_latest) ) unless @mode == 'latest'
	result << navi_item( "#{h @conf.index}#{anchor @next_day[4,4]}", "#{h navi_next_nyear(Time::local(*@next_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]))}&raquo;" ) if @next_day
	result
end

def navi_user_edit
	result = ''
	if @prev_day then
		a = @prev_day.scan( /^(\d{4})(\d\d)(\d\d)$/ ).flatten
		result << navi_item( "#{h @conf.update}?edit=true;year=#{a[0]};month=#{a[1]};day=#{a[2]}", "&laquo;#{h navi_prev_diary(Time::local(*@prev_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]))}" )
	end
	result << navi_item( h(@conf.index), h(navi_latest) )
	if @next_day then
		a = @next_day.scan( /^(\d{4})(\d\d)(\d\d)$/ ).flatten
		result << navi_item( "#{h @conf.update}?edit=true;year=#{a[0]};month=#{a[1]};day=#{a[2]}", "#{h navi_next_diary(Time::local(*@next_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]))}&raquo;" )
	end
	result
end

def navi_user_else
	navi_item( h(@conf.index), h(navi_latest) )
end

def navi_user_format( day )
	Time::local( *day.scan( /^(\d{4})(\d\d)(\d\d)$/ )[0] )
end

def navi_admin
	if @mode == 'day' then
		result = navi_item( "#{h @conf.update}?edit=true;year=#{@date.year};month=#{@date.month};day=#{@date.day}", h(navi_edit), "nofollow" )
	else
		result = navi_item( h(@conf.update), h(navi_update), "nofollow")
	end
	result << navi_item( "#{h @conf.update}?conf=default", h(navi_preference) ) if /^(latest|month|day|comment|conf|nyear|category.*)$/ !~ @mode
	result
end

def mobile_navi
	result = []
	if @navi_user_days and @navi_user_days[0]
		result << %Q[<A HREF="#{h @conf.index}#{anchor @navi_user_days[0]}" ACCESSKEY="*">[*]#{mobile_navi_prev_diary}</A>]
	end
	if @mode != 'latest'
		result << %Q[<A HREF="#{h @conf.index}" ACCESSKEY="0">[0]#{mobile_navi_latest}</A>]
	end
	if @navi_user_days and @navi_user_days[2]
		result << %Q[<A HREF="#{h @conf.index}#{anchor @navi_user_days[2]}" ACCESSKEY="#">[#]#{mobile_navi_next_diary}</A>]
	end
	if @mode == 'day' then
		result << %Q[<A HREF="#{h @conf.update}?edit=true;year=#{@date.year};month=#{@date.month};day=#{@date.day}" ACCESSKEY="5">[5]#{mobile_navi_edit}</A>]
	else
		result << %Q[<A HREF="#{h @conf.update}" ACCESSKEY="5">[5]#{mobile_navi_update}</A>]
	end
	result << %Q[<A HREF="#{h @conf.update}?conf=default" ACCESSKEY="8">[8]#{mobile_navi_preference}</A>] unless /^(latest|month|day|conf|nyear)$/ === @mode
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
			result << %Q[<a href="#{h @conf.index}#{anchor m}">#{month}</a>|]
		end
		result << "</div>\n"
	end
	result << "</div>"
end

#
# insert file
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
	%Q|<!DOCTYPE html>|
end

#
# default HTML header
#
add_header_proc do
	calc_links
	<<-HEADER
	<meta charset="#{h charset}">
	<meta name="generator" content="tDiary #{h TDIARY_VERSION}">
	<meta name="viewport" content="width=device-width,initial-scale=1">
	#{author_name_tag}
	#{author_mail_tag}
	#{index_page_tag}
	#{icon_tag}
	#{default_ogp}
	#{description_tag}
	#{css_tag.chomp}
	#{jquery_tag.chomp}
	#{script_tag.chomp}
	#{title_tag.chomp}
	#{robot_control.chomp}
	HEADER
end

def calc_links
	if /day|edit/ =~ @mode then
		today = @date.strftime('%Y%m%d')
		days = []
		yms = []
		this_month = today[0,6]

		@years.keys.each do |y|
			yms += @years[y].collect {|m| y + m}
		end
		yms |= [this_month]
		yms.sort!
		yms.unshift(nil).push(nil)
		yms[yms.index(this_month) - 1, 3].each do |ym|
			next unless ym
			now = @cgi.params['date'] # backup
			cgi = @cgi.clone
			cgi.params['date'] = [ym]
			m = TDiaryMonthWithoutFilter.new(cgi, '', @conf)
			@cgi.params['date'] = now # restore
			m.diaries.delete_if {|date,diary| !diary.visible?}
			days += m.diaries.keys.sort
		end
		days |= [today]
		days.sort!
		days.unshift(nil).push(nil)
		@navi_user_days = days[days.index(today) - 1, 3]
		@prev_day = @navi_user_days[0]
		@next_day = @navi_user_days[2]
	elsif @mode == 'nyear'
		y = 2000 # specify leam year
		m, d = @cgi.params['date'][0].scan(/^(\d\d)(\d\d)$/)[0]
		@prev_day = (Time.local(y, m, d) - 24*60*60).strftime( '%Y%m%d' )
		@next_day = (Time.local(y, m, d) + 24*60*60).strftime( '%Y%m%d' )
	end
end

def charset
	@conf.encoding
end

def last_modified_header
	''
end

def content_script_type
	''
end

def author_name_tag
	if @conf.author_name and not(@conf.author_name.empty?) then
		%Q[<meta name="author" content="#{h @conf.author_name}">]
	else
		''
	end
end

def author_mail_tag
	if @conf.author_mail and not(@conf.author_mail.empty?) then
		%Q[<link rev="made" href="mailto:#{h @conf.author_mail}">]
	else
		''
	end
end

def index_page_tag
	result = ''
	if @conf.index_page and @conf.index_page.size > 0 then
		result << %Q[<link rel="index" title="#{h navi_index}" href="#{h @conf.index_page}">\n\t]
	end
	if @prev_day then
		case @mode
		when 'day'
			result << %Q[<link rel="prev" title="#{navi_prev_diary( Time::local(*@prev_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]) )}" href="#{h @conf.index}#{anchor @prev_day}">\n\t]
		when 'nyear'
			result << %Q[<link rel="prev" title="#{navi_prev_nyear( Time::local(*@prev_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]) )}" href="#{h @conf.index}#{anchor @prev_day[4,4]}">\n\t]
		end
	end
	if @next_day then
		case @mode
		when 'day'
			result << %Q[<link rel="next" title="#{navi_next_diary( Time::local(*@next_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]) )}" href="#{h @conf.index}#{anchor @next_day}">\n\t]
		when 'nyear'
			result << %Q[<link rel="next" title="#{h navi_next_nyear( Time::local(*@next_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]) )}" href="#{h @conf.index}#{anchor @next_day[4,4]}">\n\t]
		end
	end
	result << %Q[<link rel="start" title="#{navi_latest}" href="#{h @conf.index}">\n\t]
	result.chop.chop
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

def default_ogp
	if @conf.options2['sp.selected'] && @conf.options2['sp.selected'].include?('ogp.rb')
		if defined?(@conf.banner)
			%Q[<meta content="#{base_url}images/ogimage.png" property="og:image">]
		end
	else
		uri = @conf.index.dup
		uri[0, 0] = base_url if %r|^https?://|i !~ @conf.index
		uri.gsub!( %r|/\./|, '/' )
		image = File.join(uri, "#{theme_url}/ogimage.png")
		if @mode == 'day' then
			uri += anchor( @date.strftime( '%Y%m%d' ) )
		end
		%Q[<meta content="#{title_tag.gsub(/<[^>]*>/, "")}" property="og:title">
		<meta content="#{(@mode == 'day') ? 'article' : 'website'}" property="og:type">
		<meta content="#{h image}" property="og:image">
		<meta content="#{h uri}" property="og:url">]
	end
end

def description_tag
	if @conf.description and not(@conf.description.empty?) then
		%Q[<meta name="description" content="#{h @conf.description}">]
	else
		''
	end
end

def jquery_tag
	%Q[<script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>]
end

enable_js( '00default.js', async: false )
add_js_setting( '$tDiary.style', "'#{@conf.style.downcase.sub( /\Ablog/, '' )}'" )

if /^form|edit|preview|showcomment/ =~ @mode
	enable_js( '02edit.js', async: true )
end

def script_tag_query_string
	"?#{TDIARY_VERSION}#{Time::now.strftime('%Y%m%d')}"
end

def js_url
	@cgi.is_a?(RackCGI) ? 'assets' : 'js'
end

def script_tag
	require 'uri'
	query = script_tag_query_string
	html = @javascripts.keys.sort.map {|script|
		async = @javascripts[script][:async] ? "async" : ""
		if URI(script).scheme or script =~ %r|\A//|
			%Q|<script src="#{script}" #{async}></script>|
		else
			%Q|<script src="#{js_url}/#{script}#{query}" #{async}></script>|
		end
	}.join( "\n\t" )
	html << "\n" << <<-HEAD
		<script><!--
		#{@javascript_setting.map{|a| "#{a[0]} = #{a[1]};"}.join("\n\t\t")}
		//-->
		</script>
	HEAD
end

def theme_url
	@cgi.is_a?(RackCGI) ? 'assets' : 'theme'
end

def css_tag
	if @mode =~ /conf$/ then
		css = "#{h theme_url}/conf.css"
	elsif @conf.theme and @conf.theme.length > 0
		location, name = @conf.theme.split(/\//, 2)
		unless name
			name = location
			location = 'local'
		end
		css = __send__("theme_url_#{location}", name)
	else
		css = @conf.css
	end
	title = File::basename( css, '.css' )
	<<-CSS
<link rel="stylesheet" href="#{h theme_url}/base.css" media="all">
	<link rel="stylesheet" href="#{h css}" title="#{h title}" media="all">
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
	<a href="#{h @conf.index}#{anchor( date.strftime( '%Y%m%d' ) )}">#{date.strftime @conf.date_format}</a>
	</span>
	<span class="title">#{title}</span>
	HTML
	return r.gsub( /^\t+/, '' ).chomp
end

add_title_proc do |date, title|
	nyear_link( date, title )
end

def nyear_link( date, title )
	if @conf.show_nyear and @mode != 'nyear' then
		m = date.strftime( '%m' )
		d = date.strftime( '%d' )
		years = @years.find_all {|year, months| months.include? m}
		if years.length >= 2 then
			%Q|#{title} <span class="nyear">[<a href="#{h @conf.index}#{anchor m + d}" title="#{h(nyear_diary_title)}">#{nyear_diary_label}</a>]</span>|
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
						category_anchor( "#{CGI::unescapeHTML c}" )
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

	if date then
		r << "<a "
		r << %Q[name="p#{'%02d' % index}" ] if @anchor_name
		param = "#{date.strftime( '%Y%m%d' )}#p#{'%02d' % index}"
		titleattr = (not subtitle or subtitle.empty?) ? '' : %Q[ title="#{remove_tag( apply_plugin( subtitle )).gsub( /"/, "&quot;" )}"]
		r << %Q[href="#{h @conf.index}#{anchor param}"#{titleattr}>#{@conf.section_anchor}</a> ]
	end

	r << %Q[(#{h @author}) ] if @multi_user and @author and subtitle
	r << make_category_link( subtitle )
end

#
# make anchor tag in my diary
#
def my( a, str, title = nil )
	date, _, frag = a.scan( /^(\d{4}|\d{6}|\d{8}|\d{8}-\d+)([^\d]*)?#?([pct]\d+)?$/ )[0]
	anc = frag ? "#{date}#{frag}" : date
	index = /^https?:/ =~ @conf.index ? '' : base_url
	index += @conf.index.sub(%r|^\./|, '')
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
def comment_description
	 begin
		if @conf.options['comment_description'].length > 0 then
			 return @conf.options['comment_description']
		end
	 rescue
	 end
	 comment_description_default
end

def comment_form_text
	unless @diary then
		@diary = @diaries[@date.strftime( '%Y%m%d' )]
		return '' unless @diary
	end

	r = ''
	unless @conf.hide_comment_form then
		r = <<-FORM
			<div class="form">
		FORM
		if @diary.count_comments( true ) >= @conf.comment_limit_per_day then
			r << <<-FORM
				<div class="caption"><a name="c">#{comment_limit_label}</a></div>
			FORM
		else
			r << <<-FORM
				<div class="caption"><a name="c">#{comment_description}</a></div>
				<form class="comment" name="comment-form" method="post" action="#{h @conf.index}"><div>
				<input type="hidden" name="date" value="#{ @date.strftime( '%Y%m%d' )}">
				<div class="field name">
					#{comment_name_label}:<input class="field" name="name" value="#{h( @conf.to_native(@cgi.cookies['tdiary'][0] || '' ))}">
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

add_footer_proc do
	if @mode != 'day' or bot? then
		''
	elsif hide_comment_day_limit
		r = ''
		r << <<-JS
			<script><!--
			document.getElementById('comment-form-section').innerHTML = '#{comment_form_text.gsub( /[\r\n]/, '' ).gsub( /<\//, '<\\/' )}';
			//--></script>
		JS
	else
		''
	end
end

def comment_form
	return '' unless @mode == 'day'
	return '' if bot?
	return '' if hide_comment_day_limit

	comment_form_text
end

def comment_form_mobile_mail_field
	%Q|#{comment_mail_label_short}: <INPUT NAME="mail"><BR>|
end

def comment_form_mobile
	return '' if @conf.hide_comment_form
	return '' if bot?
	return '' if hide_comment_day_limit

	if @diaries[@date.strftime('%Y%m%d')].count_comments( true ) >= @conf.comment_limit_per_day then
		return "<HR><P>#{comment_limit_label}</P>"
	end

	return <<-FORM
		<HR>
		<FORM METHOD="POST" ACTION="#{h @conf.index}">
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

def hide_comment_day_limit
	if @conf.options.include?('spamfilter.date_limit') &&
			@conf.options['spamfilter.date_limit'] &&
			/\A\d+\z/ =~ @conf.options['spamfilter.date_limit'].to_s
		date_limit = @conf.options['spamfilter.date_limit'].to_s.to_i
		now = Time.now
		today = Time.local(now.year, now.month, now.day)
		limit = today - 24 * 60 * 60 * date_limit
		if @date < limit
			return true
		end
	end
	return false
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
	body = @comment.body.sub( /[\r\n]+\Z/, '' )
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
	mail_header = comment_mail_mime( @conf.to_mail( mail_header ) ).join( "\n " ) #if /[\x80-\xff]/ =~ mail_header

	rmail = ''
	begin
		rmail = File::open( "#{TDiary::PATH}/../views/mail.rtxt.#{@conf.lang}" ){|f| f.read }
	rescue
		rmail = File::open( "#{TDiary::PATH}/../views/mail.rtxt" ){|f| f.read }
	end
	text = @conf.to_mail( ERB::new( rmail.untaint ).result( binding ) )
	receivers.each(&:untaint)
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
# convert to UTF-8
#
def to_utf8( str, charset = nil )
	@conf.to_native( str, charset )
end

#
# layout
#
def brr; '<br clear="right">'; end
def brl; '<br clear="left">';  end

#
# preferences (saving methods)
#
if @mode =~ /conf|saveconf/
	enable_js( '01conf.js', async: true )
end

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
		@conf.x_frame_options = @cgi.params['x_frame_options'][0]
		@conf.x_frame_options = nil if @conf.x_frame_options.empty?
	end
end

# header/footer (header)
def saveconf_header
	if @mode == 'saveconf' then
		@conf.header = @conf.to_native( @cgi.params['header'][0] ).lines.map(&:chomp).join( "\n" ).sub( /\n+\z/, '' )
		@conf.footer = @conf.to_native( @cgi.params['footer'][0] ).lines.map(&:chomp).join( "\n" ).sub( /\n+\z/, '' )
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
	t = -1
	@conf_theme_list.each_with_index do |theme, index|
		if theme[0] == @conf.theme then
			select = " selected"
			t = index
		end
		r << %Q|<option value="#{h theme[0]}"#{select}>#{theme[1]}</option>|
	end
	img = t == -1 ? 'nowprinting' : @conf.theme.sub(/^.*\//, '')
	r << <<-HTML
	</select>
	<input name="css" size="30" value="#{h @conf.css}">
	</p>
	<p><img id="theme_thumbnail" src="http://www.tdiary.org/theme.image/#{img}.jpg" alt="#{@theme_thumbnail_label}"></p>
	#{@theme_location_comment}
	HTML
end

def theme_list_local(list)
	theme_paths = [::TDiary::PATH, TDiary.server_root].map {|d| "#{d}/theme/*" }
	Dir::glob( theme_paths ).sort.map {|dir|
		theme = dir.sub( %r[.*/theme/], '')
		next unless FileTest::file?( "#{dir}/#{theme}.css".untaint )
		name = theme.split( /_/ ).collect{|s| s.capitalize}.join( ' ' )
		list << ["local/#{theme}",name]
	}
	list
end

def theme_url_local(theme)
	"#{h theme_url}/#{h theme}/#{h theme}.css"
end

def saveconf_theme
	if @mode == 'saveconf' then
		@conf.theme = @cgi.params['theme'][0]
		@conf.css = @cgi.params['css'][0]
	end
	@conf_theme_list = methods.inject([]) {|conf_theme_list, method|
		if /^theme_list_/ =~ method.to_s
			__send__(method, conf_theme_list)
		else
			conf_theme_list
		end
	}.sort.compact.uniq
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
		check_key = ''
		key_seed = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
		1.upto(30) do
			check_key << key_seed[rand( key_seed.length )]
		end

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
				raise ForceRedirect, "#{h @conf.update}?conf=csrf_protection#{@cgi.referer ? '&amp;referer_exists=true' : ''}"
			end
		end
		err
	else
		nil
	end
end

def saveconf_logger
	if @mode == 'saveconf' then
		@conf['log_level'] = @cgi.params['log_level'][0]
	end
end

def conf_logger_list
	log_level_list = ["DEBUG", "INFO", "WARN", "ERROR", "FATAL"]
	r = ''

	@conf['log_level'] ||= "INFO"

	log_level_list.each do |level|
		if level == @conf['log_level'] then
			select = " selected"
		end
		r << %Q|<option value="#{h level}"#{select}>#{level}</option>|
	end

	r << %Q|</select></p>|
end

def saveconf_recommendfilter
	if @mode == 'saveconf' && @cgi.params['recommend.filter'][0] == 'true' then
		@conf['sf.selected'] = ""
		@conf['comment_description'] = "ツッコミ・コメントがあればどうぞ! URIは1つまで入力可能です。"

		if @sp_path.inject(false){|r, dir| r || FileTest.exist?("#{dir}/hide-mail-field.rb") }
			if @conf['sp.selected']
				@conf['sp.selected'].concat("hide-mail-field.rb\n")
			else
				@conf['sp.selected'] = "hide-mail-field.rb\n"
			end
			@conf['spamfilter.bad_mail_patts'] = "@"
			@conf['comment_description'].concat("spam対策でE-mail欄は隠してあります。もしE-mail欄が見えていても、何も入力しないで下さい。")
		end

		@conf['spamfilter.bad_comment_patts'] = "href=\r\nurl=\r\nURL=\r\n"
		@conf['spamfilter.bad_ip_addrs'] = ""
		@conf['spamfilter.bad_uri_patts'] = ""
		@conf['spamfilter.bad_uri_patts_for_mails'] = false
		@conf['spamfilter.date_limit'] = "7"
		@conf['spamfilter.debug_file'] = ""
		@conf['spamfilter.debug_mode'] = false
		@conf['spamfilter.filter_mode'] = false
		@conf['spamfilter.hide_commentform'] = true
		@conf['spamfilter.linkcheck'] = 1
		@conf['spamfilter.max_rate'] = "0"
		@conf['spamfilter.max_uris'] = "1"
		@conf['spamfilter.resolv_check'] = true
		@conf['spamfilter.resolv_check_mode'] = false
		@conf['spamlookup.domain.list'] = "bsb.spamlookup.net\r\nsc.surbl.org\r\nrbl.bulkfeeds.jp"
		@conf['spamlookup.ip.list'] = "dnsbl.spam-champuru.livedoor.com"
		@conf['spamlookup.safe_domain.list'] = "www.google.com\r\nwww.google.co.jp\r\nezsch.ezweb.ne.jp\r\nwww.yahoo.co.jp\r\nsearch.mobile.yahoo.co.jp\r\nwww.bing.com"
	end
end

#
# old ruby alert
#
def old_ruby_alert
	if RUBY_VERSION < '2.0.0' and !@conf['old_ruby_alert.hide']
		%Q|<div class="alert-warn">
			<a href="#" class="action-button" id="alert-old-ruby">&times;</a>
			#{old_ruby_alert_message}
		</div>|
	else
		''
	end
end

def old_ruby_alert_message
	"お使いのRuby #{RUBY_VERSION}は次のリリースからサポート対象外になります。"
end

add_conf_proc( 'old_ruby_alert', nil) do
	if @mode == 'saveconf'
		@conf['old_ruby_alert.hide'] = true
	end
	%Q|<h3>OLD RUBY ALERT</h3>| # dummy
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
