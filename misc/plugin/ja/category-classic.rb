# -*- coding: utf-8 -*-
# ja/category.rb
#
# Copyright (c) 2004 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL2 or any later version.
#

def category_title
	info = Category::Info.new(@cgi, @years, @conf)
	mode = info.mode
	case mode
	when :year
		period = "#{info.year}年"
	when :half
		period = (info.month.to_i == 1 ? "上半期" : "下半期")
		period = "#{info.year}年 #{period}" if info.year
	when :quarter
		period = "第#{info.month.to_i}四半期"
		period = "#{info.year}年 #{period}" if info.year
	when :month
		period = "#{info.month.to_i}月"
		period = "#{info.year}年 #{period}" if info.year
	end
	period = " (#{period})" if period

	"[#{info.category.join('|')}#{period}]"
end

def category_init_local
	@conf['category.prev_year'] ||= '<< ($1)'
	@conf['category.next_year'] ||= '($1) >>'
	@conf['category.prev_half'] ||= '<< ($1-$2)'
	@conf['category.next_half'] ||= '($1-$2) >>'
	@conf['category.prev_quarter'] ||= '<< ($1-$2)'
	@conf['category.next_quarter'] ||= '($1-$2) >>'
	@conf['category.prev_month'] ||= '<< ($1-$2)'
	@conf['category.next_month'] ||= '($1-$2) >>'
	@conf['category.this_year'] ||= '年'
	@conf['category.this_half'] ||= '半期'
	@conf['category.this_quarter'] ||= '四半期'
	@conf['category.this_month'] ||= '月'
	@conf['category.all_diary'] ||= '全期間'
	@conf['category.all_category'] ||= '全カテゴリ'
	@conf['category.all'] ||= '全期間/全カテゴリ'
end
category_init_local

@category_conf_label = 'カテゴリ'
def category_conf_html
	r = <<HTML
<h3 class="subtitle">カテゴリインデックスの作成</h3>
<p>
カテゴリの機能を利用するにはカテゴリインデックスをあらかじめ作成しておく必要があります。
カテゴリインデックスを作成するには
以下のチェックを入れてからOKボタンを押してください。
</p>
<p><label for="category_initialize">
<input type="checkbox" id="category_initialize" name="category_initialize" value="1">カテゴリインデックスの作成
</label></p>
<p>
日記の量やサーバの性能にもよりますが、数秒から数十秒でインデックスの作成は終了します。
</p>

<h3 class="subtitle">日記編集サポート</h3>
<p>
日記編集画面の「本文」の下にカテゴリ名を一覧表示することができます。
カテゴリ名をクリックすると「本文」にそのカテゴリ名が挿入されます(要JavaScript)。
</p>
<p>
<select name="category.edit_support">
<option value="1"#{" selected" if @conf['category.edit_support'] == 1}>一覧表示</option>
<option value="2"#{" selected" if @conf['category.edit_support'] == 2}>ドロップダウンリスト</option>
<option value="0"#{" selected" if @conf['category.edit_support'] == 0}>表示しない</option>
</select>
</p>

<h3 class="subtitle">表示期間の初期状態</h3>
<p>
カテゴリ表示画面を表示した時の、最初の表示期間を指定します。
</p>
<p>
<select name="category.period">
HTML
	[
		['月', 'month', false],
		['四半期', 'quarter', true],
		['半期', 'half', false],
		['年', 'year', false],
		['全日記', 'all', false],
	].each do |text, value, default|
		selected = @conf["category.period"] ? @conf["category.period"] == value : default
		r << <<HTML
<option value="#{value}"#{" selected" if selected}>#{text}</option>
HTML
	end
	r << <<HTML
</select>
</p>

<h3 class="subtitle">ヘッダ</h3>
<p>
画面上部に表示する文章を指定します。
「&lt;%= category_navi %&gt;」で、カテゴリに特化したナビゲーションボタンを表示することができます。
また「&lt;%= category_list%&gt;」でカテゴリ名一覧を表示することができます。
その他，各種プラグインやHTMLを記述できます。
</p>

<h4>ヘッダ1</h4>
<p>ナビゲーションボタンのすぐ下に表示されます。</p>
<p><textarea name="category.header1" cols="60" rows="5">#{h @conf['category.header1']}</textarea></p>

<h4>ヘッダ2</h4>
<p>H1のすぐ下に表示されます。</p>
<p><textarea name="category.header2" cols="60" rows="5">#{h @conf['category.header2']}</textarea></p>

<h3 class="subtitle">ボタンラベル</h3>
<p>
ナビゲーションボタンのラベルを指定します。
ラベル中の$1と$2は，それぞれ「年」「月」を表す数値で置換されます。
</p>
<table border="0">
<tr><th>ボタン名</th><th>ラベル</th><th>サンプル</th></tr>
HTML
	[
		['前年', 'category.prev_year'],
		['翌年', 'category.next_year'],
		['前の半年', 'category.prev_half'],
		['次の半年', 'category.next_half'],
		['前四半期', 'category.prev_quarter'],
		['次四半期', 'category.next_quarter'],
		['先月', 'category.prev_month'],
		['翌月', 'category.next_month'],
		['今年', 'category.this_year'],
		['現半期', 'category.this_half'],
		['現四半期', 'category.this_quarter'],
		['今月', 'category.this_month'],
		['全日記', 'category.all_diary'],
		['全カテゴリ', 'category.all_category'],
		['全日記/全カテゴリ', 'category.all'],
	].each do |button, name|
		r << <<HTML
<tr>
	<td>#{button}</td>
	<td><input type="text" name="#{name}" value="#{h @conf[name]}" size="30"></td>
	<td><p><span class="adminmenu"><a>#{h @conf[name].sub(/\$1/, "2007").sub(/\$2/, "2")}</a></span></p></td>
</tr>
HTML
	end
	r << <<HTML
</table>
HTML
end

@category_icon_none_label = 'アイコンなし'
@category_icon_conf_label = 'カテゴリアイコン'
def category_icon_conf_html
	r = ''
	unless @conf.secure
		r << <<HTML
<h3 class="subtitle">カテゴリアイコンの置き場所</h3>
<p>
カテゴリアイコン用の画像が保存されているディレクトリとそのURLを指定します。
</p>
<p>
<dl>
<dt>ディレクトリ:</dt>
<dd><input name="category.icon_dir" value="#{h @category_icon_dir}" size="30"></dd>
<dt>URL:</dt>
<dd><input name="category.icon_url" value="#{h @category_icon_url}" size="30"></dd>
</dl>
</p>
<hr>
HTML
	end

	str = ''
	@categories.each do |c|
		str << %Q|\t<tr>\n\t\t<td>#{c}</td>\n\t\t<td>\n|
		str << category_icon_select(c)
		str << %Q|<img src="#{h @category_icon_url}#{h @category_icon[c]}">| if @category_icon[c]
		str << %Q|</td>\n\t</tr>\n|
	end
	r << <<HTML
<h3 class="subtitle">カテゴリアイコン</h3>
<p>
各カテゴリのアイコンをドロップダウンリストから選択します。
<p>
<table>
	<tr><th>カテゴリ</th><th>アイコン</th></tr>
#{str}
</table>
</p>
<hr>
<h3 class="subtitle">アイコンサンプル</h3>
<p>
選択可能なアイコン一覧です．
アイコンにマウスカーソルを合わせるとアイコンのファイル名がポップアップ表示されます。
</p>
<p>
#{category_icon_sample}
</p>
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
