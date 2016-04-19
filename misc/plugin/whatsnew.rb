# whatsnew.rb
#
# 名称：
# What's Newプラグイン
#
# 概要：
# 未読のセクションに指定したマークをつけることができます．
#
# 使い方：
# tdiary.conf の @section_anchor の先頭に以下のように <%= whats_new %> を追加します．
#
#   @section_anchor = '<%= whats_new %><span class="sanchor">_</span>'
#
# セクションの未読/既読によって <%= whats_new %> の部分があらかじめ指
# 定したマークで置き換えられます．デフォルトでは未読セクションでは
# "!!!NEW!!!"，既読セクションでは "" に展開されます．
#
# 注：Revision が 1.1 の whats_new.rb の説明では，<span> の中に
#     <%= whats_new %> を含めるように書いていましたが，sanchorで画像を
#     表示するようなテーマでは，whats_new の出力と sanchor の画像が重
#     なってしまうという問題がありました．
#     この変更に伴い，既読時のデフォルトは '' に変更しました．
#
# 置き換えられる文字列を変更したい場合は tdiary.conf 中で
#
#   @options['whats_new.new_mark'] = '<img src="/Images/new.png" alt="NEW!" border="0">'
#   @options['whats_new.read_mark'] = '既'
#
# のように指定します．
#
# Copyright (c) 2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL2 or any later version.
#

@whats_new = {}.taint

def whats_new
	return apply_plugin( @whats_new[:read_mark] ) unless @cgi
	@whats_new[:section] += 1
	t = @whats_new[:current_date] + "%03d" % @whats_new[:section]
	if t > @whats_new[:this_time]
		@whats_new[:this_time] = t
	end
	# 初回もしくは cookie を使わない設定の場合は機能しない
	return apply_plugin( @whats_new[:read_mark] ) if @whats_new[:last_time] == "00000000000"
	if t > @whats_new[:last_time]
		apply_plugin( @whats_new[:new_mark] )
	else
		apply_plugin( @whats_new[:read_mark] )
	end
end

add_body_enter_proc do |date|
	if @cgi
		@whats_new[:current_date] = Time::at(date).strftime('%Y%m%d')
		@whats_new[:section] = 0
		@whats_new[:last_time]
	end
	""
end

add_header_proc do
	if @cgi
		if @cgi.cookies['tdiary_whats_new'][0]
			@whats_new[:this_time] = @whats_new[:last_time] = @cgi.cookies['tdiary_whats_new'][0]
		else
			# 初めて，もしくは cookie は使わない設定
			@whats_new[:this_time] = @whats_new[:last_time] = "00000000000"
		end
		@whats_new[:new_mark] = @options['whats_new.new_mark'] || '!!!new!!!'
		@whats_new[:read_mark] = @options['whats_new.read_mark'] || ''
	end
	""
end

add_footer_proc do
	if @cgi.script_name
		if @whats_new[:this_time] > @whats_new[:last_time]
			cookie_path = File::dirname(@cgi.script_name)
			cookie_path += '/' if cookie_path !~ /\/$/
			cookie = CGI::Cookie::new({
				'name' => 'tdiary_whats_new',
				'value' => [@whats_new[:this_time]],
				'path' => cookie_path,
				'expires' => Time::now.gmtime + 90*24*60*60
			})
			add_cookie(cookie)
		end
	end
	""
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
