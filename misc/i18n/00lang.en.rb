#
# 00lang.en.rb: Language support plugin for English
#

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

def navi_index; 'Top'; end
def navi_latest; 'Latest'; end
def navi_prev_day(date); "Prev(#{date})"; end
def navi_next_day(date); "Next(#{date})"; end
def navi_prev_day2(date); "Prev Month(#{date})"; end
def navi_next_day2(date); "Next Month(#{date})"; end
def navi_update; "Update"; end
def navi_preference; "Preference"; end

def submit_label
	if @mode == 'form' then
		'Append'
	else
		'Replace'
	end
end
