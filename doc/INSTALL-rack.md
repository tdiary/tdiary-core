tDiaryのインストール (Rack環境)
============================

## 概要

tDiary-4.0 以降のバージョンは gem に対応しているので、簡単に tDiary を設置出来ます。

## tDiary の取得

gem コマンドで tDiary をインストールします。

```
% gem install tdiary
```

インストールすると、 tdiary コマンドが使えるようになります。ちゃんとインストールできているか、確認してみましょう。以下のようにバージョン番号が表示されればインストール成功です（表示される番号はバージョンにより異なります）。

```
% tdiary version
4.0.0
```

rbenv を使っている場合は忘れずに rehash を実行しておきましょう。

```
% rbenv rehash
```

## tDiary の設置

newコマンドを実行してtdiaryを設置します。インストール先のディレクトリ名を指定します。以下の例では diary ディレクトリにインストールします。

```
% tdiary new diary
      create  diary
      create  diary/public
      (中略)
      create  diary/tdiary.conf
         run  bundle install --without test development from "./diary"
Resolving dependencies...
Using rake (10.1.0)
Using bundler (1.3.5)
(中略)
Using twitter-text (1.6.1)
Your bundle is complete!
Gems in the groups test and development were not installed.
Use `bundle show [gemname]` to see where a bundled gem is installed.
         run  bundle exec tdiary htpasswd from "./diary"
Input your username/password
```

インストール途中で「Input your username/password」と表示され、
更新画面のユーザ認証のために、IDとパスワードを入力します。

```
Username: machu
New password:
Re-type new password:
install finished
run `tdiary server` in diary directory to start server
```

## tDiary の起動と終了

インストール先のディレクトリに移動して、serverコマンドを実行するとtDiaryサーバが起動します。

```
% cd diary
% bundle exec tdiary server
>> Thin web server (v1.5.1 codename Straight Razor)
>> Maximum connections set to 1024
>> Listening on 0.0.0.0:19292, CTRL+C to stop
```

Webブラウザで http://localhost:19292/ にアクセスすると、tDiaryの画面が表示されます。

CTRL+CコマンドでtDiaryサーバを終了します。

```
>> Stopping ...
```

## tDiary の更新

tDiaryのアップデートもgemコマンドを使います。

```
$ gem update tdiary
```

tDiaryの設置ディレクトリに展開されたファイルは、 tdiary updateコマンドを使って更新できます。

```
$ cd [tDiaryの設置ディレクトリ]
$ tdiary update
$ bundle install
```

## 追加のgemを使うには

tDiaryの関連ライブラリは、別のgemになっている場合があります。これらを使いたい場合、Rubyで一般的な`Gemfile`ではなく、`tdiary new`コマンドで作成した先(このドキュメントの場合はdirayディレクトリ)にある`Gemfile.local`に使いたいgemを指定します。例えばBlogKitを使いたい場合には以下のように指定します:

```
gem 'tdiary-blogkit'
```

このあと、`bundle install`をして、指定したgemをインストールします:

```
$ bundle install
```

他にも、日記の保存先をデータベースにするIO系のgem、スタイルを追加するgem、Thin以外のWebサーバを使いたい場合にも`Gemfile.local`に記述します。
