#
# 00default.rb: default plugins 
# $Revision: 1.3 $
#

#
# make navigation buttons
#
def navi
	result = %Q[<p class="adminmenu">\n]
	result << navi_user
	result << navi_admin
	result << %Q[</p>]
end

def navi_user
	result = ''
	result << %Q[<span class="adminmenu"><a href="#{@index_page}">トップ</a></span>\n] unless @index_page.empty?
	result << %Q[<span class="adminmenu"><a href="#{@index}#{anchor( (@date-24*60*60).strftime( '%Y%m%d' ) )}">&lt;前日</a></span>\n] if /^(day|comment)$/ =~ @mode
	result << %Q[<span class="adminmenu"><a href="#{@index}#{anchor( (@date+24*60*60).strftime( '%Y%m%d' ) )}">翌日&gt;</a></span>\n] if /^(day|comment)$/ =~ @mode
	result << %Q[<span class="adminmenu"><a href="#{@index}">最新</a></span>\n] unless @mode == 'latest'
	result
end

def navi_admin
	result = %Q[<span class="adminmenu"><a href="#{@update}">更新</a></span>\n]
	result << %Q[<span class="adminmenu"><a href="#{@update}?conf=OK">設定</a></span>\n] if /^(latest|month|day|comment|conf)$/ !~ @mode
	result
end

#
# make calendar
#
def calendar
	result = %Q[<p class="calendar">\n]
	@years.keys.sort.each do |year|
		result << %Q[#{year}|]
		@years[year.to_s].sort.each do |month|
			m = "#{year}#{month}"
			result << %Q[<a href="#{@index}#{anchor m}">#{month}</a>|]
		end
		result << "<br>\n"
	end
	result << "</p>"
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
	%Q[<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">]
end

#
# default HTML header
#
add_header_proc( Proc::new do
	<<-HEADER
	<meta http-equiv="Content-Type" content="text/html; charset=EUC-JP">
	<meta name="generator" content="tDiary #{TDIARY_VERSION}">
	#{author_name_tag}
	#{author_mail_tag}
	#{index_page_tag}
	#{css_tag.chomp}
	#{title_tag.chomp}
	HEADER
end )

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
		css = "#{theme_url}/#{@theme}.css"
	else
		css = @css
	end
	<<-CSS
	<meta http-equiv="content-style-type" content="text/css" media="all">
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
	result = %Q[<p class="referer">#{referer_today} | ]
	diary.each_referer( limit ) do |count,ref|
		result << %Q[<a href="#{CGI::escapeHTML( ref )}" title="#{CGI::escapeHTML( diary.disp_referer( @referer_table, ref ) )}">#{count}</a> | ]
	end
	result + '</p>'
end

def referer_of_today_long( diary, limit )
	return '' if not diary or diary.count_referers == 0
	result = %Q[<div class="refererlist"><p class="referertitle">#{referer_today}</p>\n]
	result << %Q[<ul class="referer">\n]
	diary.each_referer( limit ) do |count,ref|
		result << %Q[<li>#{count} <a href="#{CGI::escapeHTML( ref )}">#{CGI::escapeHTML( diary.disp_referer( @referer_table, ref ) )}</a></li>\n]
	end
	result + '</ul></div>'
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

