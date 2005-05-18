=begin

= IOクラスの作り方

== 概要
tDiaryは、保存形式や日記記述フォーマットを差し替えることができます。
保存形式はIOクラスと呼ばれるTDiary::IOBaseクラスを継承したクラスを実
装することで変更可能です。また、記述フォーマットはDiaryBaseモジュー
ルをincludeしたクラスで実装します。このドキュメントでは、これらの実
装に関する解説を行います。

== IOクラス
保存形式を変更する新たなクラスを作成し、tdiary.confで指定することで、
tDiary独自の保存形式と違う、独自の保存形式を選択できます。例えばDBMS
に日記データを保存する等、異なる運用のtDiaryを作ることが可能です。こ
れを実現するための仕組みを総称して「IOクラス」と呼んでいます(RubyのIO
クラスとは違います)。

=== IOBaseクラス
tdiary.rbにはTDiary::IOBaseというクラスが定義されており、これを継承
して独自のIOクラスを作成します。下記の例は、HogeIOを定義しています。

 class HogeIO < TDiary::IOBase
    def clendar
       ......
    end

    .....
 end

=== 最低限実装すべきもの
IOBaseクラスにはIOクラスに共通ないくつかのメソッドがすでに実装してあ
ります。これを継承したIOクラスでは、さらに以下のようなメソッドを実装
しなくてはいけません。

==== calendar
tDiaryに、日記が存在する年月を通知するためのメソッドです。実行時にtDiary
から呼び出されます。

返り値には、現在利用できる日記が含まれている年・月を、Hashオブジェク
トで返します。Hashに含まれている各値は、キーに西暦年(Stringで4文字)、
対応する値にはArrayで月(Stringで2桁)を設定します。以下に例を示します。

 def calendar
    return {
       '2001' => ['12'],
       '2002' => ['01', '02', '03', '04', '05', '08']
    }
 end

==== transaction( date )
指定された月の日記データを読み込み、tDiaryに理解できる形で渡します。

引数dateはTimeオブジェクトで、年と月のみがlocaltimeで与えられます。

transactionメソッドはdateで指定された月の日記データをファイル(または
その他の媒体)から読み出して、ブロックパラメタとしてtDiaryに返します。
このブロックパラメタはHashで、キーに年月日(Stringで8桁)、値に日記デー
タ(後述するDiaryBaseをincludeしたクラスのインスタンス)を持ちます。

ブロックパラメタを受けとったtDiaryは、それを使って日記を表示または更
新するので、transactionメソッドはその返り値に従って日記を保存する等
の処理を行えます。以下にtDiaryからの返り値を示します。実際にはこれら
の論理和が返ります。

* TDiary::TDiaryBase::DIRTY_NONE: 日記データに変更はありませんでした
* TDiary::TDiaryBase::DIRTY_DIARY: 日記本文に変更がありました
* TDiary::TDiaryBase::DIRTY_COMMENT: ツッコミに変更がありました
* TDiary::TDiaryBase::DIRTY_REFERER: リンク元に変更がありました

以下にtransactionの例を示します。

 def trasaction( date )
    diaries = { ... } # restore data
    dirty = yield( diaries )
    if dirty & TDiary::TDiaryBase::DIRTY_DIARY != 0 then
       ... # saving diary data
    if dirty & TDiary::TDiaryBase::DIRTY_COMMENT != 0 then
       ... # saving comment data
    if dirty & TDiary::TDiaryBase::DIRTY_REFERER != 0 then
       ... # saving referer data
    end
 end

==== diary_factory( date, title, body, style = 'tDiary' )
diary_factoryは、指定されたフォーマットの日記オブジェクトを生成して
返します。

引数dateは日付(Stringで8桁)を指定します。title、bodyはそれぞれ生成す
る日記のタイトルと本文です(String)。styleは日記の記述形式を指定する
文字列で、diary_factoryに依存します。

返り値はDiaryBaseをincludeした継承したクラスのオブジェクトです。

以下にdiary_factoryの例を示します。

 def diary_factory( date, title, body, style = 'tDiary' )
    case style
    when 'tDiary'
       DefaultDiary::new( date, title, body )
    default
       raise StandardError, 'bad style'
    end
 end

もし、スタイルに対応したIOクラスを作るなら、initializeでload_styleを
呼んだ上で、以下のようにstyled_diary_factoryを呼ぶだけで良いです。

 def diary_factory( date, title, body, style = 'tDiary' )
 	styled_diary_factory( date, title, body, style )
 end

== 日記データ
続いて、IOクラスのtransactionメソッドの返り値に含まれる日記データが
満たすべき条件について述べます。
日記データの具体例としては tdiary/tdiary_style.rb で定義されている
TDiary::DefaultDiary を参照してください。

「日記データ」は以下の要素から構成されています。

* 日付
* タイトル
* 最終更新日
* 0個以上のセクション
* 0個以上のツッコミ
* 0個以上のリンク元

さらに「セクション」は以下の要素から構成されています。

* サブタイトル
* 著者
* 本文

日記のデータ構造がこれと完全に同一である必要はなく、日記データが付加
的なデータを持ったり、
セクションがいくつかのサブセクションに分かれたりしても良いです。

== カテゴリ機能について
カテゴリ機能とは、日記中のセクションにキーワードを付けて、
あとで同じキーワードをまとめて一覧できる機能のことです。

セクションのカテゴリは、サブタイトル中で指定します。
tDiaryスタイルでは

  [カテゴリ] サブタイトル

のようにカテゴリを指定することにしていますが、
IOクラス/スタイル作者が各IOクラス/スタイルに適した
カテゴリ指定の文法を定義して下さい。

カテゴリ機能の実装は必須ではありません。
日記データをカテゴリ機能に対応させるかどうかはIOクラスの作者が判断して下さい。

== 日記データのクラス
日記データからはその日付、タイトル、最終更新日、日記本文、
コメント、Referer、セクションなどを参照できる必要があります。

もし、この日記データをスタイルとして設計するのであれば、IOクラスとは
分離して、別のファイルにする必要があります。この場合、スタイル名と
ファイル名、日記データクラス名には強い依存性があります。「Hoge」という
スタイルを作る場合、以下のように作る必要があります。

* スタイル名: Hoge
* ファイル名: hoge_style.rb
* クラス名　: TDiary::HogeDiary (スタイル名.capitalize + 'Diary')

=== DiaryBaseモジュール
tdiary.rbにはDiaryBaseというモジュールが定義されており、
日記データのクラスはこのモジュールをincludeしなければなりません。

下記の例はHogeDiaryにDiaryBaseをincludeしています。

   class HogeDiary
     include DiaryBase

     .....
   end

=== CategorizableDiary/UncategorizableDiaryモジュール
tdiary.rbにはCategorizableDiaryとUncategorizableDiaryというモジュールが定義されています。
日記データのクラスは、カテゴリ機能に対応している場合はCategorizableDiaryモジュールを、
カテゴリ機能に対応していない場合はUncategorizableDiaryモジュールを
includeしなければなりません。

下記の例はHogeDiaryにCategoriabeleDiaryをincludeしています。

   class HogeDiary
     include CategorizableDiary

     .....
   end

=== 最低限実装すべきもの
DiaryBaseモジュールには日記データのクラスに必要な幾つかのメソッドが
定義されています。DiaryBaseで定義されているメソッド以外に
日記データのクラスが備えるべきメソッドは下記のものになります。
(ここでいうメソッドは Public Instance Method のことです。)

* initialize
* replace
* append
* each_section
* to_html
* to_src
* style

メソッドではありませんが、 インスタンス変数の @last_modified には気をつけましょう。
日記データに変更があった場合に @last_modified に適切なTimeオブジェクトを設定しないと、
キャッシュの更新がうまくいきません。

* @last_modified

==== initialize
日記データを初期化します。引数はIOクラスによって違うものになります。
このメソッドでは DiaryBase#init_diary を呼ばなくてはなりません。

例
   class HogeDiary
     include DiaryBase
     .....

     def initialize(date, title, body, modified = Time::now)       
       init_diary     
       .....
     end
    
     .....
   end

==== replace(date, title, body)
日記データの日付をdateに、日記本文のソースをbodyに、タイトルをtitleに変更します。
dateはTimeオブジェクト、もしくは、日付をあらわす文字列('YYYYMMDD')です。
日付を表す文字列は具体的には下のようになります。

* '20020831'
* '20010101'

body, titleは文字列です。

日記本文が変更された場合、日記本文を解釈し直す必要があります。
解釈し直す時には日記データを構成するセクションも変更されます。

==== append(body, author = nil)
日記本文を追加します。bodyは追加される日記本文です。
authorは日記を記述した人の名前で、文字列です。
authorの引数はデフォルトでnilにしなければなりません。

日記本文が変更された場合、日記本文を解釈し直す必要があります。
解釈し直す時には日記データを構成するセクションも変更されます。

==== each_section 
each_section は各セクションをブロックパラメータとして返します。

下に一例を示します。ここで@sectionsはセクションを保持するArrayのオブジェクトです。

  class HogeDiary
    .....

    def each_section
      @sections.each |section|
        yield(section)
      end
    end

    .....
  end

==== to_html(opt, mode = :HTML)
日記データをHTMLに変換します。引数optは設定ファイル(tdiary.conf)の内容の一部を
保持するHashオブジェクトです。引数modeはSymbolオブジェクトで、
現在は下記のいずれかです。

* :HTML
* :CHTML

想定しないmodeが指定された場合は、:HTMLが指定されたものとみなして下
さい。:HTMLの場合は通常のブラウザ用にHTMLに、:CHTMLの場合は携帯端末
用にcHTMLに変換しなければなりません。

optの内容によって、日記のリンク先を変更しなければならないので、注意
が必要です。

カテゴリ機能に対応した日記データのクラスでは、
各セクションのサブタイトル中のカテゴリ指定をcategory_anchorプラグインの呼出しに変換して下さい。

==== to_src
日記の本文を返します。

==== style
日記データを記述するスタイル名を返します。
tDiary標準の記述形式の場合は「tDiary」です。
この文字列は、システム上は大小文字を区別しません。


== セクションのクラス
日記本文は幾つかのセクションに分かれます。
セクションは日記本文、セクションのタイトル、セクションを書いた人の名前
などをデータとして保持しています。
セクションクラスの例としては、tdiary/defaultio.rbにある
TDiary::DefaultSectionクラスを参照してください。

=== 最低限実装すべきメソッド
以下にセクションのクラスが実装すべきメソッドを列挙します。

* subtitle
* body
* to_src
* author
* subtitle_to_html
* body_to_html

カテゴリ機能に対応させるには、以下のメソッドを実装する必要があります。

* stripped_subtitle
* stripped_subtitle_to_html
* categories

==== subtitleとsubtitle_to_html
セクションのタイトルを文字列として返します。
タイトルがない場合はnilを返します。

subtitleはスタイルの文法で記述された本文を、subtitle_to_htmlはHTMLに変換後の本文を返します。

==== bodyとbody_to_html
セクションに対応する本文を返します。返り値の文字列にはタイトルも著者も含まれません。
本文がない場合は空文字("")を返します。

bodyはスタイルの文法で記述された本文を、body_to_htmlはHTMLに変換後の本文を返します。

==== to_src
セクションに対応する本文を返します。返り値の文字列にはタイトルと著者が含まれます。
本文がない場合は空文字("")を返します。

==== author
セクションを書いた人の名前を文字列として返します。
書いた人の名前がない場合は nil を返します。

==== stripped_subtitleとstripped_subtitle_to_html
セクションのタイトルからカテゴリ指定部分を取り除いた文字列を返します。
タイトルがない場合や、カテゴリ指定部分を取り除いた文字列が空文字("")の場合は
nilを返します。

stripped_subtitleはスタイルの文法で記述された本文を、stripped_subtitle_to_htmlはHTMLに変換後の本文を返します。

==== categories
セクションのカテゴリを文字列の配列として返します。
タイトル中にカテゴリ指定がない場合は[]を返します。

=end

