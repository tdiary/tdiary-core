# -*- coding: utf-8; -*-
#
# en/00default.rb: English resources of 00default.rb.
#
# Copyright (C) 2001-2005, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2.
#

#
# header
#
def title_tag
	r = "<title>#{h @conf.html_title}"
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
		r << "(#{years[0].sub( /^(\d\d)/, '\1-')}[#{nyear_diary_label}])" if @date
	end
	r << '</title>'
end


#
# link to HOWTO write diary
#
def style_howto
	%Q|/<a href="http://docs.tdiary.org/en/?#{h @conf.style}Style">How to write</a>|
end

#
# labels
#
def no_diary; "No diary on #{@date.strftime( @conf.date_format )}"; end
def comment_today; "Today's TSUKKOMI"; end
def comment_total( total ); "(Total: #{total})"; end
def comment_new; 'Add a TSUKKOMI'; end
def comment_description_default; 'Add a TSUKKOMI or Comment please. E-mail address will be shown to only me.'; end
def comment_limit_label; 'You cannot make more TSUKKOMI because it has over limit.'; end
def comment_description_short; 'TSUKKOMI!!'; end
def comment_name_label; 'Name'; end
def comment_name_label_short; 'Name'; end
def comment_mail_label; 'E-mail'; end
def comment_mail_label_short; 'Mail'; end
def comment_body_label; 'Comment'; end
def comment_body_label_short; 'Comment'; end
def comment_submit_label; 'Submit'; end
def comment_submit_label_short; 'Submit'; end
def comment_date( time ); time.strftime( "(#{@conf.date_format} %H:%M)" ); end
def trackback_today; "Today's TrackBacks"; end
def trackback_total( total ); "(Total: #{total})"; end

def navi_index; 'Top'; end
def navi_latest; 'Latest'; end
def navi_oldest; 'Oldest'; end
def navi_update; "Append"; end
def navi_edit; "Edit"; end
def navi_preference; "Preference"; end
def navi_prev_diary(date); "Prev(#{date.strftime(@conf.date_format)})"; end
def navi_next_diary(date); "Next(#{date.strftime(@conf.date_format)})"; end
def navi_prev_month; "Prev month"; end
def navi_next_month; "Next month"; end
def navi_prev_nyear(date); "Prev(#{date.strftime('%m-%d')})"; end
def navi_next_nyear(date); "Next(#{date.strftime('%m-%d')})"; end
def navi_prev_ndays; "#{@conf.latest_limit} days before"; end
def navi_next_ndays; "#{@conf.latest_limit} days after"; end

def submit_label
	if @mode == 'form' or @cgi.valid?( 'appendpreview' ) then
		'Append'
	else
		'Replace'
	end
end
def preview_label; 'Preview'; end

def nyear_diary_label; "my old days"; end
def nyear_diary_title; "same days in past"; end


#
# labels (for mobile)
#
def mobile_navi_latest; 'Latest'; end
def mobile_navi_update; 'Update'; end
def mobile_navi_edit; "Edit"; end
def mobile_navi_preference; 'Prefs'; end
def mobile_navi_prev_diary; 'Prev'; end
def mobile_navi_next_diary; 'Next'; end
def mobile_label_hidden_diary; 'This day is HIDDEN.'; end

#
# category
#
def category_anchor(c); "[#{c}]"; end

#
# preferences
#
@conf_saving = 'Saving...'

# genre labels
@conf_genre_label['basic'] = 'Basic'
@conf_genre_label['theme'] = 'Themes'
@conf_genre_label['tsukkomi'] = 'TSUKKOMI'
@conf_genre_label['referer'] = 'Referrer'
@conf_genre_label['security'] = 'Security'
@conf_genre_label['etc'] = 'etc'

# basic (default)
add_conf_proc( 'default', 'Site information', 'basic' ) do
	saveconf_default
	@conf.description ||= ''
	@conf.icon ||= ''
	@conf.banner ||= ''
	<<-HTML
	<h3 class="subtitle">Title</h3>
	#{"<p>The title of your diary. This value is used in HTML &lt;title&gt; element and in mobile mode. Do not use HTML tags.</p>" unless @cgi.mobile_agent?}
	<p><input name="html_title" value="#{h @conf.html_title}" size="50"></p>

	<h3 class="subtitle">Author</h3>
	#{"<p>Specify your name. This value is into HTML header.</p>" unless @cgi.mobile_agent?}
	<p><input name="author_name" value="#{h @conf.author_name}" size="40"></p>

	<h3 class="subtitle">E-mail address</h3>
	#{"<p>Specify your E-mail address. This value is into HTML header.</p>" unless @cgi.mobile_agent?}
	<p><input name="author_mail" value="#{h @conf.author_mail}" size="40"></p>

	<h3 class="subtitle">URL of index page</h3>
	#{"<p>The URL of index of your website if you have.</p>" unless @cgi.mobile_agent?}
	<p><input name="index_page" value="#{h @conf.index_page}" size="50"></p>

	<h3 class="subtitle">URL of Your Diary</h3>
	#{"<p>Specify your diary's URL. This URL is used by some plugins for indicate your diary</p>" unless @cgi.mobile_agent?}
	#{"<p><strong>NOTICE!! The URL specified below is different from current URL of accessed now.</strong></p>" unless base_url == @cgi.base_url}
	<p><input name="base_url" value="#{h base_url}" size="70"></p>

	<h3 class="subtitle">Description</h3>
	#{"<p>A brief description of your diary. Can be left blank.</p>" unless @cgi.mobile_agent?}
	<p><input name="description" value="#{h @conf.description}" size="60"></p>

	<h3 class="subtitle">Site icon (favicon)</h3>
	#{"<p>URL for the small icon (aka 'favicon') of your site. Can be left blank.</p>" unless @cgi.mobile_agent?}
	<p><input name="icon" value="#{h @conf.icon}" size="60"></p>

	<h3 class="subtitle">Site banner</h3>
	#{"<p>URL for the banner image of your site. makerss plugin will use this value to make RSS. Can be left blank.</p>" unless @cgi.mobile_agent?}
	<p><input name="banner" value="#{h @conf.banner}" size="60"></p>

	<h3 class="subtitle">Permit display in Frames</h3>
	#{"<p>Permit display your diary included by frames.</p>" unless @cgi.mobile_agent?}
	<p><select name="x_frame_options">
		<option value=""#{" selected" unless @conf.x_frame_options}>Permit</option>
		<option value="SAMEORIGIN"#{" selected" if @conf.x_frame_options == 'SAMEORIGIN'}>Permit in same domain</option>
		<option value="DENY"#{" selected" if @conf.x_frame_options == 'DENY'}>Deny</option>
	</select></p>
	HTML
end

# header/footer (header)
add_conf_proc( 'header', 'Header/Footer', 'basic' ) do
	saveconf_header

	<<-HTML
	<h3 class="subtitle">Header</h3>
	#{"<p>This text is inserted into top of each pages. You can use HTML tags. Do not remove \"&lt;%=navi%&gt;\", because it mean Navigation bar inclued \"Update\" button. And \"&lt;%=calendar%&gt;\" mean calendar. So you can specify other plugins also.</p>" unless @cgi.mobile_agent?}
	<p><textarea name="header" cols="60" rows="10">#{h @conf.header}</textarea></p>
	<h3 class="subtitle">Footer</h3>
	#{"<p>This text is inserted into bottom of each pages. You can specify as same as Header.</p>" unless @cgi.mobile_agent?}
	<p><textarea name="footer" cols="60" rows="10">#{h @conf.footer}</textarea></p>
	HTML
end

# diaplay
add_conf_proc( 'display', 'Display', 'basic' ) do
	saveconf_display

	<<-HTML
	<h3 class="subtitle">Section anchor</h3>
	#{"<p>\"Anchor\" guide to link from other website. Section anchors are insertd into begining of each section. So if you specify \"&lt;span class=\"sanchor\"&gt;_&lt;/span&gt;\", image anchor will be shown Image anchor by themes.</p>" unless @cgi.mobile_agent?}
	<p><input name="section_anchor" value="#{h @conf.section_anchor}" size="40"></p>
	<h3 class="subtitle">TSUKKOMI anchor</h3>
	#{"<p>TSUKKOMI anchor is inserted into begining of each TSUKKOMIs. So You can specify \"&lt;span class=\"canchor\"&gt;_&lt;/span&gt;\" for Image anchor.</p>" unless @cgi.mobile_agent?}
	<p><input name="comment_anchor" value="#{h @conf.comment_anchor}" size="40"></p>
	<h3 class="subtitle">Date format</h3>
	#{"<p>Format of date. If you specify a charactor after %, it mean special about date formatting: \"%Y\"(Year), \"%m\"(Month), \"%b\"(Short name of month), \"%B\"(Long name of month), \"%d\"(Day), \"%a\"(Short name of day of week), \"%A\"(Long name of day of week).</p>" unless @cgi.mobile_agent?}
	<p><input name="date_format" value="#{h @conf.date_format}" size="30"></p>
	<h3 class="subtitle">Max dates of Latest diaplay</h3>
	#{"<p>In the Latest mode, you can specify the number of days in the page.</p>" unless @cgi.mobile_agent?}
	<p><input name="latest_limit" value="#{h @conf.latest_limit}" size="2"> days in a page.</p>
	<h3 class="subtitle">My old days</h3>
	#{"<p>Show the link of \"My old days\"</p>" unless @cgi.mobile_agent?}
	<p><select name="show_nyear">
		<option value="true"#{" selected" if @conf.show_nyear}>Show</option>
		<option value="false"#{" selected" unless @conf.show_nyear}>Hide</option>
	</select></p>
	HTML
end

# timezone
add_conf_proc( 'timezone', 'Time difference adjustment', 'update' ) do
	saveconf_timezone
	<<-HTML
	<h3 class="subtitle">Time difference adjustment</h3>
	#{"<p>When updating diary, you can adjust date which is automatically inserted into the form. The unit is hour. For example, if you want to handle the time until 2 a.m. as the previous day, you set this to -2. tDiary inserts the date which is older by 2 hours than the actual time. </p>" unless @cgi.mobile_agent?}
	<p><input name="hour_offset" value="#{h @conf.hour_offset}" size="5"></p>
	HTML
end

# themes
@theme_location_comment = "<p>You can get many themes from <a href=\"http://www.tdiary.org/20021001.html\">Theme Gallery</a>(Japanese).</p>"
@theme_thumbnail_label = "Thumbnail"

add_conf_proc( 'theme', 'Themes', 'theme' ) do
	saveconf_theme

	r = <<-HTML
	<h3 class="subtitle">Theme</h3>
	#{"<p>Specify the design of your diary using Theme or CSS. When you select \"CSS specify\", input URL of CSS into the field right side.</p>" unless @cgi.mobile_agent?}
	<p>
	<select name="theme" id="theme_selection">
		<option value="">CSS Specify-&gt;</option>
	HTML
	r << conf_theme_list
end

# comments
add_conf_proc( 'comment', 'TSUKKOMI', 'tsukkomi' ) do
	saveconf_comment

	<<-HTML
	<h3 class="subtitle">Show TSUKKOMI</h3>
	#{"<p>Select show or hide TSUKKOMI from readers</p>" unless @cgi.mobile_agent?}
	<p><select name="show_comment">
		<option value="true"#{" selected" if @conf.show_comment}>Show</option>
		<option value="false"#{" selected" unless @conf.show_comment}>Hide</option>
	</select></p>
	<h3 class="subtitle">Number of TSUKKOMI</h3>
	#{"<p>In Latest or Month mode, you can specify number of visible TSUKKOMIs. So in Dayly mode, all of TSUKKOMIs are shown.</p>" unless @cgi.mobile_agent?}
	<p><input name="comment_limit" value="#{h @conf.comment_limit}" size="3"> TSUKKOMIs</p>
	<h3 class="subtitle">Limit of TSUKKOMI per a day</h3>
	#{"<p>When numbers of TSUKKOMI over this value in a day, nobody can make new TSUKKOMI. If you use TrackBack plugin, this value means sum of TSUKKOMIs and TrackBacks.</p>" unless @cgi.mobile_agent?}
	<p><input name="comment_limit_per_day" value="#{h @conf.comment_limit_per_day}" size="3"> TSUKKOMIs</p>
	HTML
end

# comment mail
def comment_mail_mime( str )
	[str.dup]
end

def comment_mail_conf_label; 'TSUKKOMI Mail'; end

def comment_mail_basic_html
	@conf['comment_mail.header'] = '' unless @conf['comment_mail.header']
	@conf['comment_mail.receivers'] = '' unless @conf['comment_mail.receivers']
	@conf['comment_mail.sendhidden'] = false unless @conf['comment_mail.sendhidden']

	<<-HTML
	<h3 class="subtitle">Notify TSUKKOMI by E-mail</h3>
	#{"<p>Select notify or not when your diary gets a new TSUKKOMI. So TSUKKOMI mail need SMTP server settings in tdiary.conf.</p>" unless @cgi.mobile_agent?}
	<p><select name="comment_mail.enable">
		<option value="true"#{" selected" if @conf['comment_mail.enable']}>Send Mail</option>
        <option value="false"#{" selected" unless @conf['comment_mail.enable']}>Don't Send</option>
	</select></p>
	<h3 class="subtitle">Receivers</h3>
	#{"<p>Sepecify receivers of TSUKKOMI mail, 1 address per 1 line. If you dose not specify, TSUKKOMI mails will be sent to your address.</p>" unless @cgi.mobile_agent?}
	<p><textarea name="comment_mail.receivers" cols="40" rows="3">#{h( @conf['comment_mail.receivers'].gsub( /[, ]+/, "\n") )}</textarea></p>
	<h3 class="subtitle">Mail header</h3>
	#{"<p>Specify a string insert to beginning of mail subject. The subject have a style of \"your_specified_string:DATE-SERIAL NAME\". \"date\" is formatted as same as diary's date you specified. But when you specify another date style in this string, subject style is changed to \"your_specified_string-SERIAL NAME\" (ex: \"hoge:%Y-%m-%d\")</p>" unless @cgi.mobile_agent?}
	<p><input name="comment_mail.header" value="#{h @conf['comment_mail.header']}"></p>
	<h3 class="subtitle">About hidden TSUKKOMI</h3>
	#{"<p>Some TSUKKOMI are hidden by filters. You can decide which sending E-mail by hidden TSUKKOMI.</p>" unless @cgi.mobile_agent?}
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
	" unless @cgi.mobile_agent?}
	<h3 class="subtitle">Handling of Referer-disabled browsers</h3>
	<p><input type="radio" name="check_referer" value="true" #{if [1,3].include?(csrf_protection_method) then " checked" end}>Reject (default)
	<input type="radio" name="check_referer" value="false" #{if [0,2].include?(csrf_protection_method) then " checked" end}>Accept
	</p>
	#{"<p>Configures handling for requests without any Referer: value.
	By default tDiary rejects such request for safety reasons.
	If your browser is configured not to send Referer values, alter that setting to allow sending Referer, at least for
	originating sites. If it is impossible, configure the key-based CSRF protection below, and
	change this setting to \"Accept\".</p>
	" unless @cgi.mobile_agent?}
	</div>
	<div class="section">
	<h3 class="subtitle">Checking CSRF key</h3>
	<h4>Checks for CSRF protection key</h4>
	<p><input type="radio" name="check_key" value="true" #{if [2,3].include?(csrf_protection_method) then " checked" end}>Enabled
	<input type="radio" name="check_key" value="false" #{if [0,1].include?(csrf_protection_method) then " checked" end}>Disabled (default)
	</p>
	#{"<p>tDiary can add a secret key for every post form to prevent CSRF. As long as attackers do not know the secret key,
	forged requests will not be granted. To enable this feature, tDiary will generate a key automatically.
	To allow Referer-disabled browsers, you must enable this setting.</p>" unless @cgi.mobile_agent?}
	#{"<p class=\"message\">Caution:
	Your browser seems not to be sending any Referers, although Referer-based protection is enabled.
	<a href=\"#{h @conf.update}?conf=csrf_protection\">Please open this page again via this link</a>.
	If you see this message again, you must either change your browser setting (temporarily to change these settings, at least),
	or edit \"tdiary.conf\" directly.</p>" if [1,3].include?(csrf_protection_method) && ! @cgi.referer && !@cgi.valid?('referer_exists')}
	</div>
	HTML
end

add_conf_proc( 'logger', 'Log Level', 'basic' ) do
	saveconf_logger

	r = <<-HTML
	<h3 class="subtitle">Log Level</h3>
	<p>Select log level of tDiary's output. If you selected spam filter's log level is enabled then select INFO or DEBUG.</p>
	<p><select name="log_level">
	HTML
	r << conf_logger_list
end

add_conf_proc( 'recommendfilter', 'Recommend filter', 'basic' ) do
	saveconf_recommendfilter

	<<-HTML
	<h3>Recommend filter</h3>
	<p>Spam filtering for tDiary recommended to change the settings. Now, caution that all change what is settings.</p>
	<p>
		<input type="checkbox" id="recommend.filter" name="recommend.filter" value="true">
		<label for="recommend.filter">Enabled recommend filter</label>
	</p>
	HTML
end

#
# old ruby alert
#
def old_ruby_alert_message
	"The ruby #{RUBY_VERSION} will be unsupported by tDiary next release."
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
