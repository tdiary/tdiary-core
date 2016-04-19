#
# ja/category.rb : tDiary plugin for show category pages
#
# Copyright (C) 2016 TADA Tadashi
# Distributed under the GPL2 or any later version.
#

@category_conf_label = 'カテゴリ'

def category_conf_html
	r = <<-HTML
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
		数秒から数十秒でインデックスの作成は終了しますが、日記の量が多い場合やサーバの性能が低い場合はタイムアウトしてしまう場合があります。この場合はオフラインで作成して下さい。
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
