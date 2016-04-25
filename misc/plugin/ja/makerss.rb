# makerss.rb Japanese resources
def makerss_tsukkomi_label( id )
	"#{id[0,4]}-#{id[4,2]}-#{id[6,2]}のツッコミ[#{id[/[1-9]\d*$/]}]"
end

@makerss_conf_label = 'フィード(RSS)の生成'

def makerss_conf_html
	<<-HTML
	<h3>フィード(RSS)の生成</h3>
	<p>フィードは他のプログラムに読みやすい形で、日記の内容を公開します。フィードに含まれる情報はフィードリーダーで読まれたり、更新通知サイトに転載されたりして利用されています。</p>
	#{%Q[<p class="message">「#{@makerss_full.file}」に書き込めません。<br>このファイルはWebサーバによって書き込み可能でなければなりません。</p>] unless @makerss_full.writable?}
	<ul>
	<li>フィードに本文全体を<select name="makerss.hidecontent">
		<option value="f"#{' selected' unless @conf['makerss.hidecontent']}>含める</option>
		<option value="t"#{' selected' if @conf['makerss.hidecontent']}>含めない</option></select></li>
	<li>フィードに含める説明を<select name="makerss.shortdesc">
		<option value="f"#{' selected' unless @conf['makerss.shortdesc']}>できるだけ長くする</option>
		<option value="t"#{' selected' if @conf['makerss.shortdesc']}>最初だけにする</option></select></li>
      <li>「#{ comment_new }」というリンクを挿入<select name="makerss.comment_link">
		<option value="f"#{' selected' unless @conf['makerss.comment_link']}>する</option>
		<option value="t"#{' selected' if @conf['makerss.comment_link']}>しない</option></select></li>
	</ul>

	<h3>ツッコミ抜きのフィード</h3>
	<p>標準のフィードには、あなたが書いた日記本文だけでなく、読者によるツッコミも含まれます。もしツッコミを含まないフィードも配信したいのであれば、こちらも設定してください。なお、標準のフィードが全文を含む場合にはツッコミも全文配信され、そうでない場合にはツッコミの日付と投稿者のみが配信されます。</p>
	#{%Q[<p class="message">「#{@makerss_no_comments.file}」に書き込めません。<br>このファイルはWebサーバによって書き込み可能でなければなりません。</p>] if @conf['makerss.no_comments'] and !@makerss_no_comments.writable?}
	<ul>
	<li>ツッコミ抜きのフィードを<select name="makerss.no_comments">
		<option value="t"#{' selected' if @conf['makerss.no_comments']}>配信する</option>
		<option value="f"#{' selected' unless @conf['makerss.no_comments']}>配信しない</option></select></li>
	</ul>
   HTML
end

@makerss_edit_label = 'ちょっとした修正(フィードを更新しない)'

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
