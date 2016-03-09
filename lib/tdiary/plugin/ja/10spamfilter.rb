# -*- coding: utf-8; -*-
#
# ja/10spamfilter.rb: resource of ja
#

@spamfilter_label_conf = 'spamフィルタ'
@dnsblfilter_label_conf = 'DNSBLフィルタ'

def spamfilter_conf_html
	r = <<-HTML
	<h3>spamの扱い</h3>
	<p>spamと判定されたツッコミを
		<select name="spamfilter.filter_mode">
			<option value="true"#{" selected" if @conf['spamfilter.filter_mode']}>非表示にする</option>
			<option value="false"#{" selected" unless @conf['spamfilter.filter_mode']}>捨てる</option>
	</select></p>

	<h3>内容によるフィルタ</h3>
	<p>ツッコミ中のURLの数が<input type="text" name="spamfilter.max_uris" value="#{h @conf['spamfilter.max_uris']}" size="5">個を超えたらspamとみなす</p>
	<p>ツッコミ中でURLを表す文字の占める割合が<input type="text" name="spamfilter.max_rate" value="#{h @conf['spamfilter.max_rate']}" size="5">%より高いものはspamとみなす</p>
	<p>ツッコミ本文が以下のパターンに当てはまる場合はspamとみなす。正規表現が利用できます<br>
		<textarea name="spamfilter.bad_comment_patts" cols="70" rows="5">#{h( @conf['spamfilter.bad_comment_patts'] || '' )}</textarea></p>
	<p>ツッコミのメールアドレスが以下のパターンに当てはまる場合はspamとみなす。正規表現が使えます<br>
		<textarea name="spamfilter.bad_mail_patts" cols="70" rows="5">#{h( @conf['spamfilter.bad_mail_patts'] || '' )}</textarea></p>
	<p>ツッコミやリンク元に含まれるURLに、以下のパターンが含まれる場合はspamとみなす<br>
		<textarea name="spamfilter.bad_uri_patts" cols="70" rows="5">#{h( @conf['spamfilter.bad_uri_patts'] || '' )}</textarea></p>
	<p>上のパターンをツッコミのメールアドレスのチェックにも
		<select name="spamfilter.bad_uri_patts_for_mails">
			<option value="true"#{" selected" if @conf['spamfilter.bad_uri_patts_for_mails']}>利用する</option>
			<option value="false"#{" selected" unless @conf['spamfilter.bad_uri_patts_for_mails']}>利用しない</option>
		</select></p>

	<h3>日付けによるフィルタ</h3>
	<p><input type="text" name="spamfilter.date_limit" value="#{h @conf['spamfilter.date_limit']}" size="5">日以上前の日付けのツッコミフォームはjavascriptで表示する。<br>(空欄は制限なし、0は当日のみ)</p>

	<h3>IPアドレスによるフィルタ</h3>
	<p>ツッコミのIPアドレスが、以下のパターンに当てはまる場合はspamとみなす(リストには完全なIPアドレスまたは「.」で終わるIPアドレスの一部を記述する)<br>
		<textarea name="spamfilter.bad_ip_addrs" cols="70" rows="5">#{h( @conf['spamfilter.bad_ip_addrs'] || '' )}</textarea></p>
	</p>
	<h3>ツッコミの注意文</h3>
	<p>ツッコミフォームの上に表示する注意文を設定します。spam判定条件を変更した場合に、読者にそれをきちんと知らせましょう<br>
	<textarea name="comment_description" cols="70" rows="5">#{h comment_description}</textarea></p>
	HTML

	r << <<-HTML
	<h3>フィルタのログ</h3>
	<p>フィルタのログを
		<select name="filter.debug_mode">
			<option value="0"#{" selected" if @conf['filter.debug_mode'] == 0}>記録しない</option>
			<option value="1"#{" selected" if @conf['filter.debug_mode'] == 1}>spamだけ記録する</option>
			<option value="2"#{" selected" if @conf['filter.debug_mode'] == 2}>すべて記録する</option>
		</select></p>
	HTML

	r
end

def dnsblfilter_conf_html
	r = <<-HTML
	<h3>DNSBL(DNSブラックリスト)サービスを使ったフィルタ</h3>
	<p>IPベースのブラックリスト問い合わせサーバーを指定します<br>
	<textarea name="spamlookup.ip.list" cols="70" rows="5">#{h @conf['spamlookup.ip.list']}</textarea></p>
	<p>ドメインベースのブラックリスト問い合わせサーバーを指定します<br>
	<textarea name="spamlookup.domain.list" cols="70" rows="5">#{h @conf['spamlookup.domain.list']}</textarea></p>
	<p>以下に指定したドメインはブラックリストに問い合わせません。検索エンジン等を指定してください<br>
	<textarea name="spamlookup.safe_domain.list" cols="70" rows="10">#{h @conf['spamlookup.safe_domain.list']}</textarea></p>
	HTML

	r
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
