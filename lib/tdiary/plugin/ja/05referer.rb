#
# 05referer.rb: Japanese resource of referer plugin
#
# Copyright (C) 2006, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2 or any later version.
#

def referer_today; '本日のリンク元'; end
def volatile_referer; '以前の日記へのリンク元'; end

def label_no_referer; 'リンク元記録除外リスト'; end
def label_only_volatile; '以前の日記へのリンク元に記録するリスト'; end
def label_referer_table; 'リンク置換リスト'; end

add_conf_proc( 'referer', 'リンク元', 'referer' ) do
	saveconf_referer

	<<-HTML
	<h3 class="subtitle">リンク元の表示</h3>
	<p>リンク元リストを表示するかどうかを指定します。</p>
	<p><select name="show_referer">
		<option value="true"#{" selected" if @conf.show_referer}>表示</option>
		<option value="false"#{" selected" unless @conf.show_referer}>非表示</option>
	</select></p>
	<h3 class="subtitle">#{label_no_referer}</h3>
	<p>リンク元リストに追加しないURLを指定します。正規表現で指定できます。1件1行で入力してください。</p>
	<p>→<a href="#{h @conf.update}?referer=no" target="referer">既存設定はこちら</a></p>
	<p><textarea name="no_referer" cols="70" rows="10">#{h @conf.no_referer2.join( "\n" )}</textarea></p>
	<h3 class="subtitle">#{label_only_volatile}</h3>
	<p>「以前の日記へのリンク元」にのみ記録したいURLはこちらに記述します。「以前の日記へのリンク元」は、新しい日付の日記を書くと消去されます。正規表現で指定できます。1件1行で入力してください。</p>
	<p>→<a href="#{h @conf.update}?referer=volatile" target="referer">既存設定はこちら</a></p>
	<p><textarea name="only_volatile" cols="70" rows="10">#{h @conf.only_volatile2.join( "\n" )}</textarea></p>
	<h3 class="subtitle">#{label_referer_table}</h3>
	<p>リンク元リストのURLを、特定の文字列に変換する対応表を指定できます。1件につき、URLと表示文字列を空白で区切って指定します。正規表現が使えるので、URL中に現れた「(〜)」は、置換文字列中で「\\\\1」のような「\\数字」で利用できます。</p>
	<p>→<a href="#{h @conf.update}?referer=table" target="referer">既存設定はこちら</a></p>
	<p><textarea name="referer_table" cols="70" rows="10">#{h @conf.referer_table2.collect{|a|a.join( " " )}.join( "\n" )}</textarea></p>
	HTML
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
