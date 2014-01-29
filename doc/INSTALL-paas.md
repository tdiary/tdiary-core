Install to PaaS
=====================

概要
--

tDiary-3.1.3 以降のバージョンでは tDiary を [Heroku](http://www.heroku.com) や [sqale](http://sqale.jp) のような PasS で動かすことが可能です。PaaS を利用することで、3.1.3 以前のバージョンで必要とされていた Apache のような http サーバーの用意や CGI として動作させるための環境設定を行う事なく、 tDiary を動かして日記を書くことが可能となります。

必要なもの
-----

tDiary を PaaS で動作させるためには以下のツールが必要となります。

  - [git](http://git-scm.com)
  - Ruby 1.9.2 以降
  - RubyGems 1.3.7 以降
  - Bundler 1.0.0 以降

また、よくわからない場合は Heroku が配布している [heroku toolbelt](https://toolbelt.heroku.com) を用いると簡単に上記のツールをインストールすることができます。

動かし方 - Heroku の場合
----

tDiary の最新版を取得します。

```
git clone git://github.com/tdiary/tdiary-core.git
```

続いて、依存するライブラリをインストールするために bundle install コマンドを実行します。

```
% cd tdiary-core
% bundle install
```

heroku コマンドを用いて Heroku でアプリケーションを作成します。なお、Heroku のアカウント作成方法は本ドキュメントでは省略します。tDiary のルートディレクトリ(Gemfile が存在する箇所) で以下のコマンドを実行します。

```
% heroku apps:create [アプリケーション名]
```

アプリケーション名には mydiary など任意の名前を英数字で入力します。続いて、Heroku 専用の作業ブランチを作成します。

```
% git checkout -b deploy
```

作業ブランチで Heroku で動かすために必要な設定ファイルをコピーします。

```
% cp misc/paas/heroku/* .
```

続いて .gitignore の 2 行目の .htpasswd と 9 行目の tdiary.conf を削除します。

日記更新時に必要となるユーザー名とパスワードを保存する .htpasswd ファイルを作成します。この情報は重要なので、外部には公開しないでください。

```
% bundle exec rake auth:password:create
```

ここまでの変更内容を deploy ブランチにコミットし、Heroku にアプリケーションを転送します。

```
git add .
git commit -m "deploy"
git push heroku deploy:master
```

これで http://mydiary.herokuapp.com にアクセスして日記を書くことができます。

動かし方 - sqale の場合
----

tDiary の最新版を取得します。

```
git clone git://github.com/tdiary/tdiary-core.git
```

続いて、依存するライブラリをインストールするために bundle install コマンドを実行します。

```
% cd tdiary-core
% bundle install
```

sqale.jp にアクセスして新しいアプリケーションを作成します。作成後にアプリケーションの URL を git のリモートリポジトリに追加します。tDiary のルートディレクトリ(Gemfile が存在する箇所) で以下のコマンドを実行します。

```
% git remote add sqale ssh://sqale@gateway.sqale.jp:2222/[username]/[application].git
```

username と application の値は別途読み替えてください。続いて、sqale 専用の作業ブランチを作成します。

```
% git checkout -b deploy
```

作業ブランチで Sqale で動かすために必要な設定ファイルをコピーします。

```
% cp misc/paas/sqale/* .
```

続いて .gitignore の 2 行目の .htpasswd と 9 行目の tdiary.conf を削除します。

日記更新時に必要となるユーザー名とパスワードを保存する .htpasswd ファイルを作成します。この情報は重要なので、外部には公開しないでください。

```
% bundle exec rake auth:password:create
```

dot.env ファイルを .env にリネームして、データベースの接続情報を記入します。データベースの接続情報は sqale のアプリケーションダッシュボードから参照してください。接続情報は以下の形式で記入します。

```
DATABASE_URL=mysql2://username:password@hostname/database
```

sqale では javascript や css ファイルを作業ディレクトリの public/assets 配下に置く必要があります。以下のコマンドを実行して対象のファイルをコピーしてください。

```
% bundle exec rake assets:copy
```

ここまでの変更内容を deploy ブランチにコミットし、Heroku にアプリケーションを転送します。

```
git add .
git commit -m "deploy"
git push sqale deploy:master
```

これで http://application-username.sqale.jp にアクセスして日記を書くことができます。

### サーバーの選択

Sqale用の`Procfile`（`misc/paas/sqale/Procfile`）ではThinというサーバーを設定していますが、このファイルを書き換えることで他のサーバーでtDiaryを動かすこともできます。
指定できるサーバーと設定方法の詳細は、Sqaleの[マニュアル](https://sqale.jp/support/manual/change-web-server)を参照してください。

また、SqaleデフォルトのUnicornで動かしたい場合は、`Procfile`を削除してください。

```
git rm Procfile
```

独自のテーマファイルを使う方法
----

Heroku で自作や tdiary-theme に含まれるテーマファイルを用いるには、deploy 対象としてテーマファイルを登録し、Heroku に転送する必要があります。

tdiary-core の deploy ブランチに切り替えます。

```
git checkout deploy
```

テーマファイルをコピーし、deploy 対象として登録します。

```
cp -rf ~/tdiary-theme/gustav theme
git add .
git commit -m "add theme file"
```

Heroku にファイルを転送します。

```
git push heroku deploy:master
```

これで tDiary on Heroku の設定画面よりコピーしたテーマファイルを選択できるようになります。

memcache アドオンを使う方法 - Heroku の場合
----

Heroku で アドオンの追加・削除を行うことが出来るユーザーは memcache アドオンを使うことで、より高速に日記キャッシュデータを扱えるようになります。tDiary on Heroku で memcache アドオンを使う方法を以下に解説します。

tdiary-core の deploy ブランチに切り替えます。

```
git checkout deploy
```

heroku コマンドを用いて memcache アドオンを有効にします。

```
heroku addons:add memcache
```

Gemfile の以下の行を有効にします。

```
gem 'dalli'
```

tdiary.conf を以下のように変更します。

```
# require 'tdiary/io/cache/file'
# To use memcache addon
require 'tdiary/io/cache/memcached'
```

この状態を Heroku に反映させます。

```
git add .
git commit -m "enable memcache"
git push heroku deploy:master
```

git push コマンドが完了すると memcached をキャッシュの保存先とした tDiary が利用可能となります。
