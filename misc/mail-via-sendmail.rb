=begin
【ツッコミメールを送るメソッドの再定義 - sendmail版】

※注意※
このメソッドは、Webサーバの権限で実行すると失敗するかも知れません。

TDiaryComment#sendmailメソッドを再定義することで、メール送信メソッド
を変更することが可能です。以下はsendmailを使ってメール送信をする場合
のサンプルです。tdiary.conf内に次のように指定することで利用できます。

   require "#{TDiary::PATH}/misc/mail-via-sendmail" 
   @sendmail = "/usr/sbin/sendmail" 

このメソッドはTDiaryComment内にあるので、TDiaryComment内にあるインス
タンス変数やメソッドに自由にアクセスできてしまいます。取り扱いには十
分注意してください。
=end

class TDiaryComment
	def sendmail( text )
		return unless @sendmail
		begin
			open( "|#{@sendmail} #{@mail_receivers.join(' ')}", 'w' ) do |o|
				o.write( text )
			end
		rescue
		end
	end
end
