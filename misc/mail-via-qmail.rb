=begin
【ツッコミメールを送るメソッドの再定義 - qmail版】

※注意※
このメソッドは、Webサーバの権限で実行すると失敗するかも知れません。

TDiaryComment#sendmailメソッドを再定義することで、メール送信メソッド
を変更することが可能です。以下はqmail-injectを使ってメール送信をする
場合のサンプルです。tdiary.conf内に次のように指定することで利用でき
ます。

   require "#{TDiary::PATH}/misc/mail-via-qmail" 
   @qmail_inject = "/var/qmail/bin/qmail-inject" 

このメソッドはTDiaryComment内にあるので、TDiaryComment内にあるインス
タンス変数やメソッドに自由にアクセスできてしまいます。取り扱いには十
分注意してください。
=end

class TDiaryComment
	def sendmail( text )
		return unless @qmail_inject
		begin
			open( "|#{@qmail_inject} #{@mail_receivers.join(' ')}", 'w' ) do |o|
				o.write( text )
			end
		rescue
		end
	end
end
