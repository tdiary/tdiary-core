# -*- coding: utf-8 -*-
# ja/recent_trackback3.rb
#
# Japanese resources for recent_trackback3.rb
#
# Copyright (c) 2004 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

if @mode == 'conf' || @mode == 'saveconf'
add_conf_proc( 'recent_trackback3', '最近のTrackBack', 'tsukkomi' ) do
	saveconf_recent_trackback3
	recent_trackback3_init
	checked = "t" == @conf['recent_trackback3.tree'] ? ' checked' : ''

	<<-HTML
	<h3 class="subtitle">表示するTrackBackの数</h3>
	<p>最大<input name="recent_trackback3.n" value="#{h( @conf['recent_trackback3.n'] )}" size="3">件</p>

	<h3 class="subtitle">日付フォーマット</h3>
	<p>使用できる'%'文字については<a href="http://www.ruby-lang.org/ja/man/index.cgi?cmd=view;name=Time#strftime">Rubyのマニュアル</a>を参照．</p>
	<p><input name="recent_trackback3.date_format" value="#{h( @conf['recent_trackback3.date_format'] )}" size="40"></p>

	<h3 class="subtitle">ツリー表示機能</h3>
	<p><label for="recent_trackback3.tree"><input id="recent_trackback3.tree" name="recent_trackback3.tree" type="checkbox" value="t"#{checked} />ツリー表示機能を使用する</label></p>

	<h3 class="subtitle">ツリー表示時のタイトルの長さ</h3>
	<p>ツリー表示機能を使用する時のタイトルの長さを指定します。ツリー表示機能を使用しない場合には関係ありません。</p>
	<p>最大 <input name="recent_trackback3.titlelen" value="#{h( @conf['recent_trackback3.titlelen'] )}" size="3" /> 文字</p>

	<h3 class="subtitle">生成するHTMLのテンプレート</h3>
	<p>各TrackBackをどのようなHTMLで表示するかを指定します．</p>
	<textarea name="recent_trackback3.format" cols="70" rows="3">#{h( @conf['recent_trackback3.format'] )}</textarea>
	<p>テンプレート中の<em>$数字</em>はそれぞれ以下の内容で置き換えられます．必要のないものは指定しなくても構いません．</p>
	<dl>
		<dt>$2</dt><dd>そのTrackBackのURL．</dd>
		<dt>$3</dt><dd>そのTrackBackのexcerpt．</dd>
		<dt>$4</dt><dd>TrackBack送信元のサイト名と記事名．</dd>
		<dt>$5</dt><dd>TrackBack Pingを受信した時刻．「日付フォーマット」で指定した形式で表示されます．</dd>
	</dl>
	HTML
end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
