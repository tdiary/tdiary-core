Install to Heroku
=====================

概要
--

tDiary-3.1.3 以降のバージョンでは tDiary を PasS である [heroku](http://www.heroku.com) で動かすことが可能です。Heroku を利用することで、3.1.3 以前のバージョンで必要とされていた Apache のような http サーバーの用意や CGI として動作させるための環境設定を行う事なく、 tDiary を動かして日記を書くことが可能となります。

必要なもの
-----

tDiary を Heroku で動作させるためには以下のツールが必要となります。

  - [git](http://git-scm.com)
  - Ruby 1.8.7 以降
  - RubyGems 1.3.7 以降
  - Bundler 1.0.0 以降

また、よくわからない場合は Heroku が配布している [heroku toolbelt](https://toolbelt.heroku.com) を用いると簡単に上記のツールをインストールすることができます。

動かし方
----

tDiary の最新版を取得します。

```
git clone git://github.com/tdiary/tdiary-core.git
```

heroku コマンドを用いて Heroku でアプリケーションを作成します。なお、Heroku のアカウント作成方法は本ドキュメントでは省略します。tDiary のルートディレクトリ(Gemfile が存在する箇所) で以下のコマンドを実行します。

```
% cd tdiary-core
% heroku apps:create [アプリケーション名]
```

アプリケーション名には mydiary など任意の名前を英数字で入力します。続いて、Heroku 専用の作業ブランチを作成します。

```
% git checkout -b deploy
```

作業ブランチで Heroku で動かすために必要な設定ファイルを変更、または新規作成します。

```
% cp tdiary.conf.heroku tdiary.conf
% cp Gemfile.heroku Gemfile
% cp Gemfile.heroku.lock Gemfile.lock
```

続いて .gitignore の 2 行目の .htpasswd と 9 行目の tdiary.conf を削除します。

日記更新時に必要となるユーザー名とパスワードを保存する .htpasswd ファイルを作成します。この情報は重要なので、外部には公開しないでください。

```
% rake auth:password:create
```

ここまでの変更内容を deploy ブランチにコミットし、Heroku にアプリケーションを転送します。

```
git add .
git commit -m "deploy"
git push heroku deploy:master
```

Heroku にアプリケーションの転送が完了した後に、日記データを保存するデータベースのテーブルを作成します。

```
heroku run rake db:create
```

これで http://mydiary.herokuapp.com にアクセスして日記を書くことができます。

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

memcache アドオンを使う方法
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
git commit -m "enable memcach"
git push heroku deploy:master
```

git push コマンドが完了すると memacached をキャッシュの保存先とした tDiary が利用可能となります。
