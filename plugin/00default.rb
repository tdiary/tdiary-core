#
# 00default.rb: default plugins 
# $Revision: 1.11 $
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
	result << %Q[<span class="adminmenu"><a href="#{@index_page}">トップ</a></span>\n] unless @index_page.empty?
	if /^(day|comment)$/ =~ @mode
		days = []
		today = @date.strftime('%Y%m%d')
		days += @diaries.keys
		days |= [today]

		days.sort!
		days.unshift(nil).push(nil)
		prev_day, cur_day, next_day = days[days.index(today) - 1, 3]
		if prev_day
			result << %Q[<span class="adminmenu"><a href="#{@index}#{anchor prev_day}">&lt;#{navi_prev_day Time::local(*prev_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]).strftime(@date_format)}</a></span>\n]
		else
			pday = Time.local(@date.year, @date.month, 1) - 24*60*60
			result << %Q[<span class="adminmenu"><a href="#{@index}#{anchor pday.strftime('%Y%m%d')}">&lt;#{navi_prev_day2 pday.strftime(@date_format)}</a></span>\n]
		end
		result << %Q[<span class="adminmenu"><a href="#{@index}">#{navi_latest}</a></span>\n] unless @mode == 'latest'
		if next_day
			result << %Q[<span class="adminmenu"><a href="#{@index}#{anchor next_day}">#{navi_next_day Time::local(*next_day.scan(/^(\d{4})(\d\d)(\d\d)$/)[0]).strftime(@date_format)}&gt;</a></span>\n]
		else
			nday = if @date.month == 12
				Time.local(@date.year + 1, 1, 1)
			else
				Time.local(@date.year, @date.month + 1, 1)
			end
			result << %Q[<span class="adminmenu"><a href="#{@index}#{anchor nday.strftime('%Y%m%d')}">#{navi_next_day2 nday.strftime(@date_format)}&gt;</a></span>\n]
		end
	else
		result << %Q[<span class="adminmenu"><a href="#{@index}">#{navi_latest}</a></span>\n] unless @mode == 'latest'
	end
	result
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
		%Q[<p class="message">#$! (#{$!.type})<br>cannot read #{file}.</p>]
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
	<<-HEADER
	<meta http-equiv="Content-Type" content="text/html; charset=#{charset}">
	<meta name="generator" content="tDiary #{TDIARY_VERSION}">
	#{author_name_tag}
	#{author_mail_tag}
	#{index_page_tag}
	#{css_tag.chomp}
	#{title_tag.chomp}
	HEADER
end

def charset
	@conf.charset( @cgi.mobile_agent? )
end

def author_name_tag
	if @author_name then
		%Q[<meta name="Author" content="#{@author_name}">]
	else
		''
	end
end

def author_mail_tag
	if @author_mail then
		%Q[<link rev="MADE" href="mailto:#{@author_mail}">]
	else
		''
	end
end

def index_page_tag
	if @index_page and @index_page.size > 0 then
		%Q[<link rel="INDEX" href="#{@index_page}">]
	else
		''
	end
end

def theme_url; 'theme'; end

def css_tag
	if @theme and @theme.length > 0 then
		css = "#{theme_url}/#{@theme}/#{@theme}.css"
	else
		css = @css
	end
	<<-CSS
	<meta http-equiv="content-style-type" content="text/css">
	<link rel="stylesheet" href="#{css}" type="text/css" media="all">
	CSS
end

def title_tag
	r = "<title>#{@html_title}"
	case @mode
	when 'day', 'comment'
		r << "(#{@date.strftime( '%Y-%m-%d' )})" if @date
	when 'month'
		r << "(#{@date.strftime( '%Y-%m' )})" if @date
	when 'form'
		r << '(更新)'
	when 'append', 'replace'
		r << '(更新完了)'
	when 'showcomment'
		r << '(変更完了)'
	when 'conf'
		r << '(設定)'
	when 'saveconf'
		r << '(設定完了)'
	end
	r << '</title>'
end

#
# make anchor string
#
def anchor( s )
	if /^(\d+)#?([pc]\d*)?$/ =~ s then
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
def my( a, str )
	%Q[<a href="#{@index}#{anchor a}">#{str}</a>]
end

#
# referer of today
#
def referer_of_today_short( diary, limit )
	return '' if not diary or diary.count_referers == 0
	result = %Q[#{referer_today} | ]
	diary.each_referer( limit ) do |count,ref|
		result << %Q[<a href="#{CGI::escapeHTML( ref )}" title="#{CGI::escapeHTML( diary.disp_referer( @referer_table, ref ) )}">#{count}</a> | ]
	end
	result
end

def referer_of_today_long( diary, limit )
	return '' if not diary or diary.count_referers == 0
	result = %Q[<div class="caption">#{referer_today}</div>\n]
	result << %Q[<ul>\n]
	diary.each_referer( limit ) do |count,ref|
		result << %Q[<li>#{count} <a href="#{CGI::escapeHTML( ref )}">#{CGI::escapeHTML( diary.disp_referer( @referer_table, ref ) )}</a></li>\n]
	end
	result + '</ul>'
end

#
# labels
#
def comment_today; '本日のツッコミ'; end
def comment_total( total ); "(全#{total}件)"; end
def comment_new; 'ツッコミを入れる'; end
def comment_description; 'ツッコミ・コメントがあればどうぞ! E-mailアドレスは公開されません。'; end
def comment_description_short; 'ツッコミ!!'; end
def comment_name_label; 'お名前'; end
def comment_name_label_short; '名前'; end
def comment_mail_label; 'E-mail'; end
def comment_mail_label_short; 'Mail'; end
def comment_body_label; 'コメント'; end
def comment_body_label_short; '本文'; end
def comment_submit_label; '投稿'; end
def comment_submit_label_short; '投稿'; end
def comment_date( time ); time.strftime( "(#{@date_format} %H:%M)" ); end
def referer_today; '本日のリンク元'; end

def navi_latest; '最新'; end
def navi_prev_day(date); "前の日記(#{date})"; end
def navi_next_day(date); "次の日記(#{date})"; end
def navi_prev_day2(date); "先月末日(#{date})"; end
def navi_next_day2(date); "翌月1日(#{date})"; end

def submit_command
	if @mode == 'form' then
		'append'
	else
		'replace'
	end
end
def submit_label
	if @mode == 'form' then
		'追加'
	else
		'登録'
	end
end

