# -*- coding: utf-8; -*-
#
# ja/00default.rb: Japanese resources of 00default.rb.
#
# Copyright (C) 2001-2005, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2 or any later version.
#

#
# header
#
def title_tag
	r = "<title>#{h @conf.html_title}"
	case @mode
	when 'day', 'comment'
		r << "(#{@date.strftime( '%Y-%m-%d' )})" if @date
	when 'month'
		r << "(#{@date.strftime( '%Y-%m' )})" if @date
	when 'form'
		r << '(追記)'
	when 'edit'
		r << '(編集)'
	when 'preview'
		r << '(プレビュー)'
	when 'showcomment'
		r << '(変更完了)'
	when 'conf'
		r << '(設定)'
	when 'saveconf'
		r << '(設定完了)'
	when 'nyear'
		r << "(#{h @cgi.params['date'][0].sub( /^(\d\d)/, '\1-')}[#{nyear_diary_label}])" if @date
	end
	r << '</title>'
end

#
# TSUKKOMI mail
#
def comment_mail_mime( str )
	require 'nkf'
	NKF::nkf( "-j -m0 -f50", str ).lines.collect do |s|
		%Q|=?ISO-2022-JP?B?#{[s.chomp].pack( 'm' ).gsub( /\n/, '' )}?=|
	end
end

def comment_mail_conf_label; 'ツッコミメール'; end

def comment_mail_basic_html
	@conf['comment_mail.header'] = '' unless @conf['comment_mail.header']
	@conf['comment_mail.receivers'] = '' unless @conf['comment_mail.receivers']
	@conf['comment_mail.sendhidden'] = false unless @conf['comment_mail.sendhidden']

	<<-HTML
	<h3 class="subtitle">ツッコミメールを送る</h3>
	<p>ツッコミがあった時に、メールを送るかどうかを選択します。</p>
	<p><select name="comment_mail.enable">
		<option value="true"#{" selected" if @conf['comment_mail.enable']}>送る</option>
        <option value="false"#{" selected" unless @conf['comment_mail.enable']}>送らない</option>
	</select></p>
	<h3 class="subtitle">送付先</h3>
	<p>メールの送付先を指定します。1行に1メールアドレスの形で、複数指定可能です。指定のない場合には、あなたのメールアドレスに送られます。</p>
	<p><textarea name="comment_mail.receivers" cols="40" rows="3">#{h( @conf['comment_mail.receivers'].gsub( /[, ]+/, "\n") )}</textarea></p>
	<h3 class="subtitle">メールヘッダ</h3>
	<p>メールのSubjectにつけるヘッダ文字列を指定します。振り分け等に便利なように指定します。実際のSubjectには「指定文字列:日付-1」のように、日付とコメント番号が付きます。ただし指定文字列中に、%に続く英字があった場合、それを日付フォーマット指定を見なします。つまり「日付」の部分は自動的に付加されなくなります(コメント番号は付加されます)。</p>
	<p><input name="comment_mail.header" value="#{h @conf['comment_mail.header']}"></p>
	<h3 class="subtitle">非表示ツッコミの扱い</h3>
	<p>フィルタの結果、最初から非表示にされたツッコミが記録されることがあります。この非表示のツッコミが来たときにもメールを発信するかどうかを選択します。</p>
	<p><label for="comment_mail.sendhidden"><input type="checkbox" id="comment_mail.sendhidden" name="comment_mail.sendhidden" value="true"#{" checked" if @conf['comment_mail.sendhidden']}>非表示のツッコミでもメールを送る</label></p>
	HTML
end

#
# link to HOWTO write diary
#
def style_howto
	%Q|/<a href="http://docs.tdiary.org/ja/?#{h @conf.style}%A5%B9%A5%BF%A5%A4%A5%EB">書き方</a>|
end

#
# labels (normal)
#
def no_diary; "#{@date.strftime( @conf.date_format )}の日記はありません。"; end
def comment_today; '本日のツッコミ'; end
def comment_total( total ); "(全#{total}件)"; end
def comment_new; 'ツッコミを入れる'; end
def comment_description_default; 'ツッコミ・コメントがあればどうぞ! E-mailアドレスは公開されません。'; end
def comment_limit_label; '本日の日記はツッコミ数の制限を越えています。'; end
def comment_description_short; 'ツッコミ!!'; end
def comment_name_label; 'お名前'; end
def comment_name_label_short; '名前'; end
def comment_mail_label; 'E-mail'; end
def comment_mail_label_short; 'Mail'; end
def comment_body_label; 'コメント'; end
def comment_body_label_short; '本文'; end
def comment_submit_label; '投稿'; end
def comment_submit_label_short; '投稿'; end
def comment_date( time ); time.strftime( "(#{@conf.date_format} %H:%M)" ); end
def trackback_today; '本日のTrackBacks'; end
def trackback_total( total ); "(全#{total}件)"; end

def navi_index; 'トップ'; end
def navi_latest; '最新'; end
def navi_oldest; '最古'; end
def navi_update; "追記"; end
def navi_edit; "編集"; end
def navi_preference; "設定"; end
def navi_prev_diary(date); "前の日記(#{date.strftime(@conf.date_format)})"; end
def navi_next_diary(date); "次の日記(#{date.strftime(@conf.date_format)})"; end
def navi_prev_month; "前月"; end
def navi_next_month; "翌月"; end
def navi_prev_nyear(date); "前の日(#{date.strftime('%m-%d')})"; end
def navi_next_nyear(date); "次の日(#{date.strftime('%m-%d')})"; end
def navi_prev_ndays; "前#{@conf.latest_limit}日分"; end
def navi_next_ndays; "次#{@conf.latest_limit}日分"; end

def submit_label
	if @mode == 'form' or @cgi.valid?( 'appendpreview' ) then
		'追記'
	else
		'登録'
	end
end
def preview_label; 'プレビュー'; end

def nyear_diary_label; "長年日記"; end
def nyear_diary_title; "長年日記"; end

#
# labels (for mobile)
#
def mobile_navi_latest; '最新'; end
def mobile_navi_update; "追記"; end
def mobile_navi_edit; "編集"; end
def mobile_navi_preference; "設定"; end
def mobile_navi_prev_diary; "前"; end
def mobile_navi_next_diary; "次"; end
def mobile_label_hidden_diary; 'この日は【非表示】です'; end

#
# category
#
def category_anchor(c); "[#{c}]"; end

#
# preferences (resources)
#
@conf_saving = '保存中……'

# genre labels
@conf_genre_label['basic'] = '基本'
@conf_genre_label['update'] = '更新'
@conf_genre_label['theme'] = 'テーマ'
@conf_genre_label['tsukkomi'] = 'ツッコミ'
@conf_genre_label['referer'] = 'リンク元'
@conf_genre_label['security'] = 'セキュリティ'
@conf_genre_label['etc'] = 'その他'


add_conf_proc( 'default', 'サイトの情報', 'basic' ) do
	saveconf_default
	@conf.description ||= ''
	@conf.icon ||= ''
	@conf.banner ||= ''
	<<-HTML
	<h3 class="subtitle">タイトル</h3>
	<p>HTMLの&lt;title&gt;タグ中および、モバイル端末からの参照時に使われるタイトルです。HTMLタグは使えません。</p>
	<p><input name="html_title" value="#{h @conf.html_title}" size="50"></p>

	<h3 class="subtitle">著者名</h3>
	<p>あなたの名前を指定します。HTMLヘッダ中に展開されます。</p>
	<p><input name="author_name" value="#{h @conf.author_name}" size="40"></p>

	<h3 class="subtitle">メールアドレス</h3>
	<p>あなたのメールアドレスを指定します。HTMLヘッダ中に展開されます。</p>
	<p><input name="author_mail" value="#{h @conf.author_mail}" size="40"></p>

	<h3 class="subtitle">トップページURL</h3>
	<p>日記よりも上位のコンテンツがあれば指定します。存在しない場合は何も入力しなくてかまいません。</p>
	<p><input name="index_page" value="#{h @conf.index_page}" size="70"></p>

	<h3 class="subtitle">日記のURL</h3>
	<p>日記のURLを指定します。このURLは、さまざまなプラグインで日記を指し示すために利用されるので、正しく一意なものを指定しましょう。</p>
	#{"<p><strong>指定してある値と、現在アクセス中のURLが異なります。注意してください。</strong></p>" unless base_url == @cgi.base_url}
	<p><input name="base_url" value="#{h base_url}" size="70"></p>

	<h3 class="subtitle">日記の説明</h3>
	<p>この日記の簡単な説明を指定します。HTMLヘッダ中に展開されます。何も入力しなくてもかまいません。</p>
	<p><input name="description" value="#{h @conf.description}" size="70"></p>

	<h3 class="subtitle">サイトアイコン(favicon)</h3>
	<p>この日記を表す小さなアイコン画像(favicon)があればそのURLを指定します。HTMLヘッダ中に展開されます。何も入力しなくてもかまいません。</p>
	<p><input name="icon" value="#{h @conf.icon}" size="70"></p>

	<h3 class="subtitle">バナー画像</h3>
	<p>この日記を表す画像(バナー)があればそのURLを指定します。makerssプラグインなどでRSSを出力する場合などに使われます。何も入力しなくてもかまいません。</p>
	<p><input name="banner" value="#{h @conf.banner}" size="70"></p>

	<h3 class="subtitle">フレーム内表示</h3>
	<p>日記全体をフレーム内にくるんで表示することを許可します。</p>
	<p><select name="x_frame_options">
		<option value=""#{" selected" unless @conf.x_frame_options}>許可する</option>
		<option value="SAMEORIGIN"#{" selected" if @conf.x_frame_options == 'SAMEORIGIN'}>同一ドメインなら許可する</option>
		<option value="DENY"#{" selected" if @conf.x_frame_options == 'DENY'}>禁止する</option>
	</select></p>
	HTML
end

add_conf_proc( 'header', 'ヘッダ・フッタ', 'basic' ) do
	saveconf_header

	<<-HTML
	<h3 class="subtitle">ヘッダ</h3>
	<p>日記の先頭に挿入される文章を指定します。HTMLタグが使えます。「&lt;%=navi%&gt;」で、ナビゲーションボタンを挿入できます(これがないと更新ができなくなるので削除しないようにしてください)。また、「&lt;%=calendar%&gt;」でカレンダーを挿入できます。その他、各種プラグインを記述できます。</p>
	<p><textarea name="header" cols="70" rows="10">#{h @conf.header}</textarea></p>
	<h3 class="subtitle">フッタ</h3>
	<p>日記の最後に挿入される文章を指定します。ヘッダと同様に指定できます。</p>
	<p><textarea name="footer" cols="70" rows="10">#{h @conf.footer}</textarea></p>
	HTML
end

add_conf_proc( 'display', '表示一般', 'basic' ) do
	saveconf_display

	<<-HTML
	<h3 class="subtitle">セクションアンカー</h3>
	<p>日記のセクションの先頭(サブタイトルの行頭)に挿入される、リンク用のアンカー文字列を指定します。なお「&lt;span class="sanchor"&gt;_&lt;/span&gt;」を指定すると、テーマによっては自動的に画像アンカーがつくようになります。</p>
	<p><input name="section_anchor" value="#{h @conf.section_anchor}" size="40"></p>
	<h3 class="subtitle">ツッコミアンカー</h3>
	<p>読者からのツッコミの先頭に挿入される、リンク用のアンカー文字列を指定します。なお「&lt;span class="canchor"&gt;_&lt;/span&gt;」を指定すると、テーマによっては自動的に画像アンカーがつくようになります。</p>
	<p><input name="comment_anchor" value="#{h @conf.comment_anchor}" size="40"></p>
	<h3 class="subtitle">日付フォーマット</h3>
	<p>日付の表示部分に使われるフォーマットを指定します。任意の文字が使えますが、「%」で始まる英字には次のような特殊な意味があります。「%Y」(西暦年)、「%m」(月数値)、「%b」(短月名)、「%B」(長月名)、「%d」(日)、「%a」(短曜日名)、「%A」(長曜日名)。</p>
	<p><input name="date_format" value="#{h @conf.date_format}" size="30"></p>
	<h3 class="subtitle">最新表示の最大日数</h3>
	<p>最新の日記を表示するときに、そのページ内に何日分の日記を表示するかを指定します。</p>
	<p>最大<input name="latest_limit" value="#{h @conf.latest_limit}" size="2">日分</p>
	<h3 class="subtitle">長年日記の表示</h3>
	<p>長年日記を表示するためのリンクを表示するかどうかを指定します。</p>
	<p><select name="show_nyear">
		<option value="true"#{" selected" if @conf.show_nyear}>表示</option>
		<option value="false"#{" selected" unless @conf.show_nyear}>非表示</option>
	</select></p>
	HTML
end

add_conf_proc( 'timezone', '時差調整', 'update' ) do
	saveconf_timezone

	<<-HTML
	<h3 class="subtitle">時差調整</h3>
	<p>更新時、フォームに挿入される日付を時間単位で調整できます。例えば午前2時までは前日として扱いたい場合には「-2」のように指定することで、2時間分引かれた日付が挿入されるようになります。また、この日付はWebサーバ上の時刻になっているので、海外のサーバで運営している場合の時差調整にも利用できます。</p>
	<p><input name="hour_offset" value="#{h @conf.hour_offset}" size="5"></p>
	HTML
end

@theme_location_comment = "<p>ここにないテーマは<a href=\"http://www.tdiary.org/20021001.html\">テーマ・ギャラリー</a>から入手できます。</p>"
@theme_thumbnail_label = "サムネイル"

add_conf_proc( 'theme', 'テーマ選択', 'theme' ) do
	saveconf_theme

	r = <<-HTML
	<h3 class="subtitle">テーマの指定</h3>
	<p>日記のデザインをテーマ、もしくはCSSの直接入力で指定します。ドロップダウンメニューから「CSS指定→」を選択した場合には、右の欄にCSSのURLを入力してください。</p>
	<p>
	<select name="theme" id="theme_selection">
		<option value="">CSS指定→</option>
	HTML
	r << conf_theme_list
end

add_conf_proc( 'comment', 'ツッコミ', 'tsukkomi' ) do
	saveconf_comment

	<<-HTML
	<h3 class="subtitle">ツッコミの表示</h3>
	<p>読者からのツッコミを表示するかどうかを指定します。</p>
	<p><select name="show_comment">
		<option value="true"#{" selected" if @conf.show_comment}>表示</option>
		<option value="false"#{" selected" unless @conf.show_comment}>非表示</option>
	</select></p>
	<h3 class="subtitle">ツッコミリスト表示数</h3>
	<p>最新もしくは月別表示時に表示する、ツッコミの最大件数を指定します。なお、日別表示時にはここの指定にかかわらずすべてのツッコミが表示されます。</p>
	<p>最大<input name="comment_limit" value="#{h @conf.comment_limit}" size="3">件</p>
	<h3 class="subtitle">1日あたりのツッコミ最大数</h3>
	<p>1日に書き込めるツッコミの最大数を指定します。この数を超えると、ツッコミ用のフォームが非表示になります。なお、TrackBackプラグインを入れている場合には、ツッコミとTrackBackの合計がこの制限を受けます。</p>
	<p>最大<input name="comment_limit_per_day" value="#{h @conf.comment_limit_per_day}" size="3">件</p>
	HTML
end

add_conf_proc( 'csrf_protection', 'CSRF(乗っ取り)対策', 'security' ) do
	err = saveconf_csrf_protection
	errstr = ''
	case err
	when :param
		errstr = '<p class="message">不正な組み合わせです。変更されませんでした。</p>'
	when :key
		errstr = '<p class="message">鍵が空です。変更されませんでした。</p>'
	end
	csrf_protection_method = @conf.options['csrf_protection_method'] || 1
	<<-HTML
	#{errstr}
	<p>クロスサイト・リクエストフォージェリ(CSRF)の対策手法を設定します。</p>
	<p>CSRF攻撃は、悪意のある人間がWebページに罠を仕掛けます。
	その罠を仕掛けたページをあなたが閲覧すると、あなたのブラウザは
	tDiaryに偽の書き込み要求を送出してしまいます。あなたのブラウザが
	偽要求を送出してしまうため、暗号化・パスワード保護だけでは対策になりません。
	tDiaryでは、この種の攻撃に対して、「Refererチェック」と「CSRFキー」という
	2種類の防衛手段を用意しています。</p>
	<div class="section">
	<h3 class="subtitle">Refererチェックによる防衛</h3>
	<h4>Refererの正当性の検査</h4>
	<p>#{if [0,1,2,3].include?(csrf_protection_method) then
            '<input type="checkbox" name="check_enabled2" value="true" checked disabled>
            <input type="hidden" name="check_enabled" value="true">'
          else
            '<input type="checkbox" name="check_enabled" value="true">'
        end}する(標準)
	</p>
	<p>あなたのブラウザが送出するReferer(リンク元情報)を検査します。
	書き込み要求が正しいページから送出されたことを確認することで、
	偽ページからの要求を防ぎます。不正なページからの要求を検出した場合、
	更新リクエストを拒否します。
	この設定画面では、無効にすることは出来ません。</p>
	<h4>Refererを送出しないブラウザを拒否</h4>
	<p><input type="radio" name="check_referer" value="true" #{if [1,3].include?(csrf_protection_method) then " checked" end}>する(標準)
	<input type="radio" name="check_referer" value="false" #{if [0,2].include?(csrf_protection_method) then " checked" end}>しない
	</p>
	<p>ブラウザからRefererが送られてこなかった場合の動作を指定します。</p>
	<p>標準では、Refererが送出されない場合、不正なリクエストを
	判別できないため、書き込み・設定変更を拒否します。
	あなたのブラウザがRefererを送出しない設定の場合、
	この設定が「する」になっていると、正規の書き込み要求も拒否してしまいます。
	ブラウザを設定を変更しRefererを送出するようにしてください。
	どうしてもRefererを送出する設定に出来ない場合、「しない」にしてください。
	この場合、Refererが全く送出されなかった場合にも、
	書き込み・設定変更を許すようになりますが、
	CSRFによる攻撃と区別できなくなりますので、必ず次の「CSRF防止キー」の
	設定と併用して下さい。</p>
	</div>
	<div class="section">
	<h3 class="subtitle">CSRF防止キーによる防衛</h3>
	<h4>CSRF防止キーの検査</h4>
	<p><input type="radio" name="check_key" value="true" #{if [2,3].include?(csrf_protection_method) then " checked" end}>する
	<input type="radio" name="check_key" value="false" #{if [0,1].include?(csrf_protection_method) then " checked" end}>しない(標準)
	</p>
	<p>書き込みフォームに偽装書き込み防止のためのキーを設定し、CSRFを防ぎます。
	偽ページが秘密のキーを知らない限り、
	偽の書き込み要求を生成することができなくなります。
	この検査を「する」にすると、システムが鍵を自動的に生成、設定します。
	上の設定と両方「しない」にすることはできません。</p>
	<p>この設定を「する」にした場合、この機構に対応していない一部の
	プラグインが動作しなくなることがあります。</p>
	#{"<p class=\"message\">注意:
	あなたのブラウザは現在Refererを送出していないようです。
	<a href=\"#{h @conf.update}?conf=csrf_protection\">このリンクからもう一回
	このページを開いてみて下さい</a>。
	それでもこのメッセージが出る状況では、この設定を変える場合、
	一時的にRefererを送出する設定にするか、
	直接tdiary.confを編集して下さい。</p>
	" if [1,3].include?(csrf_protection_method) && ! @cgi.referer && !@cgi.valid?('referer_exists')}
	</div>
	HTML
end

add_conf_proc( 'logger', 'ログレベル選択', 'basic' ) do
	saveconf_logger

	r = <<-HTML
	<h3 class="subtitle">ログレベルの設定</h3>
	<p>tDiaryが出力するログレベルを指定します。spam フィルタのログ記録を利用する場合は INFO または DEBUG に指定して下さい。</p>
	<p><select name="log_level">
	HTML
	r << conf_logger_list
end

add_conf_proc( 'recommendfilter', 'おすすめフィルタ', 'basic' ) do
	saveconf_recommendfilter

	<<-HTML
	<h3>おすすめフィルタの利用</h3>
	<p>spam 対策をtDiaryおすすめの設定に変更します。現在、設定されている内容を全て変更するので注意してください。</p>
	<p>
		<input type="checkbox" id="recommend.filter" name="recommend.filter" value="true">
		<label for="recommend.filter">おすすめフィルタ設定にする</label>
	</p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
