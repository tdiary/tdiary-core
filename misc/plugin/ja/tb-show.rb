# Japanese resource of tb-show.rb
#

def tb_show_conf_html
	<<-"HTML"
	<h3 class="subtitle">TrackBack アンカー</h3>
	<p>他のweblogからのTrackBackの先頭に挿入される、リンク用のアンカー文字列を指定します。なお「&lt;span class="tanchor"&gt;_&lt;/span&gt;」を指定すると、テーマによっては自動的に画像アンカーがつくようになります。</p>
	<p><input name="trackback_anchor" value="#{ h(@conf['trackback_anchor'] || @conf.comment_anchor ) }" size="40"></p>
	<h3 class="subtitle">TrackBack 表示方法</h3>
	<p>最新もしくは月別時の表示方法を指定します。</p>
	<p><select name="trackback_shortview_mode">
	#{ [["num_in_reflist", "リンク元一欄に数を表示(常に)"],
	    ["num_in_reflist_if_exists",
	     "リンク元一欄に数を表示(1件以上のみ)"],
	    ["shortlist", "短い一覧を表示"]
	   ].map{ |op|
             "<option value='#{op[0]}' #{'selected' if @conf['trackback_shortview_mode'] == op[0]}>#{op[1]}</option>\n"
	   }.to_s }
	</select></p>
	<h3 class="subtitle">TrackBack リスト表示数</h3>
	<p>最新もしくは月別表示時に表示する、TrackBackの最大件数を指定します。なお、日別表示時にはここの指定にかかわらず最大100件のTrackBackが表示されます。</p>
	<p>最大<input name="trackback_limit" value="#{ h( @conf['trackback_limit'] || @conf.comment_limit )}" size="3">件</p>
	<h3 class="subtitle">TrackBack URL の表示設定</h3>
	<p>最新もしくは月別表示時に TrackBackURL を表示するかどうかを指定します。</p>
	<p><select name="trackback_disp_pingurl">
	<option value="true" #{'selected' if @conf['trackback_disp_pingurl']}>表示</options>
	<option value="false" #{'selected' if !@conf['trackback_disp_pingurl']}>非表示</options>
	</select></p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
