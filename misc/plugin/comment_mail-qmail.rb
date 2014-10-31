# -*- coding: utf-8 -*-
# comment_mail_qmail.rb
#
# qmailを使ってツッコミをメールで知らせる
#   入れるだけで動作する。
#
# Options:
#   設定画面から指定できるもの(ツッコミメール系プラグイン共通):
#     @options['comment_mail.enable']
#          メールを送るかどうかを指定する。true(送る)かfalse(送らない)。
#          無指定時はfalse。
#     @options['comment_mail.header']
#          メールのSubjectに使う文字列。振り分け等に便利なように指定する。
#          実際のSubjectは「指定文字列:日付-1」のように、日付とコメント番号が
#          付く。ただし指定文字列中に、%に続く英字があった場合、それを
#          日付フォーマット指定を見なす。つまり「日付」の部分は
#          自動的に付加されなくなる(コメント番号は付加される)。
#          無指定時には空文字。
#     @options['comment_mail.receivers']
#          メールを送るアドレス文字列。カンマで区切って複数指定できる。
#          無指定時には日記筆者のアドレスになる。
#
#   tdiary.confでのみ指定できるもの:
#     @options['comment_mail.qmail']
#          qmail_injectコマンドのパスを指定する。
#          無指定時には「'/var/qmail/bin/qmail-inject'」。
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL2 or any later version.
#
def comment_mail( text, to )
	begin
		qmail = @conf['comment_mail.qmail'] || '/var/qmail/bin/qmail-inject'
		open( %Q[|'#{qmail.gsub(/'/, '')}' -f '#{@conf.author_mail.gsub( /'/, '' ).untaint}' '#{to.map{|x|x.gsub(/'/,'')}.join("' '")}'], 'w' ) do |o|
			o.write( text )
		end
	rescue
		$stderr.puts $!
	end
end

add_update_proc do
	comment_mail_send if @mode == 'comment'
end

add_conf_proc( 'comment_mail', comment_mail_conf_label, 'tsukkomi' ) do
	comment_mail_basic_setting
	comment_mail_basic_html
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
