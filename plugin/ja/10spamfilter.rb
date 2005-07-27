#
# ja/spamfilter.rb: resource of ja $Revision: 1.1 $
#

@spamfilter_label_conf = 'spamフィルタ'

def spamfilter_conf_html
	r = <<-HTML
	<h3>基本</h3>
	<p>ツッコミ中に以下の値より多くのURIが含まれるものはspamとみなす。<br>
		<input type="text" name="spamfilter.max_uris" value="#{CGI.escapeHTML(@conf['spamfilter.max_uris'].to_s)}" size="5"></p>
	<p>ツッコミの中でURIを表す文字数(バイト数)の占める割合が以下の値よりもよりも高いものはspamとみなす。<br>
		<input type="text" name="spamfilter.max_rate" value="#{CGI.escapeHTML(@conf['spamfilter.max_rate'].to_s)}" size="5"></p>
	<p>以下に列挙されたパターンを使って構成されるパターンにマッチするURIを含むツッコミはspamとみなす。実際に使用されるパターンについてはupdate_configメソッドを参照。<br>
		<textarea name="spamfilter.bad_uri_patts" cols="70" rows="8">#{CGI.escapeHTML(@conf['spamfilter.bad_uri_patts'] || '')}</textarea></p>
	<p>ツッコミ本文が以下に列挙されたパターンにマッチする場合はspamとみなす。<br>
		<textarea name="spamfilter.bad_comment_patts" cols="70" rows="8">#{CGI.escapeHTML(@conf['spamfilter.bad_comment_patts'] || '')}</textarea></p>
	<p>ツッコミのメールアドレスが以下に列挙されたパターンにマッチする場合はspamとみなす。<br>
		<textarea name="spamfilter.bad_mail_patts" cols="70" rows="8">#{CGI.escapeHTML(@conf['spamfilter.bad_mail_patts'] || '')}</textarea></p>
	<p>ツッコミのメールアドレスのチェックにURI用のパターンを使用する。<br>
		<select name="spamfilter.bad_uri_patts_for_mails">
			<option value="true"#{" selected" if @conf['spamfilter.bad_uri_patts_for_mails']}>オン</option>
			<option value="false"#{" selected" unless @conf['spamfilter.bad_uri_patts_for_mails']}>オフ</option>
		</select></p>

	<h3>IPアドレス</h3>
	<p>ツッコミやTrackBackの送信元のIPアドレスが以下のリストにマッチする場合はspamとみなす(リストには完全なIPアドレスまたは「.」で終わるIPアドレスの一部を記述する)。<br>
		<textarea name="spamfilter.bad_ip_addrs" cols="70" rows="8">#{CGI.escapeHTML(@conf['spamfilter.bad_ip_addrs'] || '')}</textarea></p>
	</p>
	<p>TrackBack送信元のIPアドレスと実際のサイトのIPアドレスがマッチしない場合はspamとみなす。<br>
		<select name="spamfilter.resolv_check">
			<option value="true"#{" selected" if @conf['spamfilter.resolv_check']}>オン</option>
			<option value="false"#{" selected" unless @conf['spamfilter.resolv_check']}>オフ</option>
	</select></p>
	HTML

	unless @conf.secure then
	r << <<-HTML
	<h3>デバッグ</h3>
	<p>デバッグモード。<br>
		<select name="spamfilter.debug_mode">
			<option value="true"#{" selected" if @conf['spamfilter.debug_mode']}>オン</option>
			<option value="false"#{" selected" unless @conf['spamfilter.debug_mode']}>オフ</option>
		</select></p>
	<p>デバッグログを記録するファイルのファイル名。<br>
		<input type="text" name="spamfilter.debug_file" value="#{CGI.escapeHTML(@conf['spamfilter.debug_file'] || '')}" size="30"></p>
	HTML
	end

	r
end
