# -*- coding: utf-8; -*-
#
# zh/00default.rb: Traditional-Chinese resources of 00default.rb.
#
# Copyright (C) 2001-2005, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#

#
# header
#
def title_tag
	r = "<title>#{h @html_title}"
	case @mode
	when 'day', 'comment'
		r << "(#{@date.strftime( '%Y-%m-%d' )})" if @date
	when 'month'
		r << "(#{@date.strftime( '%Y-%m' )})" if @date
	when 'form'
		r << '(Append)'
	when 'edit'
		r << '(Edit)'
	when 'preview'
		r << '(Preview)'
	when 'showcomment'
		r << '(TSUKKOMI Status Change Completed)'
	when 'conf'
		r << '(Preferences)'
	when 'saveconf'
		r << '(Preferences Changed)'
	when 'nyear'
		years = @diaries.keys.map {|ymd| ymd.sub(/^\d{4}/, "")}
		r << "(#{years[0].sub( /^(\d\d)/, '\1-')}[#{nyear_diary_label @date, years}])" if @date
	end
	r << '</title>'
end

#
# link to HOWTO write diary
#
def style_howto
	%Q|/<a href="http://docs.tdiary.org/en/?#{h @conf.style}Style">撰寫指引</a>|
end

#
# labels
#
def no_diary; "#{@date.strftime( @conf.date_format )} 這天沒有發表日誌"; end
def comment_today; "今日迴響"; end
def comment_total( total ); "(總共有: #{total} 則)"; end
def comment_new; '發表迴響'; end
def comment_description_default; '歡迎發表您對本文的迴響，您填寫的 email 位址只有日誌主人可以看見。'; end
def comment_limit_label; 'You cannot make more TSUKKOMI because it has over limit.'; end
def comment_description_short; '發表迴響!!'; end
def comment_name_label; '姓名'; end
def comment_name_label_short; '姓名'; end
def comment_mail_label; '電子郵件'; end
def comment_mail_label_short; '郵件'; end
def comment_body_label; '迴響'; end
def comment_body_label_short; '迴響'; end
def comment_submit_label; '發表'; end
def comment_submit_label_short; '發表'; end
def comment_date( time ); time.strftime( "(#{@date_format} %H:%M)" ); end
def trackback_today; "今日引用"; end
def trackback_total( total ); "(總共有: #{total} 則)"; end

def navi_index; '首頁'; end
def navi_latest; '最新日誌'; end
def navi_oldest; '最舊日誌'; end
def navi_update; "新增"; end
def navi_edit; "編輯"; end
def navi_preference; "選項設定"; end
def navi_prev_diary(date); "前一則日誌 (#{date.strftime(@date_format)})"; end
def navi_next_diary(date); "下一則日誌 (#{date.strftime(@date_format)})"; end
def navi_prev_month; "Prev month"; end
def navi_next_month; "Next month"; end
def navi_prev_nyear(date); "去年日誌 (#{date.strftime('%m-%d')})"; end
def navi_next_nyear(date); "次年日誌 (#{date.strftime('%m-%d')})"; end
def navi_prev_ndays; "#{@conf.latest_limit} days before"; end
def navi_next_ndays; "#{@conf.latest_limit} days after"; end

def submit_label
	if @mode == 'form' or @cgi.valid?( 'appendpreview' ) then
		'新增' #'Append'
	else
		'替換' #'Replace'
	end
end
def preview_label; '預覽'; end #'Preview'

def nyear_diary_label(date, years); "往日情懷"; end
def nyear_diary_title(date, years); "過去的此時此刻"; end


#
# labels (for mobile)
#
def mobile_navi_latest; '殻、鮟x'; end
def mobile_navi_update; "キsシW"; end
def mobile_navi_edit; "スsソ; end
def mobile_navi_preference; "随教ゥw"; end
def mobile_navi_prev_diary; "ォe、@ォh、鮟x})"; end
def mobile_navi_next_diary; "、U、@ォh、鮟x})"; end
def mobile_label_hidden_diary; 'This day is HIDDEN.'; end

#
# category
#
def category_anchor(c); "[#{c}]"; end

#
# preferences
#

# genre labels
@conf_genre_label['basic'] = '基本'
@conf_genre_label['theme'] = 'Themes'
@conf_genre_label['tsukkomi'] = 'TSUKKOMI'
@conf_genre_label['referer'] = 'Referrer'
@conf_genre_label['security'] = 'Security'
@conf_genre_label['etc'] = 'etc'

# basic (default)
add_conf_proc( 'default', '基本設定', 'basic' ) do
	saveconf_default
	@conf.description ||= ''
	@conf.icon ||= ''
	@conf.banner ||= ''
	<<-HTML
	<h3 class="subtitle">大標題</h3>
	#{"<p>這是您日誌的大標題，您填入的值會用在 HTML 的 &lt;title&gt; 項目當中。特別注意，本欄位請勿使用 HTML 標籤(tags)。 </p>" unless @conf.mobile_agent?}
	<p><input name="html_title" value="#{h @conf.html_title}" size="50"></p>

	<h3 class="subtitle">作者</h3>
	#{"<p>填上您的大名吧！此欄位的值將會用在 HTML 標頭(header)裡。</p>" unless @conf.mobile_agent?}
	<p><input name="author_name" value="#{h @conf.author_name}" size="40"></p>

	<h3 class="subtitle">電子郵件</h3>
	#{"<p>填入您的電子郵件位址，此欄位的值將用在 HTML 標頭(header)裡。</p>" unless @conf.mobile_agent?}
	<p><input name="author_mail" value="#{h @conf.author_mail}" size="40"></p>

	<h3 class="subtitle">您索引網頁(首頁)的 URL</h3>
	#{"<p>若您有自己的網站位址，可以填註在下面。</p>" unless @conf.mobile_agent?}
	<p><input name="index_page" value="#{h @conf.index_page}" size="50"></p>

	<h3 class="subtitle">URL of Your Diary</h3>
	#{"<p>Specify your diary's URL. This URL is used by some plugins for indicate your diary</p>" unless @conf.mobile_agent?}
	#{"<p><strong>NOTICE!! The URL specified below is different from current URL of accessed now.</strong></p>" unless @conf.base_url == @conf.base_url_auto}
	<p><input name="base_url" value="#{h @conf.base_url}" size="70"></p>

	<h3 class="subtitle">Description</h3>
	#{"<p>A brief description of your diary. Can be left blank.</p>" unless @conf.mobile_agent?}
	<p><input name="description" value="#{h @conf.description}" size="70"></p>

	<h3 class="subtitle">Site icon (favicon)</h3>
	#{"<p>URL for the small icon (aka 'favicon') of your site. Can be left blank.</p>" unless @conf.mobile_agent?}
	<p><input name="icon" value="#{h @conf.icon}" size="70"></p>

	<h3 class="subtitle">Site banner</h3>
	#{"<p>URL for the banner image of your site. makerss plugin will use this value to make RSS. Can be left blank.</p>" unless @conf.mobile_agent?}
	<p><input name="banner" value="#{h @conf.banner}" size="70"></p>
	HTML
end

# header/footer (header)
add_conf_proc( 'header', '頁眉與頁腳', 'basic' ) do
	saveconf_header

	<<-HTML
	<h3 class="subtitle">頁眉</h3>
	#{"<p>這段文字將會擺置在每個頁面的頂端，您可以使用 HTML 語法。但是請勿移除 \"&lt;%=navi%&gt;\"標籤，因為它代表包含\"更新\"(Update)功\能鈕在內的「導覽列」，而 \"&lt;%=calendar%&gt;\" 標籤代表日曆。此處您也可以自由搭配其它的 plugin。 </p>" unless @conf.mobile_agent?}
	<p><textarea name="header" cols="70" rows="10">#{h @conf.header}</textarea></p>
	<h3 class="subtitle">頁腳</h3>
	#{"<p>這段文字除了它的位置是置於底端以外，其餘都如同頁眉。 </p>" unless @conf.mobile_agent?}
	<p><textarea name="footer" cols="70" rows="10">#{h @conf.footer}</textarea></p>
	HTML
end

# diaplay
add_conf_proc( 'display', '顯示', 'basic' ) do
	saveconf_display

	<<-HTML
	<h3 class="subtitle">段落的錨點(anchor)代表記號</h3>
	#{"<p>\"錨點\" 的意義在於讓其它網站可以與您的日誌互相連結。段落錨點會被置於每個段落的開頭處，您可以指定 \"&lt;span class=\"sanchor\"&gt;_&lt;/span&gt;\"，而圖形化錨點的有無，會由佈景主題的設計來決定。 </p>" unless @conf.mobile_agent?}
	<p><input name="section_anchor" value="#{h @conf.section_anchor}" size="40"></p>
	<h3 class="subtitle">迴響的錨點(anchor)代表記號</h3>
	#{"<p>迴響的錨點會置於每則迴響的開頭處，您可以指定 \"&lt;span class=\"canchor\"&gt;_&lt;/span&gt;\"。</p>" unless @conf.mobile_agent?}
	<p><input name="comment_anchor" value="#{h @conf.comment_anchor}" size="40"></p>
	<h3 class="subtitle">日期的格式</h3>
	#{"<p>日期的格式，一旦您指定下列這些 % 符號之後搭配的字元，其組合就可代表日期格式，如 \"%Y\"(年), \"%m\"(月)﹜\"%b\"(月份的簡短表示法), \"%B\"(月份的長表示法), \"%d\"(日), \"%a\"(星期的簡短表示法), \"%A\"(星期的長表示法)。</p>" unless @conf.mobile_agent?}
	<p><input name="date_format" value="#{h @conf.date_format}" size="30"></p>
	<h3 class="subtitle">「最新日誌」最多要秀出幾天份？</h3>
	#{"<p>在「最新日誌」當中，您要顯示多少天份的日誌？ </p>" unless @conf.mobile_agent?}
	<p><input name="latest_limit" value="#{h @conf.latest_limit}" size="2"> 天份</p>
	<h3 class="subtitle">往日情懷</h3>
	#{"<p>是否要秀出 \"往日情懷\" (同月同日的過去日誌)？</p>" unless @conf.mobile_agent?}
	<p><select name="show_nyear">
		<option value="true"#{" selected" if @conf.show_nyear}>秀！</option>
		<option value="false"#{" selected" unless @conf.show_nyear}>隱藏</option>
	</select></p>
	HTML
end

# timezone
add_conf_proc( 'timezone', '時間差的調整', 'update' ) do
	saveconf_timezone
	<<-HTML
	<h3 class="subtitle">時間差的調整</h3>
	#{"<p>若是您更新了日誌，您可以透過此欄位(單位為小時)來做自動調整時間差。例如說，您若想要指定在清晨兩點所發表的日誌被當成是昨天的日誌，您就可以在這裡填入 -2。tDiary 會參考此數值來判定這篇日誌的發表日期。 </p>" unless @conf.mobile_agent?}
	<p><input name="hour_offset" value="#{h @conf.hour_offset}" size="5"></p>
	HTML
end

# themes
@theme_location_comment = "<p>您可以在 <a href=\"http://www.tdiary.org/20021001.html\">Theme Gallery</a>(日本語) 取得更多的佈景主題！</p>"
@theme_thumbnail_label = "Thumbnail"

add_conf_proc( 'theme', '佈景主題', 'theme' ) do
	saveconf_theme

	 r = <<-HTML
	<h3 class="subtitle">佈景主題</h3>
	#{"<p>選擇您日誌想要的佈景主題或樣式表(CSS)，如果您選擇了 \"CSS specify\"，請在右(下)方欄位裡輸入 CSS 所在的網址。 </p>" unless @conf.mobile_agent?}
	<p>
	<select name="theme" onChange="changeTheme( theme_thumbnail, this )">
		<option value="">CSS Specify-&gt;</option>
	HTML
	r << conf_theme_list
end

# comments
add_conf_proc( 'comment', '迴響', 'tsukkomi' ) do
	saveconf_comment

	<<-HTML
	<h3 class="subtitle">是否要秀出迴響？</h3>
	#{"<p>要不要秀出讀者們給您的迴響？ </p>" unless @conf.mobile_agent?}
	<p><select name="show_comment">
		<option value="true"#{" selected" if @conf.show_comment}>好</option>
		<option value="false"#{" selected" unless @conf.show_comment}>不要</option>
	</select></p>
	<h3 class="subtitle">要秀出幾篇迴響？</h3>
	#{"<p>在「最新日誌」或「某月日誌」模示下，您想要秀出多少篇可見的迴響？ 相對來說，在「單篇」模示下，所有的迴響都會秀出來。 </p>" unless @conf.mobile_agent?}
	<p>秀出 <input name="comment_limit" value="#{h @conf.comment_limit}" size="3"> 篇迴響</p>
	<h3 class="subtitle">Limit of TSUKKOMI per a day</h3>
	#{"<p>When numbers of TSUKKOMI over this value in a day, nobody can make new TSUKKOMI. If you use TrackBack plugin, this value means sum of TSUKKOMIs and TrackBacks.</p>" unless @conf.mobile_agent?}
	<p><input name="comment_limit_per_day" value="#{h @conf.comment_limit_per_day}" size="3"> TSUKKOMIs</p>
	HTML
end


# comment mail
def comment_mail_mime( str )
	[str.dup]
end

def comment_mail_conf_label; '以信件通知您有迴響'; end

def comment_mail_basic_html
	@conf['comment_mail.header'] = '' unless @conf['comment_mail.header']
	@conf['comment_mail.receivers'] = '' unless @conf['comment_mail.receivers']
	@conf['comment_mail.sendhidden'] = false unless @conf['comment_mail.sendhidden']

	<<-HTML
	<h3 class="subtitle">是否利用信件通知有迴響？</h3>
	#{"<p>請選擇在有新的迴響時要不要以電子郵件通知您。請記得這項功\能需要您在 tdiary.conf 設定 SMTP 伺服器。</p>" unless @conf.mobile_agent?}
	<p><select name="comment_mail.enable">
		<option value="true"#{" selected" if @conf['comment_mail.enable']}>請用郵件通知</option>
        <option value="false"#{" selected" unless @conf['comment_mail.enable']}>不用了</option>
	</select></p>
	<h3 class="subtitle">收件位址</h3>
	#{"<p>請指定要收到迴響通知的電子郵件位址，一行寫一個位址。如果這裡沒有另外指定，則通知信將會寄到您的電子郵件位址。</p>" unless @conf.mobile_agent?}
	<p><textarea name="comment_mail.receivers" cols="40" rows="3">#{h @conf['comment_mail.receivers'].gsub( /[, ]+/, "\n")}</textarea></p>
	<h3 class="subtitle">信件標題</h3>
	#{"<p>指定一個會擺在通知信的「信件標題」開頭處的字串。信件標題會是 \"您指定的字串:DATE-SERIAL NAME\" 的樣式。 \"date\" 是您日誌發表的日期，但是如果您另行指定了日期的樣式，標題則會變為 \"您指定的字串-SERIAL NAME\" (ex: \"hoge:%Y-%m-%d\")</p>" unless @conf.mobile_agent?}
	<p><input name="comment_mail.header" value="#{h @conf['comment_mail.header']}"></p>
	<h3 class="subtitle">About hidden TSUKKOMI</h3>
	#{"<p>Some TSUKKOMI are hidden by filters. You can decide which sending E-mail by hidden TSUKKOMI.</p>" unless @conf.mobile_agent?}
	<p><label for="comment_mail.sendhidden"><input type="checkbox" id="comment_mail.sendhidden" name="comment_mail.sendhidden" value="#{" checked" if @conf['comment_mail.sendhidden']}">Send mail by hidden TSUKKOMI</label></p>
	HTML
end

add_conf_proc( 'csrf_protection', 'CSRF Protection', 'security' ) do
	err = saveconf_csrf_protection
	errstr = ''
	case err
	when :param
		errstr = '<p class="message">Invalid options specified. Configuration not saved.</p>'
	when :key
		errstr = '<p class="message">No key specified. Configuration not saved.</p>'
	end
	csrf_protection_method = @conf.options['csrf_protection_method'] || 1
	csrf_protection_key = @conf.options['csrf_protection_key'] || ''
	<<-HTML
	#{errstr}
	<p>This page configures a protection scheme to prevent "cross-site request forgery" (CSRF) attacks.</p>
	<p>To make CSRF attack, a malicious person prepares a trap link in some web page and lets you visit that page.
	When the trap link is invoked (either by Javascript or your mouse click), <i>your</i> web browser sends a forged request to tDiary.
	Thus, neither encryption nor usual password protection can serve as a protection mechanism.
	TDiary provies two methods -- "checking referer" and "checking CSRF key" -- to prevent such attacks.</p>
	<div class="section">
	<h3 class="subtitle">Checking Referer</h3>
	<h4 class="subtitle">Checks for Referer values</h4>
	<p>#{if [0,1,2,3].include?(csrf_protection_method) then
            '<input type="checkbox" name="check_enabled2" value="true" checked disabled>
            <input type="hidden" name="check_enabled" value="true">'
          else
            '<input type="checkbox" name="check_enabled" value="true">'
        end}Enabled (default)
	</p>
	#{"<p>Configures Referer-based CSRF protection.
	TDiary checks the Referer value sent from your web browser. If the post request comes from some outer page,
	the request will be rejected. This setting can't be disabled through web-based configuration, for safety reasons.</p>
	" unless @conf.mobile_agent?}
	<h3 class="subtitle">Handling of Referer-disabled browsers</h3>
	<p><input type="radio" name="check_referer" value="true" #{if [1,3].include?(csrf_protection_method) then " checked" end}>Reject (default)
	<input type="radio" name="check_referer" value="false" #{if [0,2].include?(csrf_protection_method) then " checked" end}>Accept
	</p>
	#{"<p>Configures handling for requests without any Referer: value.
	By default tDiary rejects such request for safety reasons.
	If your browser is configured not to send Referer values, alter that setting to allow sending Referer, at least for
	originating sites. If it is impossible, configure the key-based CSRF protection below, and
	change this setting to \"Accept\".</p>
	" unless @conf.mobile_agent?}
	</div>
	<div class="section">
	<h3 class="subtitle">Checking CSRF key</h3>
	<h4>Checks for CSRF protection key</h4>
	<p><input type="radio" name="check_key" value="true" #{if [2,3].include?(csrf_protection_method) then " checked" end}>Enabled
	<input type="radio" name="check_key" value="false" #{if [0,1].include?(csrf_protection_method) then " checked" end}>Disabled (default)
	</p>
	#{"<p>TDiary can add a secret key for every post form to prevent CSRF. As long as attackers do not know the secret key,
	forged requests will not be granted. To enable this feature, you must specify the secret key below.
	To allow Referer-disabled browsers, you must enable this setting.</p>" unless @conf.mobile_agent?}
	<h4>CSRF protection key</h4>
	<p><input type="text" name="key" value="#{h csrf_protection_key}" size="20"></p>
	#{"<p>A secret key used for key-based CSRF protection. Specify a secret string which is not easy to guess.
	If this key is leaked, CSRF attacks can be exploited.
	Do not use any passwords used in other places. You need not to remember this phrase to type in.</p>" unless @conf.mobile_agent?}
	#{"<p class=\"message\">Caution:
	Your browser seems not to be sending any Referers, although Referer-based protection is enabled.
	<a href=\"#{h @update}?conf=csrf_protection\">Please open this page again via this link</a>.
	If you see this message again, you must either change your browser setting (temporarily to change these settings, at least),
	or edit \"tdiary.conf\" directly.</p>" if [1,3].include?(csrf_protection_method) && ! @cgi.referer && !@cgi.valid?('referer_exists')}
	</div>
	HTML
end
