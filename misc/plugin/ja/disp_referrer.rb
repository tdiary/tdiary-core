# -*- coding: utf-8 -*-
=begin
= 本日のリンク元もうちょっとだけ強化プラグイン((-$Id: disp_referrer.rb,v 1.46 2008-03-02 09:01:46 kazuhiko Exp $-))
日本語リソース

== 概要
アンテナからのリンク、サーチエンジンの検索結果を、通常のリンク元の下にま
とめて表示します。サーチエンジンの検索結果は、検索語毎にまとめられます。

最新の日記の表示では、通常のリンク元以外のリンク元を隠します。

== 注意
以前の版(1.1.2.39以前)からコードのほとんどを実装しなおしたため、
* 検索エンジンに関する動作が違う
* 廃止されたオプションがある
* オプション名が変更された
という非互換があります。基本的な設定はWWWブラウザからできるようになって
いますので、我慢してください。すみません。

以前の版に比べると、
* キャッシュにより表示が高速化された((-手元では、キャッシュを使わない場
  合にくらべて、1日分で2/3ほど、最新3日分で1/2ほどの実時間で日記が生成
  されました-))。この機能は残念ながら、レンタル日記などsecure=trueな日記
  では使えません。
* リンク元置換リストにないURLを比較的簡単にWWWブラウザからリストに追加で
  きるようになった
* 置換後の文字列の最初に[]で囲まれた文字を入れることによって、ユーザー
  がカテゴリーを増設できるようになった。((-tDiary本体とは違い、１つの
  URLは１つのカテゴリーしか持てないことにご注意ください。-))
* 基本的な設定をWWWブラウザからできるようになった
* disp_referrer.rbが無くても使える
* UconvライブラリやNoraライブラリがあればあるなりに、無ければないなりに
  動作する
という利点があります。

== 使い方
このプラグインをインストールすることで、デフォルトでは、
* 一日分の日記の表示で、「本日のリンク元」がアンテナ、検索エンジン、その
  他にまとめて表示されるようになります。置換後の文字列の最後の()を除いた
  タイトルでグループします。また、検索エンジンからのリンクは、キーワード
  別にまとめられます。
* 最新の日記の表示で、「本日のリンク元」にアンテナや検索エンジンからのリ
  ンクが表示されなくなります。
リンク元URLのタイトルへの置換は、tDiary本体のリンク元置換リストを使いま
す。

オプションについては下記をご覧ください。基本的なオプションは、tDiaryの設
定画面から、「リンク元もうちょっと強化」をクリックすることで設定できます。
初めて設定する時には、
  Insecure: can't modify hash (SecurityError)
というエラーが出る可能性があります。これはtDiaryの問題です。この場合には、
tDiaryを新しくして1.5.5.20030806以降を使うか、「基本」から何も変更せず
に「OK」を押すことでエラーを回避できるでしょう。

リンク元置換リストやオプションを変更した場合は、キャッシュディレクトリ
にあるキャッシュファイルdisp_referrer2.cacheやdisp_referrer2.cache~をプ
ラグインの設定画面から更新する必要があります。このプラグインの設定画面か
ら変更した項目については、変更時にキャッシュの更新もします。

リンク元は、以下のような基準で分類されます。

: 通常のリンク元(「本日のリンク元」)
  リンク元置換リストにあてはまるURLのうち、下記以外のもの。
  @options['disp_referrer2.unknown.divide']=falseの場合は、リンク元置換
  リストにあてはまらないURLもここに含まれます。

  さらに、リンク元置換リストによって置換された後の文字列の最初に[]で囲ま
  れた文字列がある場合は、これをカテゴリーと解釈してカテゴリー別に表示を
  分けます。この機能を抑制するには、WWWブラウザから設定画面を利用するか、
  tdiary.confで@options['disp_referrer2.normal.categorize']=falseにして
  ください。このオプションを変更した場合にはキャッシュを更新する必要があ
  ります。

: アンテナ
  URLに /a/ antenna/ antenna. などの文字列が含まれるか、置換後の文字列に、
  アンテナ links などの文字列が含まれるリンク元です。これらの条件は、
  @options['disp_referrer2.antenna.url']や
  @options['disp_referrer2.antenna.title']によって変更できます。
  tdiary.confを編集してください。キャッシュを更新する必要があります。

: その他
  リンク元置換リストになかったURLです。あまり長いURLは、tDiary本体の置換
  リストによって通常のリンク元に分類されてしまう可能性があります。

: 検索
  このプラグインに含まれる検索エンジンのリストに一致したURLです。リスト
  はDispRef2Setup::Enginesにあります。うまく検索エンジンと認識されない
  URLは、ほとんどの場合、通常のリンク元に混ざって表示されてしまうでしょ
  う。このような場合は、URLを
  ((<URL:http://tdiary-users.sourceforge.jp/cgi-bin/wiki.cgi?disp_referrer2.rb>))
  に知らせていただけると作者が喜びます。

=== 環境
ruby-1.6.7と1.8.0で動作を確認しています。これ以外のバージョンのRubyでも
動作するかもしれません。

tdiary-1.5.3-20030509以降で使えます。これ以前のtDiary-1.5では、
00default.rbにbot?メソッドが定義されていないため、検索エンジンのクロール
に対してリンク元が表示されてしまいます。

mod_rubyでの動作は今のところ確認していません。

=== インストール方法
このファイルをtDiaryのpluginディレクトリ内にコピーしてください。このプラ
グインの最新版は、
((<URL:http://zunda.freeshell.org/d/plugin/disp_referrer2.rb>))
にあるはずです。

また、Noraライブラリがインストールされている場合には、URLの解釈やHTMLの
エスケープに、Rubyに標準添付のCGIライブラリの代わりにNoraライブラリを使
用します。これにより、処理速度が若干速くなります((-手元で試したところ、
一日分の表示にかかる時間が1割程度短かくなりました。-))。Noraについての詳
細は、((<URL:http://raa.ruby-lang.org/list.rhtml?name=Nora>))を参照して
ください。

=== オプション
この日記で設定できるオプションの一覧は、DispRef2Setup::Defaultsにありま
す。これらのオプションのkeyの最初に、「disp_referrer2.」を追加すること
で、tdiary.confの@optionsのkeyとなり、tdiary.confから設定できるようにな
ります。これらのオプションのうち、DispRef2URL::Cached_optionsに挙げられ
ているものは、変更の際にキャッシュの更新が必要です。

また、tDiaryの設定画面から「リンク元もうちょっと強化」を選ぶことでWWWブ
ラウザから設定できる項目もあります。

== 謝辞
このプラグインは、
* UTF-8文字列のEUC文字列への変換機能
* 一部の検索エンジン名とそのURL
* 検索エンジンのロボットのクローリングの際にリンク元を表示しない機能
を、MUTOH Masaoさんのdisp_referrer.rbからコピー、編集して使わせていただ
いています。(検索エンジンのロボットに関する機能は現在はtDiary本体にとり
こまれています。)

また、URLを解釈する機能の一部を、Rubyに付属のcgi.rbからコピー、編集して
使わせていただいています。

さらに、通常のリンク元を[]で囲まれた文字列を使ってカテゴリ分けするアイデ
ィアは、kazuhikoさんのものです。

皆様に感謝いたします。

== Todos
* parse_as_search高速化: hostnameのキャッシュ？

== 著作権について
Copyright (C) 2003 zunda <zunda at freeshell.org>

Please note that some methods in this plugin are written by other
authors as written in the comments.

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL version 2 or later.
=end

=begin ChangeLog
See ../ChangeLog for changes after this.

* Mon Sep 29, 2003 zunda <zunda at freeshell.org>
- forgot to change arguments after changing initialize()
* Thu Sep 25, 2003 zunda <zunda at freeshell.org>
- name.untaint to eval name
* Thu Sep 25, 2003 zunda <zunda at freeshell.org>
- use to_native instead of to_euc
* Mon Sep 19, 2003 zunda <zunda at freeshell.org>
- disp_referrer2.rb,v 1.1.2.104 commited as disp_referrer.rb
* Mon Sep  1, 2003 zunda <zunda at freeshell.org>
- more strcit check for infoseek search enigne
* Wed Aug 27, 2003 zunda <zunda at freeshell.org>
- rd.yahoo, Searchalot, Hotbot added
* Tue Aug 12, 2003 zunda <zunda at freeshell.org>
- search engine list cleaned up
* Mon Aug 11, 2003 zunda <zunda at freeshell.org>
- instance_eval for e[2] in the search engine list
* Wed Aug  7, 2003 zunda <zunda at freeshell.org>
- WWW browser configuration interface
  - キャッシュの更新をより確実にするようにしました。WWWブラウザから置換
    リストを作った場合にはリストの最初に追加されます。
  - secure=trueな日記でその他のリンク元リストが表示できるようになりました。
- Regexp generation for Wiki sites
* Wed Aug  6, 2003 zunda <zunda at freeshell.org>
- WWW browser configuration interface
  - 主なオプションとリンク元置換リストの効率的な編集がWWWブラウザからで
    きるようになりました。secure=trueな日記では一部の機能は使えません。
* Sat Aug  2, 2003 zunda <zunda at freeshell.org>
- Second version
- basic functions re-implemented
  - オプションを命名しなおしました。また不要なオプションを消しました。
    tdiary.confを編集していた方は、お手数ですが設定をしなおしてください。
  - Noraライブラリとキャッシュの利用で高速化しました。
  - 検索エンジンのリストをプラグインで持つようになりました。&や;を含む検
    索文字列も期待通りに抽出できます。
* Mon Feb 17, 2003 zunda <zunda at freeshell.org>
- First version
=end

# Message strings
Disp_referrer2_name = 'リンク元もうちょっと強化'.taint
Disp_referrer2_abstract = <<'_END'.taint
<p>
	アンテナからのリンク、サーチエンジンの検索結果を、
	通常のリンク元の下にまとめて表示します。
	サーチエンジンの検索結果は、検索語毎にまとめられます。
</p>
_END
Disp_referrer2_cache_info = <<'_END'.taint
<p>
	現在、キャッシュの大きさは%1$sバイトです。
</p>
_END
Disp_referrer2_update_info = <<'_END'.taint
<p>
	「<a href="%1$s">リンク元</a>」の変更の後には、
	このチェックボックス
  −<label for="dr2.cache.update"><input id="dr2.cache.update" name="dr2.cache.update" value="force" type="checkbox">キャッシュをクリアする</label>−
	チェックしてからOKをクリックして、
	キャッシュのクリアをしてくさい。
</p>
_END
Disp_referrer2_move_to_refererlist = <<'_END'.taint
	その他のリンク元の置換リストの編集に<a href="%s">移る</a>。
_END
Disp_referrer2_move_to_config = <<'_END'.taint
	基本的な設定に<a href="%s">移る</a>。
_END
Disp_referrer2_also_todayslink = <<'_END'.taint
	リンク元置換リストは「<a href="%s">リンク元</a>」からも編集できます。
_END
Disp_referrer2_antenna_label = 'アンテナ'.taint
Disp_referrer2_unknown_label = 'その他のリンク元'.taint
Disp_referrer2_search_label = '検索'.taint
Disp_referrer2_search_unknown_keyword = 'キーワード不明'.taint
Disp_referrer2_cache_label = '(%sのキャッシュ)'.taint

class DispRef2SetupIF

	# show options
	def show_options
		r = <<-_HTML
			<h3>リンク元の分類と表示</h3>
			<table>
			<tr>
				<td><input name="dr2.current_mode" value="#{Options}" type="hidden">
				リンク元置換リストにないリンク元を
				<td><label for="dr2.unknown.divide.true"><input id="dr2.unknown.divide.true" name="dr2.unknown.divide" value="true" type="radio"#{' checked'if @setup['unknown.divide']}>#{DispRef2String::escapeHTML(@setup['unknown.label'])}として分ける</label>
				<td><label for="dr2.unknown.divide.false"><input id="dr2.unknown.divide.false" name="dr2.unknown.divide" value="false" type="radio"#{' checked'if not @setup['unknown.divide']}>通常のリンク元と混ぜる</label>。
			<tr>
				<td>#{DispRef2String::escapeHTML(@setup['unknown.label'])}を
				<td><label for="dr2.unknown.hide.false"><input id="dr2.unknown.hide.false" name="dr2.unknown.hide" value="false" type="radio"#{' checked'if not @setup['unknown.hide']}>表示する</label>
				<td><label for="dr2.unknown.hide.true"><input id="dr2.unknown.hide.true" name="dr2.unknown.hide" value="true" type="radio"#{' checked'if @setup['unknown.hide']}>隠す</label>。
			<tr>
				<td>リンク元置換リストの置換後の文字列の最初の[]をカテゴリー分けに
				<td><label for="dr2.normal.categorize.true"><input id="dr2.normal.categorize.true" name="dr2.normal.categorize" value="true" type="radio"#{' checked'if @setup['normal.categorize']}>使う</label>
				<td><label for="dr2.normal.categorize.false"><input id="dr2.normal.categorize.false" name="dr2.normal.categorize" value="false" type="radio"#{' checked'if not @setup['normal.categorize']}>使わない</label>。
			<tr>
				<td>一日分の表示で、通常のリンク元以外のリンク元を
				<td><label for="dr2.long.only_normal.false"><input id="dr2.long.only_normal.false" name="dr2.long.only_normal" value="false" type="radio"#{' checked'if not @setup['long.only_normal']}>表示する</label>
				<td><label for="dr2.long.only_normal.true"><input id="dr2.long.only_normal.true" name="dr2.long.only_normal" value="true" type="radio"#{' checked'if @setup['long.only_normal']}>隠す</label>。
			<tr>
				<td>最新の表示で、通常のリンク元以外のリンク元を
				<td><label for="dr2.short.only_normal.false"><input id="dr2.short.only_normal.false" name="dr2.short.only_normal" value="false" type="radio"#{' checked'if not @setup['short.only_normal']}>表示する</label>
				<td><label for="dr2.short.only_normal.true"><input id="dr2.short.only_normal.true" name="dr2.short.only_normal" value="true" type="radio"#{' checked'if @setup['short.only_normal']}>隠す</label>。
			</table>
			<p>最新の表示で、通常のリンク元以外のリンク元を表示する場合には、このプラグインが無い場合とまったく同じ表示になります。</p>
			<h3>通常のリンク元のグループ化</h3>
			<table>
			<tr>
				<td>通常のリンク元を
				<td><label for="dr2.normal.group.true"><input id="dr2.normal.group.true" name="dr2.normal.group" value="true" type="radio"#{' checked'if @setup['normal.group']}>置換後の文字列でまとめる</label>
				<td><label for="dr2.normal.group.false"><input id="dr2.normal.group.false" name="dr2.normal.group" value="false" type="radio"#{' checked'if not @setup['normal.group']}>URL毎に分ける</label>。
			<tr>
				<td>通常のリンク元を置換後の文字列でまとめる場合に、最後の()を
				<td><label for="dr2.normal.ignore_parenthesis.true"><input id="dr2.normal.ignore_parenthesis.true" name="dr2.normal.ignore_parenthesis" value="true" type="radio"#{' checked'if @setup['normal.ignore_parenthesis']}>無視する</label>
				<td><label for="dr2.normal.ignore_parenthesis.false"><input id="dr2.normal.ignore_parenthesis.false" name="dr2.normal.ignore_parenthesis" value="false" type="radio"#{' checked'if not @setup['normal.ignore_parenthesis']}>無視しない</label>。
			</table>
			<h3>アンテナからのリンクのグループ化</h3>
			<table>
			<tr>
				<td>アンテナからのリンクを
				<td><label for="dr2.antenna.group.true"><input id="dr2.antenna.group.true" name="dr2.antenna.group" value="true" type="radio"#{' checked'if @setup['antenna.group']}>置換後の文字列でまとめる</label>
				<td><label for="dr2.antenna.group.false"><input id="dr2.antenna.group.false" name="dr2.antenna.group" value="false" type="radio"#{' checked'if not @setup['antenna.group']}>URL毎に分ける</label>。
			<tr>
				<td>アンテナからのリンクを置換後の文字列でまとめる場合に、最後の()を
				<td><label for="dr2.antenna.ignore_parenthesis.true"><input id="dr2.antenna.ignore_parenthesis.true" name="dr2.antenna.ignore_parenthesis" value="true" type="radio"#{' checked'if @setup['antenna.ignore_parenthesis']}>無視する</label>
				<td><label for="dr2.antenna.ignore_parenthesis.false"><input id="dr2.antenna.ignore_parenthesis.false" name="dr2.antenna.ignore_parenthesis" value="false" type="radio"#{' checked'if not @setup['antenna.ignore_parenthesis']}>無視しない</label>。
			</table>
			<h3>検索キーワードの表示</h3>
			<table>
			<tr>
				<td>検索エンジン名を
				<td><label for="dr2.search.expand.true"><input id="dr2.search.expand.true" name="dr2.search.expand" value="true" type="radio"#{' checked'if @setup['search.expand']}>表示する</label>
				<td><label for="dr2.search.expand.false"><input id="dr2.search.expand.false" name="dr2.search.expand" value="false" type="radio"#{' checked'if not @setup['search.expand']}>表示しない</label>。
			</table>
		_HTML
		r << <<-_HTML
			<h3>キャッシュ</h3>
			<p>キャッシュ機能は、tDiary2形式(DefaultIO)使用時は利用できません。</p>
			<table>
			<tr>
				<td>キャッシュを
				<td><label for="dr2.no_cache.false"><input id="dr2.no_cache.false" name="dr2.no_cache" value="false" type="radio"#{' checked'if not @setup['no_cache']}>利用する</label>
				<td><label for="dr2.no_cache.true"><input id="dr2.no_cache.true" name="dr2.no_cache" value="true" type="radio"#{' checked'if @setup['no_cache']}>利用しない</label>。
			<tr>
				<td>キャッシュの大きさを
				<td colspan="3"><input name="dr2.cache_max_size" value="#{DispRef2String::escapeHTML(@setup['cache_max_size'])}" type="text">バイトまでにする。
			<tr>
				<td>今回の設定変更で、キャッシュを
				<td><label for="dr2.cache.update.force"><input id="dr2.cache.update.force" name="dr2.cache.update" value="force" type="radio">クリアする</label>
				<td><label for="dr2.cache.update.auto"><input id="dr2.cache.update.auto" name="dr2.cache.update" value="auto" type="radio" checked>必要ならクリアする</label>
				<td><label for="dr2.cache.update.never"><input id="dr2.cache.update.never" name="dr2.cache.update" value="never" type="radio">クリアしない</label>。
			</table>
			<p>キャッシュの大きさの制限は目安です。これよりも大きくなる場合もあります。キャッシュの大きさの制限を0にすると、キャッシュの大きさを制限しなくなります。最後にKやMをつけると、キロバイト、メガバイト単位になります。</p>
		_HTML
		r
	end

	# shows URL list to be added to the referer_table or no_referer
	def show_unknown_list
		urls = DispRef2Cache.new( @setup ).urls( DispRef2URL::Unknown ).keys
		if urls.size == 0 then
			urls = DispRef2Latest.new( @cgi, 'latest.rhtml', @conf, @setup ).unknown_urls
		end
		urls.reject!{ |url| DispRef2String::url_match?( url, @setup['reflist.ignore_urls'] ) }
		r = <<-_HTML
			<h3>リンク元置換リスト</h3>
			<input name="dr2.current_mode" value="#{RefList}" type="hidden">
			<p>リンク元無視リストに一致するURLはここには表示されません。</p>
		<p>
			リンク元置換リストや記録除外リストには入れたくないURLは、
			無視リストに入れておくことで、
			下記のリストに現れなくなります。
			無視リストは、
			下記のリストにURLを表示するかどうかの判断にだけ使われます。
			<label for="dr2.clear_ignore_urls"><input id="dr2.clear_ignore_urls" name="dr2.clear_ignore_urls" value="true" type="checkbox">無視リストを空にする場合はチェック</label>して下さい。
		</p>
		_HTML
		if urls.size > 0 then
			r << <<-_HTML
				<p>リンク元置換リストにない下記のURLを、
					リンク元置換リストに入れる場合は、
					下段の空白にタイトルを入力してください。
					また、リンク元記録除外リストに追加するには、
					チェックボックスをチェックしてください。
				</p>
				<p>
					正規表現はリンク元置換リストに追加するのに適当なものになっています。
					確認して、不具合があれば編集してください。
					リンク元置換リストにだけ追加する場合には、
					もう少しマッチの条件が緩いものでもかまいません。
				</p>
				<p>
					最後の空欄は、リンク元置換リストに追加する際のタイトルです。
					URL中に現れた「(〜)」は、
					置換文字列中で「\\1」のような「数字」で利用できます。
					また、sprintf('[tdiary:%d]', $1.to_i+1) といった、
					スクリプト片も利用できます。
				</p>
			_HTML
			if @cgi.auth_type and @cgi.remote_user and @setup['configure.use_link'] then
				r << <<-_HTML
					<p>
						それぞれのURLはリンクになっていますが、これをクリックすることで、
						リンク先に、この日記の更新・設定用のURLが知られることになります。
						適切なアクセス制限が無い場合にはクリックしないようにしてください。
					</p>
				_HTML
			end
			r << <<-_HTML
				<p>
					ここにないURLは「<a href="#{DispRef2String::escapeHTML(@conf.update)}?conf=referer">リンク元</a>」から修正してください。
				</p>
				<dl>
			_HTML
			i = 0
			urls.sort.each do |url|
				shown_url = DispRef2String::escapeHTML( @setup.to_native( DispRef2String::unescape( url ) ) )
				if @cgi.auth_type and @cgi.remote_user and @setup['configure.use_link'] then
					r << "<dt><a href=\"#{DispRef2String::escapeHTML(url)}\">#{shown_url}</a>"
				else
					r << "<dt>#{shown_url}"
				end
				r << <<-_HTML
					<dd>
						<label for="dr2.#{i}.noref"><input id="dr2.#{i}.noref" name="dr2.#{i}.noref" value="true" type="checkbox">除外リストに追加</label>
						<label for="dr2.#{i}.ignore"><input id="dr2.#{i}.ignore" name="dr2.#{i}.ignore" value="true" type="checkbox">無視リストに追加</label><br>
						<input name="dr2.#{i}.reg" value="#{DispRef2String::escapeHTML( DispRef2String::url_regexp( url ) )}" type="text" size="70"><br>
						<input name="dr2.#{i}.title" value="" type="text" size="70">
				_HTML
				i += 1
			end
			r << <<-_HTML
				<input name="dr2.urls" type="hidden" value="#{i}">
				</dl>
			_HTML
		else
			r << <<-_HTML
				<p>現在、#{DispRef2String::escapeHTML(@setup['unknown.label'])}はありません。</p>
			_HTML
		end
		r << <<-_HTML
			<h3>アンテナのための正規表現</h3>
			<p>アンテナのURLや置換後の文字列にマッチする正規表現です。
				これらの正規表現にマッチするリンク元は「アンテナ」に分類されます。</p>
			<ul>
			<li>URL:
				<input name="dr2.antenna.url" value="#{DispRef2String::escapeHTML( @setup.to_native( @setup['antenna.url'] ) )}" type="text" size="70">
				<label for="dr2.antenna.url.default"><input id="dr2.antenna.url.default" name="dr2.antenna.url.default" value="true" type="checkbox">デフォルトに戻す</label>
			<li>置換後の文字列:<input name="dr2.antenna.title" value="#{DispRef2String::escapeHTML( @setup.to_native( @setup['antenna.title'] ) )}" type="text" size="70">
				<label for="dr2.antenna.title.default"><input id="dr2.antenna.title.default" name="dr2.antenna.title.default" value="true" type="checkbox">デフォルトに戻す</label>
			</ul>
			_HTML
		r
	end
end

# Hash table of search engines
# key: company name
# value: array of:
# [0]:url regexp [1]:title [2]:keys for search keyword [3]:cache regexp
# keys - an Array of Strings for usual keys
#      - a String as a Ruby code to be sent to URL after regexp matching
#      - a Symbol to indicate the key contains URL to be recursively converted
DispReferrer2_Google_cache = /cache:[^:]+:([^+]+)+/
DispReferrer2_Yahoofs = /u=(.+)/
DispReferrer2_Engines = {
	'google' => [
		[%r{\Ahttp://(?:[^./]+\.)*google\.([^/]+)/((?:hws/|m/)?search|blogsearch|custom|ie|m)}i, '".#{$1}のGoogle検索"', ['as_q', 'q', 'as_epq'], DispReferrer2_Google_cache],
		[%r{\Ahttp://.*?\bgoogle\.([^/]+)/.*url}i, '".#{$1}のGoogleのURL検索?"', ['as_q', 'q'], DispReferrer2_Google_cache],
		[%r{\Ahttp://.*?\bgoogle/search}i, '"たぶんGoogle検索"', ['as_q', 'q'], DispReferrer2_Google_cache],
		[%r{\Ahttp://eval.google\.([^/]+)}i, '".#{$1}のGoogle Accounts"', [], nil],
		[%r{\Ahttp://(?:images|www)\.google\.([^/]+)/(?:images|imgres|imglanding)}i, '".#{$1}のGoogleイメージ検索"', ['q'], DispReferrer2_Google_cache],
		[%r{\Ahttp://images\.google\.([^/]+)/imgres}i, '".#{$1}のGoogleイメージ検索"', [:prev], DispReferrer2_Google_cache],
		[%r{\Ahttp://translate\.google\.([^/]+)/translate}i, '".#{$1}のGoogle検索"', [:prev], DispReferrer2_Google_cache],
	],
	'yahoo' => [
		[%r{\Ahttp://[^/]+\.rd\.yahoo\.([^/]+)}i, '".#{$1}のYahooのリダイレクタ"', 'split(/\*/)[1]', nil],
		[%r{\Ahttp://srd\.yahoo\.co\.jp/}i, '"Yahooのリダイレクタ"', [], nil],
		[%r{\Ahttp://rd[^/]+\.yahoo\.com/}i, '"Yahooのリダイレクタ"', [], nil], # エンジンは inktomi 製と見た。
		[%r{\Ahttp://([a-z]{2})\.search\.yahoo\.com/}i, '".#{$1}のYahoo!検索"', ['p'], DispReferrer2_Google_cache],
		[%r{\Ahttp://(?:[^bm/]+|blog-search)\.yahoo\.([^/]+)/}i, '".#{$1}のYahoo!検索"', ['p', 'va', 'vp'], DispReferrer2_Google_cache],
		[%r{\Ahttp://wrs\.search\.yahoo\.([^/]+)/(?:.*)\bK=([^/]+)}i, 'keyword=$2; "#{$1}のYahoo!検索"', [], nil],
		[%r{\Ahttp://(?:image-search\.yahoo\.co\.jp/(?:search|detail)|images\.search\.yahoo\.co\.jp/bin/(?:search|query))}, '".co.jpのYahoo!画像検索"', ['p'], DispReferrer2_Google_cache],
		[%r{\Ahttp://images\.search\.yahoo\.(:?com|co\.jp)/search/images(?:/view)?}, '".comのYahoo!画像検索"', ['p'], DispReferrer2_Google_cache],
	],
	'netscape' => [[%r{\Ahttp://[^/]+\.netscape\.([^/]+)/}i, '".#{$1}のNetscape検索"', ['search', 'query'], DispReferrer2_Google_cache]],
	'msn' => [[%r{\Ahttp://[^/]+\.MSN\.([^/]+)/}i, '".#{$1}のMSNサーチ"', ['q', 'MT'], nil ]],
	'bing' => [[%r{\Ahttp://(www|jp)\.bing\.com/}i, '"Bing検索"', ['q'], nil ]],
	'auone' => [[%r{\Ahttp://search\.auone.jp/}i, '"auOne検索"', ['q'], nil ]],
	'metacrawler' => [[%r{\Ahttp://[^/]+\.metacrawler.com/}i, '"MetaCrawler"', ['q'], nil ]],
	'metabot' => [[%r{\Ahttp://[^/]+\.metabot\.ru/}i, '"MetaBot.ru"', ['st'], nil ]],
	'altavista' => [[%r{\Ahttp://(?:[^/]+\.)?altavista\.([^/]+)/}i, '".#{$1}のAltaVista検索"', ['q'], nil ]],
	'infoseek' => [
		[%r{\Ahttp://(www\.)?infoseek\.co\.jp/}i, '"Infoseek"', ['qt'], nil],
		[%r{\Ahttp://search\d*\.www\.infoseek\.co\.jp/(?:[IO]Titles|Seek|Web)}, '"Infoseekハイブリッド検索"', ['qt'], nil],
	],
	'odn' => [[%r{\Ahttp://[^/]+\.odn\.ne\.jp/}i, '"ODN検索"', ['QueryString', 'key'], nil ]],
	'lycos' => [[%r{\Ahttp://[^/]+\.lycos\.([^/]+)/}i, '".#{$1}のLycos"', ['query', 'q', 'qt'], nil ]],
	'fresheye' => [[%r{\Ahttp://[^/]+\.fresheye}i, '"フレッシュアイ"', ['kw'], nil ]],
	'goo' => [
		[%r{\Ahttp://((www|ocn|dictionary|kids|eco|oshiete|(?:[^/]+\.)?search|(?:[^/]+\.)?blog|community|machi|bb|dir|channel|ocnsearch)\.)?goo\.ne\.jp/}i, '"goo"', ['MT'], nil ],
		[%r{\Ahttp://bsearch\.goo\.ne\.jp/(?:movie\.jsp|video/)}i, '"goo動画検索"', ['MT'], nil ],
		[%r{\Ahttp://bsearch\.goo\.ne\.jp/audio\.jsp}i, '"goo音楽検索"', ['MT'], nil ],
		[%r{\Ahttp://bsearch\.goo\.ne\.jp/(?:image|imgdt)\.jsp}i, '"goo画像検索"', ['MT'], nil ],
		[%r{\Ahttp://(?:[^/]+\.)?image\.goo\.ne\.jp/}i, '"goo画像検索"', ['MT'], nil ],
		[%r{\Ahttp://(?:[^/]+\.)?mobile\.goo\.ne\.jp/search(?:_i)?.jsp}i, '"gooケータイサイト検索"', ['MT'], nil ],
		[%r{\Ahttp://((www|ocn|dictionary|kids|eco|oshiete|(?:[^/]+\.)?search|community|machi|bb|dir|channel|ocnsearch)\.)?goo\.ne\.jp/}i, '"goo"', ['MT'], nil ],
	],
	'nifty' => [
		[%r{\Ahttp://search\.nifty\.com/}i, '"@nifty/@search"', ['q', 'Text', 'text'], DispReferrer2_Google_cache],
		[%r{\Ahttp://srchnavi\.nifty\.com/}i, '"@niftyのリダイレクタ"', ['title'], nil ],
		[%r{\Ahttp://azby\.search\.nifty\.com/}i, '"AzbyClub"', ['Text'], nil ],
	],
	'excite' => [[%r{\Ahttp://[^/]+\.excite\.([^/]+)/}i, '".#{$1}のExcite"', ['search', 's', 'query', 'qkw'], nil ]],
	'biglobe' => [
		[%r{\Ahttp://(?:[^/]+\.)?search\.biglobe\.ne\.jp/}i, '"BIGLOBEサーチ"', ['q'], nil ],
		[%r{\Ahttp://(?:[^/]+\.)?search\.biglobe\.ne\.jp/}i, '"BIGLOBEサーチ"', [], nil ],
	],
	'dion' => [[%r{\Ahttp://dir\.dion\.ne\.jp/}i, '"Dion"', ['QueryString', 'key'], nil ]],
	'naver' => [[%r{\Ahttp://[^/]+\.naver\.co\.jp/}i, '"NAVER Japan"', ['query'], nil ]],
	'webcrawler' => [[%r{\Ahttp://[^/]+\.webcrawler\.com/}i, '"WebCrawler"', ['qkw'], nil ]],
	'euroseek' => [[%r{\Ahttp://[^/]+\.euroseek\.com/}i, '"Euroseek.com"', ['string'], nil ]],
	'aol' => [
		[%r{\Ahttp://[^/]+\.aol\.}i, '"AOLサーチ"', ['query', 'query_contain'], nil ],
		[%r{\Ahttp://aolsearch\.[^/]+\.aol\.com/redir_convert\.adp}i, '"AOLサーチ"', ['query_contain'], nil]
	],
	'alltheweb' => [
		[%r{\Ahttp://[^/]+\.alltheweb\.com/}i, '"AlltheWeb.com"', ['q'], nil ],
		[%r{\Ahttp://[^/]+\.alltheweb\.com/}i, '"AlltheWeb.com"', [], nil ],
	],
	'kobe-u' => [
		[%r{\Ahttp://bach\.scitec\.kobe-u\.ac\.jp/cgi-bin/metcha\.cgi}i, '"メッチャ検索エンジン"', ['q'], nil ],
		[%r{\Ahttp://bach\.istc\.kobe-u\.ac\.jp/cgi-bin/metcha\.cgi}i, '"メッチャ検索エンジン"', ['q'], nil ],
	],
	'tocc' => [[%r{\Ahttp://www\.tocc\.co\.jp/search/}i, '"TOCC/Search"', ['QRY'], nil ]],
	'yappo' => [[%r{\Ahttp://i\.yappo\.jp/}i, '"iYappo"', [], nil ]],
	'suomi24' => [[%r{\Ahttp://[^/]+\.suomi24\.([^/]+)/.*query}i, '"Suomi24"', ['q'], DispReferrer2_Google_cache]],
	'earthlink' => [[%r{\Ahttp://search\.earthlink\.net/search}i, '"EarthLink Search"', ['as_q', 'q', 'query'], DispReferrer2_Google_cache]],
	'infobee' => [[%r{\Ahttp://infobee\.ne\.jp/}i, '"新鮮情報検索"', ['MT'], nil ]],
	't-online' => [[%r{\Ahttp://brisbane\.t-online\.de/}i, '"T-Online"', ['q'], DispReferrer2_Google_cache]],
	'walla' => [[%r{\Ahttp://find\.walla\.co\.il/}i, '"Walla! Channels"', ['q'], nil ]],
	'mysearch' => [[%r{\Ahttp://[^/]+\.mysearch\.com/}i, '"My Search"', ['searchfor'], nil ]],
	'jword' => [[%r{\Ahttp://[^/]+\.jword\.jp/}i, '"JWord"', ['name', 'q'], nil ]],
	'nytimes' => [[%r{\Ahttp://query\.nytimes\.com/search}i, '"New York Times: Search"', ['as_q', 'q', 'query'], DispReferrer2_Google_cache]],
	'aaacafe' => [[%r{\Ahttp://search\.aaacafe\.ne\.jp/search}i, '"AAA!CAFE"', ['key'], nil]],
	'virgilio' => [[%r{\Ahttp://search\.virgilio\.it/search}i, '"VIRGILIO Ricerca"', ['qs'], nil]],
	'ceek' => [[%r{\Ahttp://www\.ceek\.jp/}i, '"ceek.jp"', ['q'], nil]],
	'cnn' => [[%r{\Ahttp://websearch\.cnn\.com/}i, '"CNN.com"', ['query', 'as_q', 'q', 'as_epq'], DispReferrer2_Google_cache]],
	'webferret' => [[%r{\Ahttp://webferret\.search\.com/}i, '"WebFerret"', 'split(/,/)[1]', nil]],
	'eniro' => [[%r{\Ahttp://www\.eniro\.se/}i, '"Eniro"', ['query', 'as_q', 'q'], DispReferrer2_Google_cache]],
	'passagen' => [[%r{\Ahttp://search\.evreka\.passagen\.se/}i, '"Eniro"', ['q', 'as_q', 'query'], DispReferrer2_Google_cache]],
	'redbox' => [[%r{\Ahttp://www\.redbox\.cz/}i, '"RedBox"', ['srch'], nil]],
	'odin' => [[%r{\Ahttp://odin\.ingrid\.org/}i, '"ODiN検索"', ['key'], nil]],
	'kensaku' => [[%r{\Ahttp://www\.kensaku\.}i, '"kensaku.jp検索"', ['key'], nil]],
	'hotbot' => [[%r{\Ahttp://www\.hotbot\.}i, '"HotBot Web Search"', ['MT'], nil ]],
	'searchalot' => [[%r{\Ahttp://www\.searchalot\.}i, '"Searchalot"', ['q'], nil ]],
	'cometsystems' => [[%r{\Ahttp://search\.cometsystems\.com/}i, '"Comet Web Search"', ['qry'], nil ]],
	'bulkfeeds' => [
		[%r{\Ahttp://bulkfeeds\.net/app/search2}i, '"Bulkfeeds: RSS Directory & Search"', ['q'], nil ],
		[%r{\Ahttp://bulkfeeds\.net/app/similar}i, '"Bulkfeeds Similarity Search"', ['url'], nil ],
	],
	'answerbus' => [
		[%r{\Ahttp://www\.answerbus\.com/}i, '"AnswerBus"', [], nil ],
		[%r{\Ahttp://answerbus\.coli\.uni-sb\.de/cgi-bin/answerbus/answer.cgi}i, '"AnswerBus"', [], nil ],
	],
	'dogplile' => [[%r{\Ahttp://www.\dogpile\.com/info\.dogpl/search/web/}i, '"dogpile"', [], nil ]],
	'www' => [[%r{\Ahttp://www\.google/search}i, '"Google検索?"', [:prev, 'as_q', 'q'], DispReferrer2_Google_cache]],	# TLD missing
	'planet' => [[%r{\Ahttp://www\.planet\.nl/planet/}i, '"Planet-Zoekpagina"', ['googleq', 'keyword'], DispReferrer2_Google_cache]], # googleq parameter has a strange prefix
	'dcn' => [[%r{\Ahttp://www\.dcn\.to/~comment/cgi-bin/commenton\.cgi}i, '"メタサーチCOMMENTON"', ['q'], nil ]],
	'ask' => [
		[%r{\Ahttp://ask\.jp/web.asp}i, '"ask.jp"', ['q'], nil ],
		[%r{\Ahttp://jp\.ask\.com}i, '"ask.com"', ['q'], nil],
	],
	'searchscout' => [[%r{\Ahttp://results\.searchscout\.com/search}i, '"SearchSout"', ['k'], nil ]],
	'inktomi' => [[%r{\Ahttp://rdrw1.inktomi.com/click}i, '"inktomi のリダイレクタ"', [], nil]],
	'3721' => [[%r{\Ahttp://(?:seek|nmsearch)\.3721\.com/}i, '"3721网頁搜索"', ['p','name'], nil]],
	'yisou' => [[%r{\Ahttp://www\.yisou\.com/}i, '"一搜"', ['p'], nil]],
	'devilfinder' => [[%r{\Ahttp://www\.devilfinder\.com/find.php}i, '"The Devilfinder"', ['q'], nil]],
	'lyricsuniverse' => [[%r{\Ahttp://www\.lyricsuniverse\.com/}, '"LYRICS Universe"', [], nil]],
	'vivisimo' => [[%r{\Ahttp://[^/]+\.vivisimo\.com/search}i, '"Vivisimo"', [], nil]],
	'a9' => [[%r{\Ahttp://a9\.com/}i, '"A9"', ['q'], nil]],
	'nttrd' => [[%r{\Ahttp://labs\.nttrd\.com/cgi-bin/index\.cgi}, '"gooラボ"', ['q'], nil]],
	'whatis' => [[%r{\Ahttp://whatis\.techtarget\.com/wsearchResults/}i, '"WhatIs.com | web search"', ['query'], nil]],
	'comcast' => [[%r{\Ahttp://www\.comcast\.net/qry/websearch}i, '"COMCAST"', ['query'], nil]],
	'mywebsearch' => [[%r{\Ahttp://www\.mywebsearch\.com/jsp/GGmain.jsp}i, '"My Web Search"', ['seachfor'], nil]],
	'wisenut' => [[%r{\Ahttp://www\.wisenut\.com/search/query.dll}, '"WiseNut"', ['q'], nil]],
	'livedoor' => [[%r{\Ahttp://(sf|www|search)\.livedoor\.}i, '"Livedoor"', ['q'], nil ]],
	'tkensaku' => [[%r{\Ahttp://www\.tkensaku\.com/sclient\.cgi}i, '"TKENSAKU"', ['value'], nil]],
	'yahoofs' => [[%r{\Ahttp://cache\.yahoofs\.jp/(?:search/)?cache}i, '"Yahoo! cache"', ['p', 'w'], nil]],
	'googlie' => [[%r{\Ahttp://www\.googlie\.com/search}i, '"Google検索(へのリダイレクタ)"', [:prev, 'as_q', 'q'], DispReferrer2_Google_cache]],
	'toppg' => [[%r{\Ahttp://g\.toppg\.to/search}i, '"Google検索(へのリダイレクタ)"', [:prev, 'as_q', 'q'], DispReferrer2_Google_cache]],
	'naoya' => [[%r{\Ahttp://naoya\.dyndns\.org/feedback/app/search}i, '"FeedBack"', ['keyword'], nil]],
	'blogpeople' => [[%r{\Ahttp://bst\.blogpeople\.net/search_result\.jsp}i, '"blogpeople"', ['keyword'], nil]],
	'matome' => [[%r{\Ahttp://\w+\.matome\.jp/(?:keyword|tag)/(.*(?=\.html\Z)|.*\Z)}i, 'keyword=$1; "まとめ検索"', [], nil]],
	'210' => [[%r{\Ahttp://210\.174\.160\.70/se_root.phtml}i, '"JWord（日本語キーワード）"', ['name'], nil]],
	# % whois 64.233.160
	# NetRange:   64.233.160.0 - 64.233.191.255
	# CIDR:       64.233.160.0/19
	# NetName:    GOOGLE
	'233' => [[%r{\Ahttp://64\.233\.(?:1[6-8][0-9]|190|191)\.\d+/}i, '"Google検索"', [:prev, 'as_q', 'q'], DispReferrer2_Google_cache]],
	# % whois 66.102.0.0
	# NetRange:   66.102.0.0 - 66.102.15.255
	# CIDR:       66.102.0.0/20
	# NetName:    GOOGLE-2
	'102' => [[%r{\Ahttp://66\.102\.(?:[0-9]|1[0-5])\.\d+/}i, '"Google検索"', [:prev, 'as_q', 'q'], DispReferrer2_Google_cache]],
	# other google candidates:
	# % whois 216.239.37.104
	# NetRange:   216.239.32.0 - 216.239.63.255
	# CIDR:       216.239.32.0/19
	# NetName:    GOOGLE
	'216' => [[%r{\Ahttp://216\.239\.(?:3[2-9]|[4-5]\d|6[0-3])\.\d+/}i, '"Google検索"', [:prev, 'as_q', 'q'], DispReferrer2_Google_cache]],
	# % whois 72.14.203.104
	# NetRange:   72.14.192.0 - 72.14.239.255
	# CIDR:       72.14.192.0/19, 72.14.224.0/20
	# NetName:    GOOGLE
	'14' => [[%r{\Ahttp://72\.14\.(?:19[2-9]|2\d\d)\.\d+/}i, '"Google検索"', [:prev, 'as_q', 'q'], DispReferrer2_Google_cache]],
	# % whois 66.249.93.104
	# NetRange:   66.249.64.0 - 66.249.95.255
	# CIDR:       66.249.64.0/19
	# NetName:    GOOGLE
	'249' => [[%r{\Ahttp://66\.249\.(?:6[4-9]|[7-8]\d|9[0-5])\.\d+/}i, '"Google検索"', [:prev, 'as_q', 'q'], DispReferrer2_Google_cache]],
	'ezweb' => [[%r{\Ahttp://ezsch\.ezweb\.ne\.jp/search/}i, '"EZweb検索"', ['query'], nil]],
	'overture' => [[%r{\Ahttp://(?:\w+\.)?overture\.com/}i, '"Overture検索"', ['Keywords'], nil]],
	'multimeta' => [[%r{\Ahttp://(?:\w+\.)?multimeta\.com/}i, '"Multimeta検索"', ['suchbegriff'], nil]],
	'starware' => [[%r{\Ahttp://search\.starware\.com/}i, '"Starware検索"', ['qry'], nil]],
	'rambler' => [[%r{\Ahttp://\w+\.rambler\.ru/}i, '"Rambler"', ['words'], nil]],
	'technorati' => [
		[%r{\Ahttp://www\.technorati\.jp\/search\/search\.html}i, '"テクノラティ"', ['query'], nil],
		[%r{\Ahttp://www\.technorati\.jp\/search\/(.*)}i, 'keyword=$1; "テクノラティ"', [], nil],
	],
	'pagesupli' => [
		[%r{\Ahttp://www\.pagesupli\.com/cgi-bin/nph-image.exe}i, '"pageone検索"', ['q'], nil],
		[%r{\Ahttp://www\.pagesupli\.com/\w+/(.*)}i, 'keyword=$1; "pageone検索"', [], nil],
	],
	'yahoogle' => [[%r{\Ahttp://www\.yahoogle\.jp/(?:yahoogle|google|yahoo)-\d+-(.+)\.html\Z}i, 'keyword=$1; "yahoogle!"', [], nil]],
	# $ whois 209.85.165.104
	# NetRange:   209.85.128.0 - 209.85.255.255
	# CIDR:       209.85.128.0/17
	# NetName:    GOOGLE
	'85' => [[%r{\Ahttp://209\.85\.(?:12[8-9]|1[3-9]\d|2\d\d)\.\d+/}i, '"Google検索"', [:prev, 'as_q', 'q'], DispReferrer2_Google_cache]],
	'chew' => [[%r{\Ahttp://blog\.chew\.jp/result/(?:.*/)?(.+)}, 'keyword=$1; "YGブログ検索"', [], nil]],
	'x0' => [[%r{\Ahttp://bloger\.x0\.com/result/(?:.*/)?(.+)}, 'keyword=$1; "YGブログ検索"', [], nil]],
	'wordtantei' => [[%r{\Ahttp://wordtantei\.com/result/(?:.*/)?(.+)}, 'keyword=$1; "ワード探偵"', [], nil]],
	'sfa-cms' => [[%r{\Ahttp://www\.sfa-cms\.(?:com|net)/word/(?:.*/)?(.+)}, 'keyword=$1; "入れ⇔替え検索"', [], nil]],
	'hatena' => [[%r{\Ahttp://search\.hatena\.ne\.jp/}i, '"はてな検索"', ['word'], nil]],
	'live' => [
		[%r{\Ahttp://search\.live\.com/results\.aspx}i, '"Live Search"', ['q'], nil],
		[%r{\Ahttp://search\.live\.com/images/results\.aspx}i, '"Live Search(画像)"', ['q'], nil],
		[%r{\Ahttp://search\.live\.com/news/results\.aspx}i, '"Live Search(ニュース)"', ['q'], nil],

	],
	'rakuten' => [[%r{\Ahttp://websearch\.rakuten\.co\.jp}i, '"楽天ウェブ検索"', ['qt'], nil]],
	'luna' => [[%r{\Ahttp://(:?s|ja\.msearch)\.luna\.tv/search\.aspx}i, '"luna"', ['q'], nil]],
}

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
