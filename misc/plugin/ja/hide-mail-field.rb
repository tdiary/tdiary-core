# Japanese resource of hide-mail-field plugin

@hide_mail_field_label_conf = 'メール欄隠し'

def hide_mail_field_conf_html
	<<-HTML
   <h3>ツッコミの注意文</h3>
   <p>ツッコミフォームの上に表示する注意文を設定します。メール欄が消えていることを読者にきちんと知らせましょう。この欄は標準spamフィルタの設定ページにあるものと同じものです。<br>
   <textarea name="comment_description" cols="70" rows="5">#{h comment_description}</textarea><br>
	例: ツッコミ・コメントがあればどうぞ! spam対策でE-mail欄は隠してあります。もしE-mail欄が見えていても、何も入力しないで下さい。</p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
