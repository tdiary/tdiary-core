#
# 00lang.en.rb: Language support plugin for English
#

#
# navi
#
def navi_user
	result = ''
	result << %Q[<span class="adminmenu"><a href="#{@index_page}">Index</a></span>\n] unless @index_page.empty?
	result << %Q[<span class="adminmenu"><a href="#{@index}#{anchor( (@date-24*60*60).strftime( '%Y%m%d' ) )}">&lt;Prev</a></span>\n] if /^(day|comment)$/ =~ @mode
	result << %Q[<span class="adminmenu"><a href="#{@index}#{anchor( (@date+24*60*60).strftime( '%Y%m%d' ) )}">Next&gt;</a></span>\n] if /^(day|comment)$/ =~ @mode
	result << %Q[<span class="adminmenu"><a href="#{@index}">Latest</a></span>\n] unless @mode == 'latest'
	result
end

def navi_admin
	result = %Q[<span class="adminmenu"><a href="#{@update}">Update</a></span>\n]
	result << %Q[<span class="adminmenu"><a href="#{@update}?conf=OK">Preference</a></span>\n] if /^(latest|month|day|comment|conf)$/ !~ @mode
	result
end

#
# header
#
def title_tag
	r = "<title>#{@html_title}"
	case @mode
	when 'day', 'comment'
		r << "(#{@date.strftime( '%Y-%m-%d' )})" if @date
	when 'month'
		r << "(#{@date.strftime( '%Y-%m' )})" if @date
	when 'form'
		r << '(Updating)'
	when 'append', 'replace'
		r << '(Updating Completed)'
	when 'showcomment'
		r << '(Changing Completed)'
	when 'conf'
		r << '(Preferences)'
	when 'saveconf'
		r << '(Preferences Changed)'
	end
	r << '</title>'
end


#
# labels
#
def comment_today; "Today's TSUKKOMI"; end
def comment_total( total ); "(Total: #{total})"; end
def comment_new; 'Make a TSUKKOMI'; end
def comment_description; 'Make a TSUKKOMI or Comment please. E-mail address will be shown to only me.'; end
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

def submit_label
	if @mode == 'form' then
		'Append'
	else
		'Replace'
	end
end
