# -*- coding: utf-8 -*-
=begin
= その日の天気プラグイン((-$Id: weather.rb,v 1.13 2008-03-02 09:01:46 kazuhiko Exp $-))
その日の天気を、その日の日記を最初に更新する時に取得して保存し、それぞれ
の日の日記の上部に表示します。

== 入手方法
このファイルの最新版は、
((<URL:http://zunda.freeshell.org/d/plugin/weather.rb>))
にあります。

== 使い方
=== インストールと設定の方法
このファイルをpluginディレクトリにコピーしてください。漢字コードは
EUC-JPです。

次に、tdiary.confを編集するか、WWWブラウザからtDiaryの設定画面から「その
日の天気」を選んで、天気データをいただいてくるURLを設定してください。
tdiary.confを編集する場合には、@options['weather.url']に設定してくださ
い。両方で設定をした場合には、tDiaryの設定画面での設定が優先されます。

例えば、 NOAA National Weather Serviceを利用する場合には、
((<URL:http://weather.noaa.gov/>))から、Select a country...で国名を選ん
でGo!ボタンを押し、次に観測地点を選んでください。その時表示されたページ
のURLを、例えば、
  @options['weather.url'] = 'http://weather.noaa.gov/weather/current/RJTI.html'
と書いてください。この例では東京ヘリポート((-どこにあるんだろ？-))の天気
が記録されます。情報の二次利用が制限されている場合がありますので、そのよ
うなWWWページから情報を取得しないように注意してください。

さらに、将来日記のタイムゾーンが変化する可能性がある方は、今のタイムゾー
ンを、@options['weather.tz']か、環境変数TZに設定しておくことをお勧めし
ます。これによって、日記が引越した後も、天気データ取得時のタイムゾーン
で天気を表示し続けることができます。tdiary.confに設定する場合は、例えば
日本標準時の場合は、
  @options['weather.tz'] = 'Japan'
と設定してください。

これで、新しい日の日記を書く度に、設定したURLから天候データを取得して、
表示するようになるはずです。天気は、
  <div class="weather"><span class="weather">hh:mm現在<a href="取得元URL">天気(温度)</a></span></div>
という形式でそれぞれの日の日記の上に表示されます。必要ならば、CSSを編集
してください。
  div.weather {
    text-align: right;
    font-size: 75%;
  }
などとしておけばいいでしょう。

日記に使用しているWWWサーバーからサーバーの権限でWWWページの閲覧ができる
必要があります。環境変数TZを変更する場合がありますので、secureモードでは
使えません。mod_rubyでの動作は今のところ確認していません。

デフォルトでは、携帯端末から閲覧された場合には天気を表示しないようになっ
ています。携帯からでも天気を表示したい場合には、設定画面から設定するか、
tdiary.confに
  @options['weather.show_mobile'] = true
を指定してください。

=== 保存される天気データについて
天気データは、
* 書いてる日記の日付と現在の日付が一致し、
* その日の天気データがまだ取得されていないか、前回の取得時にエラーがあった
場合に、取得されます。

天気データは、@options['weather.dir']に設定したディレクトリか、
@cache_path/weather/ ディレクトリ以下に、年/年月.weather というファイ ル
名で保存されます。タブ区切りのテキストファイルですので必要に応じて編集
することができます。タブの数を変えてしまわないように気をつけて編集してく
ださい。フォーマットの詳細は、Weather.to_sメソッドを参照してください。

天気データには、データの取得時刻が記録されています。また、データの取得元
から得られた、天気の更新時刻が記録されていることもあります。これらの時刻
は、世界標準時(UNIX時刻)に直されて記録されていて、日記に表示する時に現地
時刻に直しています。このため、天気を記録した時のタイムゾーンと、天気を表
示する時のタイムゾーンが異なってしまうと、例えば朝の天気だったものが夕方
の天気として表示されてしまうことになります。これを防ぐには、例えば、
  @options['weather.tz'] = 'Japan'
というオプションを設定して、データにタイムゾーンを記録するようにしてくだ
さい。tdiary.confなどで、
  ENV['TZ'] = 'Japan'
などとして環境変数TZを設定することでも同様の効果が得られます。環境変数を
設定した場合は、tDiary全体の動作に影響がありますので留意してください。

なお、1.1.2.19かそれ以前のバージョンのweather.rbではタイムゾーンの情報が
天気データに記録されていません。お手数ですが、必要ならば、ファイルを編集
して、タイムゾーン情報を追加してください。記録ファイルは、デフォルトでは、
  .../cache/weather/2003/200301.weather
などにあります。取得元URLの次の数字がUNIX時刻ですので、それに続けて、空
白を一つと、Japanなどタイムゾーンを示す文字列を入力してください。データ
取得時にエラーがなければ、その後２つのタブに続いて、天気のデータが記録さ
れているはずです。

=== オプション
==== 必ず指定が必要な項目
: @options['weather.url']
  天気データを得られるWWWページのURL。
    @options['weather.url'] = 'http://weather.noaa.gov/weather/current/RJTI.html'
  など。情報の二次利用が制限されている場合がありますので、そのようなWWW
  ページから情報を取得しないように注意してください。ブラウザから設定した
  場合はそちらが優先されます。

==== 指定しなくてもいい項目
: @options['weather.show_mobile'] = false
  trueの場合は、携帯端末からのアクセスの場合に、i_html_stringで生成され
  たCHTMLを表示します。falseの場合は、携帯端末からのアクセスの場合には天
  気を表示しません。ブラウザから設定した場合はそちらが優先されます。

: @options['weather.tz']
  データを取得した場所のタイムゾーン。コマンドライン上で例えば、
    TZ=Japan date
  を実行して正しい時刻が表示される文字列を設定してください。Linuxでは、
  /usr/share/zoneinfo以下のファイル名を指定すればいいはずです。ブラウザ
  から設定した場合はそちらが優先されます。このオプションが指定されてい
  ない場合、環境変数TZが設定されていればその値を使用します。そうでなけ
  ればタイムゾーンは記録しません。

  天気データにタイムゾーンが記録されていない場合は、もし将来日記のタイム
  ゾーンが変更された場合に違う時刻を表示することになります。

  日付の判定など、天気データの記録以外の時刻の管理には、日記全体のタイム
  ゾーンが用いられます。

: @options['weather.oldest'] = 21600
  得られたデータが、このオプション(秒)より古い場合には、天気の取得エラー
  になり、次の日記の更新で再びデータを取得しようとします。デフォルトは6
  時間(21600秒)です。このオプションがnilに設定されている場合には、どんな
  に古いデータでも受け入れます。

: @options['weather.show_error']
  データ取得時にエラーがあった場合にそれを日記に表示したい場合にはtrueに
  します。デフォルトでは表示しません。

: @options['weather.dir']
  データの保存場所。デフォルトは以下の通り。
    "#{@cache_path}/weather/"
  この下に、年/年月.weather というファイルが作られます。これを、
  @data_pathと同じにすると、日記のデータと同じディレクトリに天気のデータ
  を保存できるかもしれません。

: @options['weather.items']
  WWWページから取得する項目。デフォルトは、ソースをご覧ください。
  parse_htmlで得られる項目名をキー、記録する項目名を値としたハッシュです。
  www.nws.noaa.govのフォーマットに合わせて、多少の単位の変動には耐えられ
  るようにしてあります。これを変更する場合には、parse_htmlメソッドも編
  集する必要があるかもしれません。

: @options['weather.header']
  HTTPリクエストヘッダに追加する項目のハッシュ
    @options['weather.header'] = {'Accept-language' => 'ja'}
  など。((-Accept-languageによって取得する言語を選べるサイトもあります。-))
  デフォルトでは追加のヘッダは送信しません。

== 天候の翻訳について
NWSからのデータは英語ですので、適当に日本語に直してから出力するようにし
てあります。翻訳は、WeatherTranslatorモジュールによっていて、変換表は、
Weatherクラスに、Words_jaという配列定数として与えてあります。

語彙はまだまだ充分ではないと思います。知らない単語は英語のまま表示されま
すので、Words_jaに適宜追加してください。
((<URL:http://tdiary-users.sourceforge.jp/cgi-bin/wiki.cgi?weather%2Erb>))
に書いておくと、そのうち配布元で追加されるかもしれません。

== 細かい設定
天気データ取得元や好みに合わて、以下のメソッドを変更することで、より柔
軟な設定ができます。

=== 表示に関するもの
: Weather.html_string
  @data[item]を参照して、天気を表示するHTML断片を作ってください。

: Weather.error_html_string
  データ取得エラーがあった場合に、@errorを参照してエラーを表示するHTML断
  片を作ってください。

携帯端末からの閲覧の際には、Weather.i_html_stringが使われます。エラーの
表示はできません。

=== 天気データの取得に関するもの
: Weather.parse_html( html, items )
  ((|html|))文字列を解析して、((|items|))ハッシュに従って@data[item]を定
  義してください。((|items|))には@optins['weather.items']または
  Weather_default_itemsが代入されます。返り値は利用されません。テーブル
  を用いた天気情報源ならば、このメソッドをあまり改造しないで使えるかも
  しれません。

== まだやるべきこと
* 天気に応じたアイコンの表示 -どうやろうか？

== 謝辞
その日の天気プラグインのアイディアを提供してくださったhsbtさん、実装のヒ
ントを提供してくださったzoeさんに感謝します。また、NOAAの情報を提供して
くださったkotakさんに感謝します。

The author appreciates National Weather Service
((<URL:http://weather.noaa.gov/>)) making such valuable data available
in public domain as described in ((<URL:http://www.noaa.gov/wx.html>)).

== Copyright
Copyright 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution,
and distribution of modified versions of this work under the terms
of GPL version 2 or later.
=end

=begin
== Instance variables
=end
@weather_plugin_name = 'その日の天気'

=begin
== Classes and methods
=== WeatherTranslator module
We want Japanese displayed in a diary written in Japanese.

--- Weather::Words_ja
    Array of arrays of a Regexp and a Statement to be executed.
    WeatherTranslator::S.tr accepts this kind of hash to translate a
    given string.
=end
require 'erb'

class Weather
	Words_ja = [
		[%r[\A(.*)/(.*)], '"#{S.new( $1 ).translate( table )}/#{S.new( $2 ).translate( table )}"'],
		[%r[\s*\b(greater|more) than (-?[\d.]+\s*\S*)\s*]i, '"#{S.new( $2 ).translate( table )}以上"'],
		[%r[^(.*?) with (.*)$]i, '"#{S.new( $2 ).translate( table )}ありの#{S.new( $1 ).translate( table )}"'],
		[%r[^(.*?) during the past hours?$]i, '"直前まで#{S.new( $1 ).translate( table )}"'],
		#[%r[\s*\b([\w\s]+?) in the vicinity]i, '"近辺で#{S.new( $1).translate( table )}"'],
		[%r[\s*\bin the vicinity\b\s*]i, '""'],
		# ... in the vicinityは無視されるようになっています。訳語が欲しい方は、
		# 上のコメントアウトされている行のコメントを外してください。
		[%r[\s*\bpatches of\b\s*]i, '""'],
		[%r[\s*\bdirection variable\b\s*]i, '"不定"'],
		[%r[\s*(-?[\d.]+)\s*\(?F\)?], '"華氏#{$1}度"'],
		[%r[\s*\bmile(\(?s\)?)?\s*]i, '"マイル"'],
		[%r[\s*\b(mostly |partly )clear\b\s*]i, '"晴"'],
		[%r[\s*\bclear\b\s*]i, '"快晴"'],
		[%r[\s*\b(mostly |partly )?cloudy\b\s*]i, '"曇"'],
		[%r[\s*\bovercast\b\s*]i, '"曇"'],
		[%r[\s*\blight snow showers?\b\s*]i, '"にわか雪"'],
		[%r[\s*\blight snow\b\s*]i, '"小雪"'],
		[%r[\s*\blight drizzle\b\s*]i, '"小雨"'],
		[%r[\s*\blight rain showers?\b\s*]i, '"弱いにわか雨"'],
		[%r[\s*\bheavy rain showers?\b\s*]i, '"強いにわか雨"'],
		[%r[\s*\bheavy rain\b\s*]i, '"豪雨"'],
		[%r[\s*\b(rain )?showers?\b\s*]i, '"にわか雨"'],
		[%r[\s*\bdrizzle\b\s*]i, '"こぬか雨"'],
		[%r[\s*\blight rain\b\s*]i, '"霧雨"'],
		[%r[\s*\brain\b\s*]i, '"雨"'],
		[%r[\s*\bmist\b\s*]i, '"靄"'],
		[%r[\s*\bhaze\b\s*]i, '"霞"'],
		[%r[\s*\b(partial )?(freezing )?fog\b\s*]i, '"霧"'],
		[%r[\s*\bsnow\b\s*]i, '"雪"'],
		[%r[\s*\bthunder( storm)?\b\s*]i, '"雷"'],
		[%r[\s*\blightning\b\s*]i, '"稲光"'],
		[%r[\s*\bsand\b\s*]i, '"黄砂"'],
		[%r[\s*\bcumulonimbus clouds\b\s*]i, '"積乱雲"'],
		[%r[\s*\bcumulus clouds\b\s*]i, '"積雲"'],
		[%r[\s*\btowering\b\s*]i, '""'],
		[%r[\s*\bobserved\b\s*]i, '""'],
		[%r[\s*\bC\b\s*], '"℃"'],
	].freeze
end

=begin
=== Weather class
Weather of a date.
--- Weather.html_string
--- Weather.error_html_string
      Returns an HTML fragment showing data or error, called from
      Weather.to_html.

--- Weather.i_html_string
      Returns a CHTML fragment to be shown on a mobile browser.
=end
class Weather
	include ERB::Util

	def error_html_string
		%Q|<span class="weather">お天気エラー:<a href="#{h(@url)}">#{h( @error )}</a></span>|
	end

	# edit this method to define how you show the weather
	def html_string
		has_data = false
		r = '<span class="weather">'

		# time stamp
		if @tz then
			tzbak = ENV['TZ']
			ENV['TZ'] = @tz	# this is not thread safe...
		end
		if @data['timestamp'] then
			r << Time::at( @data['timestamp'].to_i ).strftime( '%H:%M' ).sub( /^0/, '' )
		else
			r << Time::at( @time.to_i ).strftime( '%H:%M' ).sub( /^0/, '' )
		end
		r << '現在'
		if @tz then
			ENV['TZ'] = tzbak
		end

		# weather
		r << %Q|<a href="#{h(@url)}">|
		if @data['weather'] then
			r << %Q|<span class="weather">#{h( WeatherTranslator::S.new( @data['weather']).translate( Words_ja ).compact )}</span>|
			has_data = true
		elsif @data['condition'] then
			r << %Q|<span class="condition">#{h( WeatherTranslator::S.new( @data['condition']).translate( Words_ja ).compact )}</span>|
			has_data = true
		end

		# temperature
		if @data['temperature(C)'] and t = @data['temperature(C)'].scan(/-?[\d.]+/)[-1] then
			r << %Q| <span class="temperature">#{sprintf( '%.0f', t )}℃</span>|
			has_data = true
		end

		r << "</a></span>"
		return has_data ? r : ''
	end

	# edit this method to define how you show the weather for a mobile agent
	def i_html_string
		r = ''

		# weather
		if @data['weather'] then
			r << %Q|<A HREF="#{u(@url)}">|
			r << h( WeatherTranslator::S.new( @data['weather']).translate( Words_ja ).compact )
			r << "</A>"
		elsif @data['condition'] then
			r << %Q|<A HREF="#{u(@url)}">|
			r << h( WeatherTranslator::S.new( @data['condition']).translate( Words_ja ).compact )
			r << "</A>"
		end

		return r
	end
end

# www configuration interface
def weather_configure_html( conf )
	station = Weather::extract_station_id(conf['weather.url'])
	station ||= conf['weather.url']
	<<-HTML
	<h3 class="subtitle">その日の天気プラグイン</h3>
	<p>その日の天気を、その日の日記を最初に更新する時に取得して保存し、
		それぞれの日の日記の上部に表示します。</p>
	<h4>天気データ</h4>
	<p>その日の天気を、例えばNOAA National Weather Serviceを利用する場合には、
		<a href="http://weather.noaa.gov/">NOAA National Weather Service</a>
		から、Select a country...で国名を選んでGo!ボタンを押し、
		次に観測地点を選んでください。
		そして、その時表示されたページのURL
		(例えば東京ヘリポートの場合は<tt>http://weather.noaa.gov/weather/current/RJTI.html</tt>となります)
		を、以下に記入してください。
		大文字4文字のStation IDでもかまいません。</p>
	<p><input name="weather.url" value="#{station}" size="50"></p>
	<p>将来日記のタイムゾーンが変化する可能性がある方は、
		今のタイムゾーンを記録しておくことをお勧めします。
		これによって、日記が引越した後も、
		天気データ取得時のタイムゾーンで天気を表示し続けることができます。</p>
	<p>タイムゾーンを記録するには、例えば日本標準時の場合には、
		tdiary.rbと同じディレクトリにあるtdiary.confに、
		ENV['TZ'] = 'Japan'などと書き足すか、
		以下に、Japanと記入してください。</p>
	<p><input name="weather.tz" value="#{conf['weather.tz']}"></p>
	<h4>WWWブラウザへの表示</h4>
	<p>下記から選んでください。</p>
	<p><select name="weather.in_title">
		<option value="false"#{' selected'unless conf['weather.in_title']}>
		本文の上に表示する
		<option value="true"#{' selected'if conf['weather.in_title']}>
		タイトルの横に表示する
	</select></p>
	<h4>携帯電話への表示</h4>
	<p>下記から選んでください。</p>
	<p><select name="weather.show_mobile">
		<option value="true"#{' selected'if conf['weather.show_mobile']}>
		携帯電話にも今日の天気を表示する
		<option value="false"#{' selected'unless conf['weather.show_mobile']}>
		携帯電話には今日の天気を表示しない
	</select></p>
	<h4>検索エンジンなどのロボットへの表示</h4>
	<p>下記から選んでください。</p>
	<p><select name="weather.show_robot">
		<option value="true"#{' selected'if conf['weather.show_robot']}>
		検索エンジンなどのロボットにも今日の天気を知らせる
		<option value="false"#{' selected'unless conf['weather.show_robot']}>
		検索エンジンなどのロボットには今日の天気を知らせない
	</select></p>
	<h4>その他の設定</h4>
	<p>この他にもいくつかtdiary.confから設定できる項目があります。
		詳しくは、プラグインのファイル(weather.rb)をご覧ください。</p>
	HTML
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
