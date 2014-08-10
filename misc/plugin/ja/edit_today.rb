# -*- coding: utf-8 -*-
# Japanese resources of edit_today plugin.

@edit_today_caption = 'この日を編集'

def edit_today_edit_label( date )
	date.strftime( '%Y-%m-%dを編集' )
end

def edit_today_conf_html
	<<-HTML
	<h3 class="subtitle">リンク文字列</h3>
	<p>編集ページへのリンクを示す文字列を指定します。画像が用意できれば、アイコンなども指定出来ます。</p>
	<p><input name="edit_today_caption" size="70" value="#{h @conf['edit_today.caption']}"></p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
