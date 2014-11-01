# -*- coding: utf-8 -*-
# speed_comment.rb
#
# spped_comment: 最新・月毎表示時に簡易なツッコミフォームを表示する
#                pluginディレクトリに入れるだけで動きます。
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL2 or any later version.
#
=begin ChangeLog
2003-09-24 TADA Tadashi <sho@spc.gr.jp>
	* support cookie for name.
	* support conf_proc.

2002-03-24 TADA Tadashi <sho@spc.gr.jp>
	* suppress output in mobile mode.

2002-03-12 TADA Tadashi <sho@spc.gr.jp>
	* support insert into @header.
=end

add_body_leave_proc do |date|
	if /latest|month/ =~ @mode and not @cgi.mobile_agent? then
		@conf['speed_comment.name_size'] = 20 unless @conf['speed_comment.name_size']
		@conf['speed_comment.body_size'] = 40 unless @conf['speed_comment.body_size']
		r = ""
		r << %Q[<div class="form"><form method="post" action="#{h( @index )}"><p>]
		r << %Q[<input type="hidden" name="date" value="#{h( date.strftime( '%Y%m%d' ) )}">]
		r << %Q[<input type="hidden" name="mail" value="">]
		r << %Q[#{h( comment_name_label )} : <input class="field" name="name" size="#{@conf['speed_comment.name_size']}" value="#{h( @conf.to_native(@cgi.cookies['tdiary'][0] || '' ))}">]
		r << %Q[#{h( comment_body_label )} : <input class="field" name="body" size="#{@conf['speed_comment.body_size']}">]
		r << %Q[<input type="submit" name="comment" value="#{h( comment_submit_label )}">]
		r << %Q[</p></form></div>]
	else
		''
	end
end

unless @resource_loaded then
	def speed_comment_label
		'簡易ツッコミ'
	end

	def speed_comment_html
		<<-HTML
		<h3>簡易ツッコミフォームのサイズ</h3>
		<p>名前欄: <input name="speed_comment.name_size" size="5" value="#{h( @conf['speed_comment.name_size'] ) || 20}"></p>
		<p>本文欄: <input name="speed_comment.body_size" size="5" value="#{h( @conf['speed_comment.body_size'] ) || 40}"></p>
		HTML
	end
end

add_conf_proc( 'speed_comment', speed_comment_label ) do
	if @mode == 'saveconf' then
		@conf['speed_comment.name_size'] = @cgi.params['speed_comment.name_size'][0].to_i
		@conf['speed_comment.name_size'] = 20 if @conf['speed_comment.name_size'] < 1
		@conf['speed_comment.body_size'] = @cgi.params['speed_comment.body_size'][0].to_i
		@conf['speed_comment.body_size'] = 40 if @conf['speed_comment.body_size'] < 1
	end
	speed_comment_html
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
