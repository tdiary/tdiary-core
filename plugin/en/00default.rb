#
# en/00default.rb: English resources of 00default.rb.
#

#
# header
#
def title_tag
	r = "<title>#{CGI::escapeHTML( @html_title )}"
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
# labels
#
def no_diary; "No diary on #{@date.strftime( @conf.date_format )}"; end
def comment_today; "Today's TSUKKOMI"; end
def comment_total( total ); "(Total: #{total})"; end
def comment_new; 'Add a TSUKKOMI'; end
def comment_description; 'Add a TSUKKOMI or Comment please. E-mail address will be shown to only me.'; end
def comment_description_short; 'TSUKKOMI!!'; end
def comment_name_label; 'Name'; end
def comment_name_label_short; 'Name'; end
def comment_mail_label; 'E-mail'; end
def comment_mail_label_short; 'Mail'; end
def comment_body_label; 'Comment'; end
def comment_body_label_short; 'Comment'; end
def comment_submit_label; 'Submit'; end
def comment_submit_label_short; 'Submit'; end
def comment_date( time ); time.strftime( "(#{@date_format} %H:%M)" ); end
def referer_today; "Today's Link"; end
def trackback_today; "Today's TrackBacks"; end
def trackback_total( total ); "(Total: #{total})"; end

def navi_index; 'Top'; end
def navi_latest; 'Latest'; end
def navi_oldest; 'Oldest'; end
def navi_update; "Append"; end
def navi_edit; "Edit"; end
def navi_preference; "Preference"; end
def navi_prev_diary(date); "Prev(#{date.strftime(@date_format)})"; end
def navi_next_diary(date); "Next(#{date.strftime(@date_format)})"; end
def navi_prev_nyear(date); "Prev(#{date.strftime('%m-%d')})"; end
def navi_next_nyear(date); "Next(#{date.strftime('%m-%d')})"; end

def submit_label
	if @mode == 'form' or @cgi.valid?( 'appendpreview' ) then
		'Append'
	else
		'Replace'
	end
end
def preview_label; 'Preview'; end

def label_no_referer; "Today's Link Excluding List"; end
def label_referer_table; "Today's Link Conversion Rule"; end

def nyear_diary_label(date, years); "my old days"; end
def nyear_diary_title(date, years); "same days in past"; end


#
# labels (for mobile)
#
def mobile_navi_latest; 'Latest'; end
def mobile_navi_update; 'Update'; end
def mobile_navi_preference; 'Prefs'; end
def mobile_navi_prev_diary; 'Prev'; end
def mobile_navi_next_diary; 'Next'; end
def mobile_label_hidden_diary; 'This day is HIDDEN.'; end

#
# category
#
def category_title; "Categorized"; end
def category_title_year(year); "#{year}"; end
def category_title_month(year, month); "#{year}-#{month}"; end
def category_title_quarter(year, q); "#{year}-#{q}Q"; end
def category_title_latest; "Currnet Month"; end

#
# preferences
#

# basic (default)
add_conf_proc( 'default', 'Basic' ) do
	saveconf_default
	<<-HTML
	<h3 class="subtitle">Author</h3>
	#{"<p>Specify your name. This value is into HTML header.</p>" unless @conf.mobile_agent?}
	<p><input name="author_name" value="#{CGI::escapeHTML @conf.author_name}" size="40"></p>
	<h3 class="subtitle">E-mail address</h3>
	#{"<p>Specify your E-mail address. This value is into HTML header.</p>" unless @conf.mobile_agent?}
	<p><input name="author_mail" value="#{@conf.author_mail}" size="40"></p>
	<h3 class="subtitle">URL of index page</h3>
	#{"<p>The URL of index of your website if you have.</p>" unless @conf.mobile_agent?}
	<p><input name="index_page" value="#{@conf.index_page}" size="50"></p>
	<h3 class="subtitle">Time difference adjustment</h3>
	#{"<p>When updating diary, you can adjust date which is automatically inserted into the form. The unit is hour. For example, if you want to handle the time until 2 a.m. as the previous day, you set this to -2. tDiary inserts the date which is older by 2 hours than the actual time. </p>" unless @conf.mobile_agent?}
	<p><input name="hour_offset" value="#{@conf.hour_offset}" size="5"></p>
	HTML
end

# header/footer (header)
add_conf_proc( 'header', 'Header/Footer' ) do
	saveconf_header

	<<-HTML
	<h3 class="subtitle">Title</h3>
	#{"<p>The title of your diary. This value is used in HTML &lt;title&gt; element and in mobile mode. Do not use HTML tags.</p>" unless @conf.mobile_agent?}
	<p><input name="html_title" value="#{ CGI::escapeHTML @conf.html_title }" size="50"></p>
	<h3 class="subtitle">Header</h3>
	#{"<p>This text is inserted into top of each pages. You can use HTML tags. Do not remove \"&lt;%=navi%&gt;\", because it mean Navigation bar inclued \"Update\" button. And \"&lt;%=calendar%&gt;\" mean calendar. So you can specify other plugins also.</p>" unless @conf.mobile_agent?}
	<p><textarea name="header" cols="70" rows="10">#{ CGI::escapeHTML @conf.header }</textarea></p>
	<h3 class="subtitle">Footer</h3>
	#{"<p>This text is inserted into bottom of each pages. You can specify as same as Header.</p>" unless @conf.mobile_agent?}
	<p><textarea name="footer" cols="70" rows="10">#{ CGI::escapeHTML @conf.footer }</textarea></p>
	HTML
end

# diaplay
add_conf_proc( 'display', 'Display' ) do
	saveconf_display

	<<-HTML
	<h3 class="subtitle">Section anchor</h3>
	#{"<p>\"Anchor\" guide to link from other website. Section anchors are insertd into begining of each section. So if you specify \"&lt;span class=\"sanchor\"&gt;_&lt;/span&gt;\", image anchor will be shown Image anchor by themes.</p>" unless @conf.mobile_agent?}
	<p><input name="section_anchor" value="#{ CGI::escapeHTML @conf.section_anchor }" size="40"></p>
	<h3 class="subtitle">TSUKKOMI anchor</h3>
	#{"<p>TSUKKOMI anchor is inserted into begining of each TSUKKOMIs. So You can specify \"&lt;span class=\"canchor\"&gt;_&lt;/span&gt;\" for Image anchor.</p>" unless @conf.mobile_agent?}
	<p><input name="comment_anchor" value="#{ CGI::escapeHTML @conf.comment_anchor }" size="40"></p>
	<h3 class="subtitle">Date format</h3>
	#{"<p>Format of date. If you specify a charactor after %, it mean special about date formatting: \"%Y\"(Year), \"%m\"(Month)¡¢\"%b\"(Short name of month), \"%B\"(Long name of month), \"%d\"(Day), \"%a\"(Short name of day of week), \"%A\"(Long name of day of week).</p>" unless @conf.mobile_agent?}
	<p><input name="date_format" value="#{ CGI::escapeHTML @conf.date_format }" size="30"></p>
	<h3 class="subtitle">Max dates of Latest diaplay</h3>
	#{"<p>In the Latest mode, you can specify the number of days in the page.</p>" unless @conf.mobile_agent?}
	<p><input name="latest_limit" value="#{@conf.latest_limit}" size="2"> days in a page.</p>
	<h3 class="subtitle">My old days</h4>
	#{"<p>Show the link of \"My old days\"</p>" unless @conf.mobile_agent?}
	<p><select name="show_nyear">
		<option value="true"#{if @conf.show_nyear then " selected" end}>Show</option>
        <option value="false"#{if not @conf.show_nyear then " selected" end}>Hide</option>
	</select></p>
	HTML
end

# themes
add_conf_proc( 'theme', 'Themes' ) do
	saveconf_theme

	 r = <<-HTML
	<h3 class="subtitle">Theme</h3>
	#{"<p>Specify the design of your diary using Theme or CSS. When you select \"CSS specify\", input URL of CSS into the field right side.</p>" unless @conf.mobile_agent?}
	<p>
	<select name="theme">
		<option value="">CSS Specify-&gt;</option>
	HTML
	@conf_theme_list.each do |theme|
		r << %Q|<option value="#{theme[0]}"#{if theme[0] == @conf.theme then " selected" end}>#{theme[1]}</option>|
	end
	r << <<-HTML
	</select>
	<input name="css" size="50" value="#{ @conf.css }">
	</p>
	#{"<p>You can get many themes from <a href=\"http://www.tdiary.org/20021001.html\">Theme Gallery</a>(Japanese).</p>" unless @conf.mobile_agent?}
	HTML
end

# comments
add_conf_proc( 'comment', 'TSUKKOMI' ) do
	saveconf_comment

	<<-HTML
	<h3 class="subtitle">Show TSUKKOMI</h3>
	#{"<p>Select show or hide TSUKKOMI from readers</p>" unless @conf.mobile_agent?}
	<p><select name="show_comment">
		<option value="true"#{if @conf.show_comment then " selected" end}>Show</option>
		<option value="false"#{if not @conf.show_comment then " selected" end}>Hide</option>
	</select></p>
	<h3 class="subtitle">Number of TSUKKOMI</h3>
	#{"<p>In Latest or Month mode, you can specify number of visible TSUKKOMIs. So in Dayly mode, all of TSUKKOMIs are shown.</p>" unless @conf.mobile_agent?}
	<p><input name="comment_limit" value="#{ @conf.comment_limit }" size="3"> TSUKKOMIs</p>
	HTML
end

# referer
add_conf_proc( 'referer', "Today's Link" ) do
	saveconf_referer

	<<-HTML
	<h3 class="subtitle">Show links</h3>
	#{"<p>Select show or hide about Today's Link</p>" unless @conf.mobile_agent?}
	<p><select name="show_referer">
		<option value="true"#{if @conf.show_referer then " selected" end}>Show</option>
		<option value="false"#{if not @conf.show_referer then " selected" end}>Hide</option>
	</select></p>
	<h3 class="subtitle">Number of Links</h3>
	#{"<p>In Latest or Month mode, you can specify number of visible Link list. So in Dayly mode, all of Link are shown.</p>" unless @conf.mobile_agent?}
	<p><input name="referer_limit" value="#{@conf.referer_limit}" size="3"> sites</p>
	<h3 class="subtitle">Control Links saving</h3>
	#{"<p>Specify which saving only day mode. It means reducing 'referer noise' by access from 'Link page'.</p>" unless @conf.mobile_agent?}
	<p><select name="referer_day_only">
		<option value="true"#{if @conf.referer_day_only then " selected" end}>Save links only in day mode</option>
		<option value="false"#{if not @conf.referer_day_only then " selected" end}>Save links in all access</option>
	</select></p>
	<h3 class="subtitle">Excluding list</h3>
	#{"<p>List of excluding URL that is not recorded to Today's Link. Specify it in regular expression, and a URL into a line.</p>" unless @conf.mobile_agent?}
	<p>See <a href="#{@conf.update}?referer=no" target="referer">Default configuration is here</a>.</p>
	<p><textarea name="no_referer" cols="70" rows="10">#{@conf.no_referer2.join( "\n" )}</textarea></p>
	<h3 class="subtitle">Rule of conversion URL to words.</h3>
	#{"<p>A table to convert URL to words in Today's Link. Specify it in regular expression, and a URL into a line.<p>" unless @conf.mobile_agent?}
	<p>See <a href="#{@conf.update}?referer=table" target="referer">Default configurations</a>.</p>
	<p><textarea name="referer_table" cols="70" rows="10">#{@conf.referer_table2.collect{|a|a.join( " " )}.join( "\n" )}</textarea></p>
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

	<<-HTML
	<h3 class="subtitle">Notify TSUKKOMI by E-mail</h3>
	#{"<p>Select notify or not when your diary gets a new TSUKKOMI. So TSUKKOMI mail need SMTP server settings in tdiary.conf.</p>" unless @conf.mobile_agent?}
	<p><select name="comment_mail.enable">
		<option value="true"#{if @conf['comment_mail.enable'] then " selected" end}>Send Mail</option>
        <option value="false"#{if not @conf['comment_mail.enable'] then " selected" end}>Don't Send</option>
	</select></p>
	<h3 class="subtitle">Receivers</h3>
	#{"<p>Sepecify receivers of TSUKKOMI mail, 1 address per 1 line. If you dose not specify, TSUKKOMI mails will be sent to your address.</p>" unless @conf.mobile_agent?}
	<p><textarea name="comment_mail.receivers" cols="40" rows="3">#{CGI::escapeHTML( @conf['comment_mail.receivers'].gsub( /[, ]+/, "\n") )}</textarea></p>
	<h3 class="subtitle">Mail header</h3>
	#{"<p>Specify a string insert to beginning of mail subject. The subject have a style of \"your_specified_string:DATE-SERIAL NAME\". \"date\" is formatted as same as diary's date you specified. But when you specify another date style in this string, subject style is changed to \"your_specified_string-SERIAL NAME\" (ex: \"hoge:%Y-%m-%d\")</p>" unless @conf.mobile_agent?}
	<p><input name="comment_mail.header" value="#{CGI::escapeHTML( @conf['comment_mail.header'])}"></p>
	HTML
end

#
# link to HOWTO write diary
#
def style_howto
	%Q|/<a href="http://docs.tdiary.org/en/?#{@conf.style}Style">How to write</a>|
end
