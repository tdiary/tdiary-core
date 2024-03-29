インストールマニュアル
======================

tDiaryの設置
------------

tDiaryは様々な環境で動作します。それぞれの環境にあわせた設置手順を参照してください。

 - 独自サーバ、VPSサーバなどのRack環境 … [INSTALL-rack.md](INSTALL-rack.md)
 - Heroku、SqaleなどのPaaS環境 … [INSTALL-paas.md](INSTALL-paas.md)
 - レンタルサーバなどのCGI環境 … [INSTALL-cgi.md](INSTALL-cgi.md)

tDiaryの設定
------------

### tdiary.confの作成

tDiaryの設定ファイルであるtdiary.confを作ります。

初めてtDiaryをインストールする人には、付属のtdiary.conf.beginnerを使うのがオススメです。最初に使えるようにしておくと良いプラグインがあらかじめONになっていたり、spamフィルタにある程度の設定がされているなど、インストールしてすぐに使いやすい状態になっています。

tdiary.conf.beginnerをtdiary.confにリネームして、内容を書き換えます。tDiaryの設定はほとんどWebブラウザ経由で行えます。ただし、`@data_path`は必要に応じて最初に書き換えてください。

```
@data_path = 'data'
```

`@data_path`は、日記のデータを保存するディレクトリです。ほとんどのレンタルサーバで使われているApache HTTPサーバ向けには、このディレクトリをWWWサーバ経由で参照されないように.htaccessファイルによるアクセス制御を設定済みです。他のWebサーバを使用する場合には、WWWサーバ経由でアクセスできない(`public_html`配下でない)ディレクトリを指定するか、アクセス制御を設定してください。また、このディレクトリはWWWサーバの権限で書き込めるパーミッションにしておく必要があります。

tdiary.confには、他にもいろいろな設定項目を記述できます。これらの項目には以下の3つの種類があります。

tDiary は日記データのキャッシュを PStore ファイルとして保存しますが、設定を変えることによりより高速な memcached を使用することも可能です。memcached をキャッシュの保存先として使用する場合は tdiary.conf を以下のように変更します。

```
# 以下の行をコメントアウト
# require 'tdiary/cache/file'
require 'tdiary/cache/memcached'
require 'tdiary/io/default'
@io_class = TDiary::IO::Default
```

同様に redis を使用する場合は tdiary.conf を以下のように変更します。

```
# 以下の行をコメントアウト
# require 'tdiary/cache/file'
require 'tdiary/cache/redis'
require 'tdiary/io/default'
@io_class = TDiary::IO::Default
```

#### CGIで設定できない項目

`@data_path`のように、CGIでは設定できない項目です。これらの項目は、tdiary.confファイルを直接編集して変更しなければいけません。

#### CGIで設定できる項目

変更画面のメニューにある「設定」を開くと、ブラウザからtDiaryの設定を変更できます。ほとんどの項目はここから設定できるので、わざわざtdiary.confを手で書き換える必要はありません。

#### CGIで追加設定できるが、標準設定を記述できる項目

tdiary.confに記述しておくことで、CGIの設定画面からは編集できないが追加はできるといった設定をできる項目があります(リンク元記録除外や、リンク元変換表)。あらかじめtdiary.confに記述しておくことで、複数の人が同一サーバ上でtDiaryを使うような場合に手間を省くことができます。

各々の項目については、tdiary.conf.sampleの説明を読んでください。一般的な使用では、`@data_path`だけを正しく設定すれば、あとはブラウザから変更が可能です。

また、サフィックス.rbのファイルをCGIスクリプトとして指定できない環境では、index.rbやupdate.rbのファイル名を変更する必要がありますが、この変更をtDiaryに教えるために、@indexや@updateという変数が用意されています。環境によってはこれも指定する必要があるでしょう。

tdiary.confの設定が終わったら、http://www.hoge.example.org/~foo/diary/にアクセスしてみましょう。からっぽの日記ページが出れば設定は正しいです。不幸にして「Internal Server Error」が出てしまったら、Apacheのエラーログを参照して間違った設定を修正してください。

tDiaryの実行
------------

### 日記の更新

ページの先頭には、「トップ」「更新」の2つのリンクがあります。「トップ」は`@index_page`で指定した表紙へ、「更新」は日記を更新するフォームへ移動します。もし「更新」をクリックした時、認証ダイアログが出なかったら、.htaccessの記述が正しくない可能性があります。

更新ページの先頭にもメニューがあります。一番右端に「設定」が増えているでしょう。ここをクリックすると、設定用のページが開きます。詳しくはを参照してください。

更新ページには、日記の日付とその日のタイトル、本文を入力するフォームがあります。日付、タイトル、本文を入力して「追加」ボタンを押すと、その日の日記に追加されます。タイトルと本文はどちらも省略可能です。追加なので、一日に何度も日記を書く場合に、わざわざ以前のデータを呼び出す必要はありません。また、すでにタイトルが指定されている場合、タイトルを入力しなければ以前指定したものが使われます。

フォームで日付を入力して「この日付の日記を編集」ボタンを押すと、(その日の日記がすでに存在すれば)タイトルと本文に過去の日記のデータが読み込まれます。この時、フォームの最後のボタンは「登録」になります(つまり、追加ではありません)。

日記本文には日記向けに少し特殊化したHTMLを使います。多少癖があって人によってはなかなか馴染めないことがあるようなので、[日記の書き方](HOWTO-write-tDiary.md)には必ず目を通して下さい。

### 日記の設定

更新画面で「設定」をクリックすると、設定画面になります。ここではtDiaryのさまざまな設定項目をブラウザから設定できます。各項目の説明は画面中に記述してありますから、それを参考にいろいろと設定を変えてみてください。また、ページ中には利用しやすくするために「OK」ボタンがたくさん置いてありますが、すべて同じものです。つまり、どの「OK」を押してもすべての項目が保存されます。

なお、この設定画面で行った変更は、`@data_path`で指定したディレクトリに別のtdiary.confとして保存されます(初期設定時に手動で書き換えたtdiary.confではありません)。このファイルは、元のtdiary.confのあとに読み込まれるので、設定の内容はブラウザから指定したものが優先されます(ただし、元のtdiary.conf中の設定を変えることで、読み込むタイミングは変更できます)。

### 日記の参照

日記の参照には、最新、月別、日別の3種類のモードがあります。デフォルトページは最新です。月別は、ページの最初の方に出るカレンダーをクリックすると参照できます。また、日別は日付をクリックすると参照できます。

最新・月別と日別には、表示される内容に違いがあります。最新・月別では「本日のツッコミ」「本日のリンク元」が省略されて表示されるのに対し、日別ではすべて表示されます。また、日別にはツッコミ用のフォームがあります。ツッコミをしてもらいたかったら、読者を日別ページに誘導するように、ヘッダ(@header)を工夫する必要があるかも知れません。

月、日、セクション、ツッコミには、それぞれアンカーがあり、他の場所からリンクできるようになっています。それぞれのアンカーはリンクにもなっているので、そこにポインタを合わせることで、そのURLを知ることができます。

携帯端末からの参照ではデータ量に制限があるため、上記の機能はほとんど使えません。最新は最新日付の日記だけが表示され、前日・翌日へ移動できるだけです。ただし、すべてのページにツッコミ用フォームが付いているので、ツッコミを入れることは可能です。

### プラグインによるカスタマイズ

tDiaryにはプラグインと呼ばれる機能があります。プラグインを追加することで、tDiaryの機能を増やしたり、変更したりすることが可能です。プラグインについての詳しい説明は、[HOWTO-use-plugin.md](HOWTO-use-plugin.md)(使い方)・[HOWTO-make-plugin.md](HOWTO-make-plugin.md)(作り方)を参照してください。

### あとは……

日記をつけ続けるだけです(これが一番難しい:-)。Have fun!!

著作権、サポートなど
--------------------

tDiary本体は、原作者であるただただし(t@tdtds.jp)が、GPL2ないしその後継ライセンスの元で配布、改変を許可するフリーソフトウェアです。

また、tDiaryフルセットに付属するテーマ、プラグインはすべて、それぞれの原作者が著作権を有します。ライセンス等に関しては個々のファイルを参照してください。

tDiaryは[tDiary.org](http://www.tdiary.org/)でサポートを行っています。ご意見・ご要望はこちらへどうぞ。パッチ歓迎です。

