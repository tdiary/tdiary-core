=begin
【ツッコミメールを送るメソッドの再定義】

※このファイルは同内容がすでにデフォルト機能として動作するようになっ
　ていますので、実際に適用する必要はありません。あくまでサンプルです。

TDiaryComment#sendmailメソッドを再定義することで、メール送信メソッド
を変更することが可能です。以下はSMTPを使ってメール送信をする場合のサ
ンプルです。tdiary.conf内に次のように指定することで利用できます。

   require "#{TDiary::PATH}/misc/mail-via-smtp" 
   @smtp_host = "smtp.example.net" 
   @smtp_port = 25 

このメソッドはTDiaryComment内にあるので、TDiaryComment内にあるインス
タンス変数やメソッドに自由にアクセスできてしまいます。取り扱いには十
分注意してください。
=end

module TDiary
	class TDiaryComment
		def sendmail( text )
			return unless @smtp_host
			begin
				require 'net/smtp'
				Net::SMTP.start( @smtp_host, @smtp_port ) do |smtp|
					smtp.ready( @author_mail, @mail_receivers ) do |adapter| adapter.write( text ) end
				end
			rescue
			end
		end
	end
end
