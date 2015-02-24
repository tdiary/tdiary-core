# -*- coding: utf-8 -*-
# comment_mail-smtp.rb
#
# SMTPプロトコルを使ってツッコミをメールで知らせる
#   同一ホスト内にSMTPサーバがある場合は有効にするだけで動作する
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
#     @options['comment_mail.smtp_host']
#     @options['comment_mail.smtp_port']
#          それぞれ、メール送信に使うSMTPサーバのホスト名とポート番号。
#          無指定時はそれぞれ「'localhost'」と「25」。
#   以下は通常は不要。必要に応じて指定する:
#     @options['comment_mail.user_name']
#     @options['comment_mail.password']
#          SMTP認証が必要な場合のユーザ名とパスワード
#     @options['comment_mail.authentication']
#          SMTP認証の方式。:plainや:loginなど(Mail gemに指定できるもの)
#     @options['comment_mail.starttls']
#          TLSに自動接続する(true/false) (Mail gem)
#
# Copyright (c) 2015 TADA Tadashi <t@tdtds.jp>
# You can distribute this file under the GPL2 or any later version.
#
def comment_mail( text, to )
	begin
		require 'mail'

		mail = Mail.new( text )
		delivery_opts = {
			address: @conf['comment_mail.smtp_host'] || 'localhost',
			port: @conf['comment_mail.smtp_port'] || 25,
			authentication: @conf['comment_mail.authentication'],
			user_name: @conf['comment_mail.user_name'],
			password: @conf['comment_mail.password'],
			enable_starttls_auto: @conf['comment_mail.starttls']
		}.delete_if{|k,v| v == nil}
		mail.delivery_method( :smtp, delivery_opts )
		mail.deliver
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
