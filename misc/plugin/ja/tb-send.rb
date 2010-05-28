# -*- coding: utf-8 -*-
# Japanese resource of tb-send.rb

@tb_send_label_url = 'TrackBack送信先URL'
@tb_send_label_section = 'TrackBackするセクション'
@tb_send_label_no_section = '(セクションを指定しない)'
@tb_send_label_current_section = '(最後に追記したセクション)'
if @conf['tb.no_section'] then
	@tb_send_label_excerpt = '概略(記入しなければ本文の冒頭が使われます)'
else
	@tb_send_label_excerpt = '概略(記入しなければ選択したセクションの冒頭が使われます)'
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
