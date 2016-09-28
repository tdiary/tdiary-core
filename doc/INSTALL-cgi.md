tDiaryのインストール (CGI環境)
==============================

一般的なCGIの実行を許可しているISPやレンタルサーバ上で利用する場合を想定し、以下のような環境を例に説明します。

  - WWWサーバ: Apache 2.x
  - ユーザ名: foo
  - 日記のURL: `http://www.hoge.example.org/~foo/diary/`
  - 上記URLのパス: `/home/foo/public_html/diary`

## tDiaryの取得

tDiaryのダウンロードサイトから、配布アーカイブを取得します。
  
 - [tDiary.org - ダウンロード](http://www.tdiary.org/20021112.html)

### 【補足】 tDiaryをGitHubから取得する場合

開発版を使いたい、更新を楽にしたいという理由でtDiaryをGitHubから取得して利用する場合は、外部ライブラリ (hikidocなど) を手動でインストールする必要があります。以降の手順に沿って、ライブラリをインストールしてください。

配布アーカイブから取得する場合は、外部ライブラリは同梱されているため、この手順は不要です。

まず、外部ライブラリの取得に必要となるBundlerインストールします。

```
% gem install bundler
```

次に、gitコマンドでtDiaryのソースコードを取得した後に、 `bundle install` コマンドを実行して外部ライブラリをインストールします。

```
% git clone git://github.com/tdiary/tdiary-core.git tdiary
% cd tdiary
% bundle install --without development
```

## CGIスクリプトの設定

配布アーカイブを展開し、中身をすべて`/home/foo/public_html/diary`にコピーします。以下の2つのファイルがCGIスクリプト本体なので、WWWサーバの権限で実行可能なようにパーミッションを設定してください。

  - index.rb
  - update.rb

また、/usr/bin/envを使った起動ができない環境では、各ファイルの先頭を、rubyのパスに書き換える必要があるでしょう。ISPのホームディレクトリにこっそりRubyを入れたような場合を除き、通常はあまり気にしなくても良いはずです。

## .htaccessの作成

続いて、CGIの実行環境を整えます。dot.htaccessを.htaccessにリネームして、環境に合わせて書き換えます。添付のサンプルは以下のようになっています。

```
Options +ExecCGI
AddHandler cgi-script .rb
DirectoryIndex index.rb

<Files "*.rhtml">
   deny from all
</Files>

<Files "tdiary.*">
   deny from all
</Files>

<Files update.rb>
AuthName      tDiary
AuthType      Basic
AuthUserFile  /home/foo/.htpasswd
Require user  foo
</Files>
```

ここでは、

  - CGIの実行を可能にし、
  - サフィックス「.rb」のファイルをCGIと認識させ、
  - index.rbをデフォルトのファイルに設定し、
  - `*.rhtml`と`tdiary.*`のファイルの参照を禁止して、
  - update.rbへのアクセスにはユーザ認証が必要

という設定になっています。とりあえず書き換えが必要なのは、AuthUserFileとRequire userでしょう。意味はWebででも調べて下さい。AuthUseFileは、あらかじめhtpasswdコマンドで作成しておく必要があります(これもWebで調べればわかります)。

また、利用するWWWサーバの設定が、CGIの実行ファイルのサフィックスを固定(例:.cgi)にしている場合があります。この場合、AddHandlerやDirectoryIndexも変更する必要があるでしょう。これに応じて、index.rbやupdate.rbのファイル名も変更する必要があります。
