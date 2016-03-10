# -*- coding: utf-8 -*-
# random_google.rb
#
# random_google: 日記からランダムに抽出した単語をgoogleで検索するリンクを生成する
#
# 使い方:
#   tDiary1.5.5以降で導入されたconf_procに対応しているので，tDiaryの設定画面からどうぞ．
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL2 or any later version.
#

def random_google_pickup_word(date)
	analyzer = @conf['random_google.analyzer']
	analyzer = @conf['random_google.analyzer_path'] if analyzer == "user_defined"
	analyzer = "internal" if analyzer == ""
	if analyzer == "internal"
		m = self.methods
		url_regexp = %r<(((http[s]{0,1}|ftp)://[\(\)%#!/0-9a-zA-Z_$@.&+-,'"*=;?:~-]+)|([0-9a-zA-Z_.-]+@[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+\.[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+))>
		@diaries[date.strftime('%Y%m%d')].to_src.
			gsub(url_regexp, '').
			scan(/(?:[亜-瑤]{2,}|[ァ-ヶー]{2,}|[0-9A-Za-z]{2,})/).sort.uniq.reject {|i| m.include?(i)}
	else
		require 'open3'
		inn, out, err = Open3.popen3("#{analyzer} | sort | uniq")
		inn.puts @diaries[date.strftime('%Y%m%d')].to_src
		inn.close
		m = self.methods
		r = out.read.map do |l|
			word = l.split[0]
			if /\s(名詞|未知語)/.match(l) and
				!/(\W|\d)/.match(word) and            # 記号とか数字は要らない
				!/\A[あ-ん]{1,2}\z/.match(word) and   # 2文字以下のひらがなも要らんでしょ
				!m.include?(word)          # Pluginのメソッドは除外した方がいいかも
				word
			else
				nil
			end
		end.compact
		out.close
		err.close
		r
	end
end

def random_google_init
	@conf['random_google.n'] ||= 2
	@conf['random_google.caption'] ||= 'もしかしたら関連するかもしれないページ'
	@conf['random_google.popup'] ||= '本日のお題: $1'
	@conf['random_google.append'] ||= ''
	@conf['random_google.exception'] ||= ''
	@conf['random_google.analyzer'] ||= "internal"
	@conf['random_google.analyzer_path'] ||= ""
end

if /(latest|day)/ === @mode and !bot?
	add_body_enter_proc do |date|
		random_google_init

		exception = @conf['random_google.exception'].split
		words = random_google_pickup_word(date) - exception
		if words.empty?
			''
		else
			r = []
			@conf['random_google.n'].times do |i|
				r << words.delete_at(rand(words.size))
			end
			append = @conf['random_google.append'].split
			rr = (r.compact + append).map {|i| u(i)}.join('+')	# URL-escaped
			rrr = r.compact.map.to_a.join(' ')
			caption = @conf['random_google.caption'].gsub(/\$1/, h(rrr)) # only the words picked up are escaped
			popup = h(@conf['random_google.popup'].gsub(/\$1/, rrr)) # escaped
			<<-HTML
			<div class="body-enter">
			[<a href="http://www.google.com/search?lr=lang_ja&amp;ie=utf-8&amp;q=#{rr}" title="#{popup}">
			#{caption}
			</a>]
			</div>
			HTML
		end
	end
end

def saveconf_random_google
	if @mode == 'saveconf' then
		@conf['random_google.n'] = @cgi.params['random_google_n'][0].to_i
		@conf['random_google.caption'] = @cgi.params['random_google_caption'][0]
		@conf['random_google.popup'] = @cgi.params['random_google_popup'][0]
		@conf['random_google.append'] = @cgi.params['random_google_append'][0]
		@conf['random_google.exception'] = @cgi.params['random_google_exception'][0]
		@conf['random_google.analyzer'] = @cgi.params['random_google_analyzer'][0]
		@conf['random_google.analyzer_path'] = @cgi.params['random_google_analyzer_path'][0]
	end
end

add_conf_proc('RandomGoogle', '関連するかもしれないページ検索') do
	saveconf_random_google
	random_google_init

	r = <<-HTML
	<h3 class="subtitle">キーワードの数</h3>
	<p>日記本文から抽出するキーワードの数</p>
	<p><select name="random_google_n">
	HTML

	1.upto(9) do |i|
		r << %Q|		<option value="#{i}"#{@conf['random_google.n'] == i ? " selected" : ""}>#{i}</option>\n|
	end
	r << <<-HTML
	</select></p>

	<h3 class="subtitle">表示関連</h3>
	<p>googleへのリンクを示す文字列とリンクの上にマウスポインタを置いた時にポップアップする文字列を指定します．文字列中の $1 は抽出されたキーワードで置換されます．</p>
	<p>リンク：<input name="random_google_caption" size="70" value="#{h @conf['random_google.caption']}"></p>
	<p>ポップアップ：<input name="random_google_popup" size="70" value="#{h @conf['random_google.popup']}"></p>

	<h3 class="subtitle">追加するキーワード</h3>
	<p>追加したいキーワードを指定します．複数指定する場合はキーワードをスペースで区切って指定してください．</p>
	<p>例)</p><pre>-site:example.com</pre>
	<p><input name="random_google_append" size="70" value="#{h @conf['random_google.append']}"></p>

	<h3 class="subtitle">除外するキーワード</h3>
	<p>除外したいキーワードを指定します．複数指定する場合はキーワードをスペースで区切って指定してください．</p>
	<p>例)</p><pre>a the</pre>
	<p><input name="random_google_exception" size="70" value="#{h @conf['random_google.exception']}"></p>
	HTML

		r << <<-HTML
	<h3 class="subtitle">形態素解析器の利用</h3>
	<p>キーワードの抽出に形態素解析器を利用するかどうかを指定します．形態素解析器を使用しない場合は/([亜-瑤]{2,}|[ァ-ヶー]{2,}|[0-9A-Za-z]{2,})/という正規表現でキーワードを抽出しますが，あまり精度はよくありません．</p>
	<p>ChasenやMeCabが標準パスにインストールされていない場合は「場所を指定する」を選択し，下の「形態素解析器のパス」で形態素解析器を絶対パスで指定して下さい．</p>
	<p>ChasenやMeCab以外の形態素解析器を利用したい場合も同様に「場所を指定する」を選択し，下の「形態素解析器のパス」で形態素解析器を絶対パスで指定して下さい．最初のカラムに形態素が出力され，かつ同じ行にその形態素の品詞(「名詞」等)が出力されるような形態素解析器であれば利用可能です．</p>
	<p><select name="random_google_analyzer">
		<option value="chasen"#{@conf['random_google.analyzer'] == "chasen" ? " selected" : ""}>ChaSenを利用する</option>
		<option value="mecab"#{@conf['random_google.analyzer'] == "mecab" ? " selected" : ""}>MeCabを利用する</option>
		<option value="user_defined"#{@conf['random_google.analyzer'] == "user_defined" ? " selected" : ""}>場所を指定する</option>
		<option value="internal"#{@conf['random_google.analyzer'] == "internal" ? " selected" : ""}>利用しない</option>
 	</select></p>

	<h3 class="subtitle">形態素解析器のパス</h3>
	<p>利用する形態素解析器を絶対パスで指定します．</p>
	<p>例)</p><pre>/usr/local/bin/chasen</pre>
	<p><input name="random_google_analyzer_path" size="70" value="#{h @conf['random_google.analyzer_path']}"></p>
	HTML
	r
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
