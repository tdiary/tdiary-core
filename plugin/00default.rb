#
# 00default.rb: default plugins 
# $Revision: 1.53 $
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
	calc_links if /^(latest|month|day|nyear)$/ === @mode
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
	result << %Q[<A HREF="#{@update}?conf=default" ACCESSKEY="9">[9]#{mobile_navi_preference#}</A>] unless /^(latest|month|day|conf|nyear)$/ === @mode
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
	if @mode == 'day' or @conf.mobile_agent? then
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
		today = @date.strftime('%Y%m%d')
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
	@conf.charset( @conf.mobile_agent? )
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
		result << %Q[<link rel="start" title="#{navi_index}" href="#{@index_page}">\n\t]
	end
	oldest = @years.keys.sort[0]
	if oldest then
		result << %Q[<link rel="first" title="#{navi_oldest}" href="#{@index}#{anchor( oldest + @years[oldest][0])}">\n\t]
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
	result << %Q[<link rel="last" title="#{navi_latest}" href="#{@index}">\n\t]
	result.chop.chop
end

def theme_url; 'theme'; end

def css_tag
	if @theme and @theme.length > 0 then
		css = "#{theme_url}/#{@theme}/#{@theme}.css"
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

def title_tag
	r = "<title>#{@html_title}"
	case @mode
	when 'day', 'comment'
		r << "(#{@date.strftime( '%Y-%m-%d' )})" if @date
	when 'month'
		r << "(#{@date.strftime( '%Y-%m' )})" if @date
	when 'form'
		r << '(追記)'
	when 'edit'
		r << '(編集)'
	when 'preview'
		r << '(プレビュー)'
	when 'showcomment'
		r << '(変更完了)'
	when 'conf'
		r << '(設定)'
	when 'saveconf'
		r << '(設定完了)'
	when 'nyear'
		years = @diaries.keys.map {|ymd| ymd.sub(/^\d{4}/, "")}
		r << "(#{@cgi.params['date'][0].sub( /^(\d\d)/, '\1-')}[#{nyear_diary_label @date, years}])" if @date
	end
	r << '</title>'
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
	if title then
		%Q[<a href="#{@index}#{anchor a}" title="#{title}">#{str}</a>]
	else
		%Q[<a href="#{@index}#{anchor a}">#{str}</a>]
	end
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
# other resources
#
def html_lang
	"ja-JP"
end

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

	name = comment_mail_mime( @comment.name.to_jis )[0]
	body = @comment.body.sub( /[\r\n]+\Z/, '' ).to_jis
	mail = @comment.mail
	mail = @conf.author_mail unless mail =~ %r<[0-9a-zA-Z_.-]+@[\(\)%!0-9a-zA-Z_$@.&+-,'"*-]+>
	
	now = Time::now
	g = now.dup.gmtime
	l = Time::local( g.year, g.month, g.day, g.hour, g.min, g.sec )
	tz = (g.to_i - l.to_i) / 36
	date = now.strftime( "%a, %d %b %Y %X " ) + sprintf( "%+05d", tz )

	serial = @diaries[@date.strftime( '%Y%m%d' )].count_comments( true )
	message_id = %Q!<tdiary.#{[@conf['comment_mail.header'] || ''].pack('m').gsub(/\n/,'')}.#{now.strftime('%Y%m%d%H%M%S')}.#{serial}@#{Socket::gethostname.sub(/^.+?\./,'')}>!

	mail_header = (@conf['comment_mail.header'] || '').dup
	mail_header << ":#{@conf.date_format}" unless /%[a-zA-Z%]/ =~ mail_header
	mail_header = @date.strftime( mail_header )
	mail_header = comment_mail_mime( mail_header.to_jis ).join( "\n " ) if /[\x80-\xff]/ =~ mail_header

	rmail = ''
	begin
		if @conf.lang then
			rmail = File::open( "#{TDiary::PATH}/skel/mail.rtxt.#{@conf.lang}" ){|f| f.read }
		else
			rmail = File::open( "#{TDiary::PATH}/skel/mail.rtxt" ){|f| f.read }
		end
	rescue
		rmail = File::open( "#{TDiary::PATH}/skel/mail.rtxt" ){|f| f.read }
	end
	text = ERbLight::new( rmail.untaint ).result( binding )
	comment_mail( text, receivers )
end

def comment_mail_mime( str )
	require 'nkf'
	NKF::nkf( "-j -m0 -f50", str ).collect do |s|
		%Q|=?ISO-2022-JP?B?#{[s.chomp].pack( 'm' ).gsub( /\n/, '' )}?=|
	end
end

def comment_mail( text )
	# no action in default.
	# override by each plugins.
end

def comment_mail_conf_label; 'ツッコミメール'; end

def comment_mail_basic_setting
	if @mode == 'saveconf' then
		@conf['comment_mail.enable'] = @cgi.params['comment_mail.enable'][0] == 'true' ? true : false
		@conf['comment_mail.receivers'] = @cgi.params['comment_mail.receivers'][0].strip.gsub( /[\n\r]+/, ',' )
		@conf['comment_mail.header'] = @cgi.params['comment_mail.header'][0]
	end
end

def comment_mail_basic_html
	@conf['comment_mail.header'] = '' unless @conf['comment_mail.header']
	@conf['comment_mail.receivers'] = '' unless @conf['comment_mail.receivers']

	<<-HTML
	<h3 class="subtitle">ツッコミメールを送る</h3>
	#{"<p>ツッコミがあった時に、メールを送るかどうかを選択します。</p>" unless @conf.mobile_agent?}
	<p><select name="comment_mail.enable">
		<option value="true"#{if @conf['comment_mail.enable'] then " selected" end}>送る</option>
        <option value="false"#{if not @conf['comment_mail.enable'] then " selected" end}>送らない</option>
	</select></p>
	<h3 class="subtitle">送付先</h3>
	#{"<p>メールの送付先を指定します。1行に1メールアドレスの形で、複数指定可能です。指定のない場合には、あなたのメールアドレスに送られます。</p>" unless @conf.mobile_agent?}
	<p><textarea name="comment_mail.receivers" cols="40" rows="3">#{CGI::escapeHTML( @conf['comment_mail.receivers'].gsub( /[, ]+/, "\n") )}</textarea></p>
	<h3 class="subtitle">メールヘッダ</h3>
	#{"<p>メールのSubjectにつけるヘッダ文字列を指定します。振り分け等に便利なように指定します。実際のSubjectには「指定文字列:日付-1」のように、日付とコメント番号が付きます。ただし指定文字列中に、%に続く英字があった場合、それを日付フォーマット指定を見なします。つまり「日付」の部分は自動的に付加されなくなります(コメント番号は付加されます)。</p>" unless @conf.mobile_agent?}
	<p><input name="comment_mail.header" value="#{CGI::escapeHTML( @conf['comment_mail.header'])}"></p>
	HTML
end

#
# detect bot from User-Agent
#
bot = ["googlebot", "Hatena Antenna", "moget@goo.ne.jp"]
bot += @conf['bot'] || []
@bot = Regexp::new( "(#{bot.join( '|' )})" )

def bot?
	@bot =~ @cgi.user_agent
end

#
# link to HOWTO write diary
#
def style_howto
	key = case @conf.style
		when /^tDiary$/i; 'tDiary%A5%B9%A5%BF%A5%A4%A5%EB'
		when /^Wiki$/i; 'Wiki%A5%B9%A5%BF%A5%A4%A5%EB'
		when /^etDiary$/i; 'etDiary%A5%B9%A5%BF%A5%A4%A5%EB'
		when /^RD$/i; 'RD%A5%B9%A5%BF%A5%A4%A5%EB'
		when /^emptDiary$/i; 'emptDiary%A5%B9%A5%BF%A5%A4%A5%EB'
		else;	return ''
		end
	%Q|/<a href="http://tdiary-users.sourceforge.jp/cgi-bin/wiki.cgi?#{key}">書き方</a>|
end

#
# labels (normal)
#
def no_diary; "#{@date.strftime( @conf.date_format )}の日記はありません。"; end
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

def navi_index; 'トップ'; end
def navi_latest; '最新'; end
def navi_oldest; '最古'; end
def navi_update; "追記"; end
def navi_edit; "編集"; end
def navi_preference; "設定"; end
def navi_prev_diary(date); "前の日記(#{date.strftime(@date_format)})"; end
def navi_next_diary(date); "次の日記(#{date.strftime(@date_format)})"; end
def navi_prev_nyear(date); "前の日(#{date.strftime('%m-%d')})"; end
def navi_next_nyear(date); "次の日(#{date.strftime('%m-%d')})"; end

def submit_label
	if @mode == 'form' or @cgi.valid?( 'appendpreview' ) then
		'追記'
	else
		'登録'
	end
end
def preview_label; 'プレビュー'; end

def label_no_referer; 'リンク元記録除外リスト'; end
def label_referer_table; 'リンク置換リスト'; end

def nyear_diary_label(date, years); "長年日記"; end
def nyear_diary_title(date, years); "長年日記"; end

#
# labels (for mobile)
#
def mobile_navi_latest; '最新'; end
def mobile_navi_update; "追記"; end
def mobile_navi_preference; "設定"; end
def mobile_navi_prev_diary; "前"; end
def mobile_navi_next_diary; "次"; end
def mobile_label_hidden_diary; 'この日は【非表示】です'; end

#
# category
#
def category_anchor(c); "[#{c}]"; end
def category_title; "カテゴリ別"; end
def category_title_year(year); "#{year}年"; end
def category_title_month(year, month); "#{year}年#{month}月"; end
def category_title_quarter(year, q); "#{year}年#{q}Q"; end
def category_title_latest; "今月"; end

#
# preferences
#

# basic (default)
def saveconf_default
	if @mode == 'saveconf' then
		@conf.author_name = @cgi.params['author_name'][0].to_euc
		@conf.author_mail = @cgi.params['author_mail'][0]
		@conf.index_page = @cgi.params['index_page'][0]
		@conf.hour_offset = @cgi.params['hour_offset'][0].to_f
	end
end

add_conf_proc( 'default', '基本' ) do
	saveconf_default
	<<-HTML
	<h3 class="subtitle">著者名</h3>
	#{"<p>あなたの名前を指定します。HTMLヘッダ中に展開されます。</p>" unless @conf.mobile_agent?}
	<p><input name="author_name" value="#{CGI::escapeHTML @conf.author_name}" size="40"></p>
	<h3 class="subtitle">メールアドレス</h3>
	#{"<p>あなたのメールアドレスを指定します。HTMLヘッダ中に展開されます。</p>" unless @conf.mobile_agent?}
	<p><input name="author_mail" value="#{@conf.author_mail}" size="40"></p>
	<h3 class="subtitle">トップページURL</h3>
	#{"<p>日記よりも上位のコンテンツがあれば指定します。存在しない場合は何も入力しなくてかまいません。</p>" unless @conf.mobile_agent?}
	<p><input name="index_page" value="#{@conf.index_page}" size="50"></p>
	<h3 class="subtitle">時差調整</h3>
	#{"<p>更新時、フォームに挿入される日付を時間単位で調整できます。例えば午前2時までは前日として扱いたい場合には「-2」のように指定することで、2時間分引かれた日付が挿入されるようになります。また、この日付はWebサーバ上の時刻になっているので、海外のサーバで運営している場合の時差調整にも利用できます。</p>" unless @conf.mobile_agent?}
	<p><input name="hour_offset" value="#{@conf.hour_offset}" size="5"></p>
	HTML
end

# header/footer (header)
def saveconf_header
	if @mode == 'saveconf' then
		@conf.html_title = @cgi.params['html_title'][0].to_euc
		@conf.header = @cgi.params['header'][0].to_euc.gsub( /\r\n/, "\n" ).gsub( /\r/, '' ).sub( /\n+\z/, '' )
		@conf.footer = @cgi.params['footer'][0].to_euc.gsub( /\r\n/, "\n" ).gsub( /\r/, '' ).sub( /\n+\z/, '' )
	end
end

add_conf_proc( 'header', 'ヘッダ・フッタ' ) do
	saveconf_header

	<<-HTML
	<h3 class="subtitle">タイトル</h3>
	#{"<p>HTMLの&lt;title&gt;タグ中および、モバイル端末からの参照時に使われるタイトルです。HTMLタグは使えません。</p>" unless @conf.mobile_agent?}
	<p><input name="html_title" value="#{ CGI::escapeHTML @conf.html_title }" size="50"></p>
	<h3 class="subtitle">ヘッダ</h3>
	#{"<p>日記の先頭に挿入される文章を指定します。HTMLタグが使えます。「&lt;%=navi%&gt;」で、ナビゲーションボタンを挿入できます(これがないと更新ができなくなるので削除しないようにしてください)。また、「&lt;%=calendar%&gt;」でカレンダーを挿入できます。その他、各種プラグインを記述できます。</p>" unless @conf.mobile_agent?}
	<p><textarea name="header" cols="70" rows="10">#{ CGI::escapeHTML @conf.header }</textarea></p>
	<h3 class="subtitle">フッタ</h3>
	#{"<p>日記の最後に挿入される文章を指定します。ヘッダと同様に指定できます。</p>" unless @conf.mobile_agent?}
	<p><textarea name="footer" cols="70" rows="10">#{ CGI::escapeHTML @conf.footer }</textarea></p>
	HTML
end

# diaplay
def saveconf_display
	if @mode == 'saveconf' then
		@conf.section_anchor = @cgi.params['section_anchor'][0].to_euc
		@conf.comment_anchor = @cgi.params['comment_anchor'][0].to_euc
		@conf.date_format = @cgi.params['date_format'][0].to_euc
		@conf.latest_limit = @cgi.params['latest_limit'][0].to_i
		@conf.latest_limit = 10 if @conf.latest_limit < 1
		@conf.show_nyear = @cgi.params['show_nyear'][0] == 'true' ? true : false
	end
end

add_conf_proc( 'display', '表示一般' ) do
	saveconf_display

	<<-HTML
	<h3 class="subtitle">セクションアンカー</h3>
	#{"<p>日記のセクションの先頭(サブタイトルの行頭)に挿入される、リンク用のアンカー文字列を指定します。なお「&lt;span class=\"sanchor\"&gt;_&lt;/span&gt;」を指定すると、テーマによっては自動的に画像アンカーがつくようになります。</p>" unless @conf.mobile_agent?}
	<p><input name="section_anchor" value="#{ CGI::escapeHTML @conf.section_anchor }" size="40"></p>
	<h3 class="subtitle">ツッコミアンカー</h3>
	#{"<p>読者からのツッコミの先頭に挿入される、リンク用のアンカー文字列を指定します。なお「&lt;span class=\"canchor\"&gt;_&lt;/span&gt;」を指定すると、テーマによっては自動的に画像アンカーがつくようになります。</p>" unless @conf.mobile_agent?}
	<p><input name="comment_anchor" value="#{ CGI::escapeHTML @conf.comment_anchor }" size="40"></p>
	<h3 class="subtitle">日付フォーマット</h3>
	#{"<p>日付の表示部分に使われるフォーマットを指定します。任意の文字が使えますが、「%」で始まる英字には次のような特殊な意味があります。「%Y」(西暦年)、「%m」(月数値)、「%b」(短月名)、「%B」(長月名)、「%d」(日)、「%a」(短曜日名)、「%A」(長曜日名)。</p>" unless @conf.mobile_agent?}
	<p><input name="date_format" value="#{ CGI::escapeHTML @conf.date_format }" size="30"></p>
	<h3 class="subtitle">最新表示の最大日数</h3>
	#{"<p>最新の日記を表示するときに、そのページ内に何日分の日記を表示するかを指定します。</p>" unless @conf.mobile_agent?}
	<p>最大<input name="latest_limit" value="#{ @conf.latest_limit }" size="2">日分</p>
	<h3 class="subtitle">長年日記の表示</h4>
	#{"<p>長年日記を表示するためのリンクを表示するかどうかを指定します。</p>" unless @conf.mobile_agent?}
	<p><select name="show_nyear">
		<option value="true"#{if @conf.show_nyear then " selected" end}>表示</option>
        <option value="false"#{if not @conf.show_nyear then " selected" end}>非表示</option>
	</select></p>
	HTML
end

# themes
def saveconf_theme
	if @mode == 'saveconf' then
		@conf.theme = @cgi.params['theme'][0]
		@conf.css = @cgi.params['css'][0]
	end
end

if @mode =~ /^(conf|saveconf)$/ then
	@conf_theme_list = []
	Dir::glob( "#{::TDiary::PATH}/theme/*" ).sort.each do |dir|
		theme = dir.sub( %r[.*/theme/], '')
		next unless FileTest::file?( "#{dir}/#{theme}.css".untaint )
		name = theme.split( /_/ ).collect{|s| s.capitalize}.join( ' ' )
		@conf_theme_list << [theme,name]
	end
end

add_conf_proc( 'theme', 'テーマ' ) do
	saveconf_theme

	 r = <<-HTML
	<h3 class="subtitle">テーマの指定</h3>
	#{"<p>日記のデザインをテーマ、もしくはCSSの直接入力で指定します。ドロップダウンメニューから「CSS指定→」を選択した場合には、右の欄にCSSのURLを入力してください。</p>" unless @conf.mobile_agent?}
	<p>
	<select name="theme">
		<option value="">CSS指定→</option>
	HTML
	@conf_theme_list.each do |theme|
		r << %Q|<option value="#{theme[0]}"#{if theme[0] == @conf.theme then " selected" end}>#{theme[1]}</option>|
	end
	r << <<-HTML
	</select>
	<input name="css" size="50" value="#{ @conf.css }">
	</p>
	#{"<p>ここにないテーマは<a href=\"http://www.tdiary.org/20021001.html\">テーマ・ギャラリー</a>から入手できます。</p>" unless @conf.mobile_agent?}
	HTML
end

# comments
def saveconf_comment
	if @mode == 'saveconf' then
		@conf.show_comment = @cgi.params['show_comment'][0] == 'true' ? true : false
		@conf.comment_limit = @cgi.params['comment_limit'][0].to_i
		@conf.comment_limit = 3 if @conf.comment_limit < 1
	end
end

add_conf_proc( 'comment', 'ツッコミ' ) do
	saveconf_comment

	<<-HTML
	<h3 class="subtitle">ツッコミの表示</h3>
	#{"<p>読者からのツッコミを表示するかどうかを指定します。</p>" unless @conf.mobile_agent?}
	<p><select name="show_comment">
		<option value="true"#{if @conf.show_comment then " selected" end}>表示</option>
		<option value="false"#{if not @conf.show_comment then " selected" end}>非表示</option>
	</select></p>
	<h3 class="subtitle">ツッコミリスト表示数</h3>
	#{"<p>最新もしくは月別表示時に表示する、ツッコミの最大件数を指定します。なお、日別表示時にはここの指定にかかわらずすべてのツッコミが表示されます。</p>" unless @conf.mobile_agent?}
	<p>最大<input name="comment_limit" value="#{ @conf.comment_limit }" size="3">件</p>
	HTML
end

# referer
def saveconf_referer
	if @mode == 'saveconf' then
		@conf.show_referer = @cgi.params['show_referer'][0] == 'true' ? true : false
		@conf.referer_limit = @cgi.params['referer_limit'][0].to_i
		@conf.referer_limit = 10 if @conf.referer_limit < 1
		no_referer2 = []
		@cgi.params['no_referer'][0].to_euc.each do |ref|
			ref.strip!
			no_referer2 << ref if ref.length > 0
		end
		@conf.no_referer2 = no_referer2
		referer_table2 = []
		@cgi.params['referer_table'][0].to_euc.each do |pair|
			u, n = pair.sub( /[\r\n]+/, '' ).split( /[ \t]+/, 2 )
			referer_table2 << [u,n] if u and n
		end
		@conf.referer_table2 = referer_table2
	end
end

add_conf_proc( 'referer', 'リンク元' ) do
	saveconf_referer

	<<-HTML
	<h3 class="subtitle">リンク元の表示</h3>
	#{"<p>リンク元リストを表示するかどうかを指定します。</p>" unless @conf.mobile_agent?}
	<p><select name="show_referer">
		<option value="true"#{if @conf.show_referer then " selected" end}>表示</option>
		<option value="false"#{if not @conf.show_referer then " selected" end}>非表示</option>
	</select></p>
	<h3 class="subtitle">リンク元リスト表示数</h3>
	#{"<p>最新もしくは月別表示時に表示する、リンク元リストの最大件数を指定します。なお、日別表示時にはここの指定にかかわらずすべてのリンク元が表示されます。</p>" unless @conf.mobile_agent?}
	<p>最大<input name="referer_limit" value="#{@conf.referer_limit}" size="3">サイト</p>
	<h3 class="subtitle">リンク元記録除外リスト</h3>
	#{"<p>リンク元リストに追加しないURLを指定します。正規表現で指定できます。1件1行で入力してください。</p>" unless @conf.mobile_agent?}
	<p>→<a href="#{@conf.update}?referer=no" target="referer">既存設定はこちら</a></p>
	<p><textarea name="no_referer" cols="70" rows="10">#{@conf.no_referer2.join( "\n" )}</textarea></p>
	<h3 class="subtitle">リンク元置換リスト</h3>
	#{"<p>リンク元リストのURLを、特定の文字列に変換する対応表を指定できます。1件につき、URLと表示文字列を空白で区切って指定します。正規表現が使えるので、URL中に現れた「(〜)」は、置換文字列中で「\\1」のような「\数字」で利用できます。</p>" unless @conf.mobile_agent?}
	<p>→<a href="#{@conf.update}?referer=table" target="referer">既存設定はこちら</a></p>
	<p><textarea name="referer_table" cols="70" rows="10">#{@conf.referer_table2.collect{|a|a.join( " " )}.join( "\n" )}</textarea></p>
	HTML
end

