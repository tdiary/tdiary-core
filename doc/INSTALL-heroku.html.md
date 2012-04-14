Install to Heroku
=====================

概要
--

tDiary-3.1.3 以降のバージョンでは tDiary を PasS である [heroku](http://www.heroku.com) で動かすことが可能です。Heroku を利用することで以前のバージョンで必要とされていてサーバーの用意や CGI として動作させるための環境構築を行う事なく、 tDiary を動かして日記を書くことが可能となります。

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
cd tdiary-core
heroku create mydiary -s cedar
```

Heroku 専用の作業ブランチを作成します。

```
git checkout -b deploy
```

作業ブランチで Heroku で動かすために必要な設定ファイルを変更、または新規作成します。

```
cp tdiary.conf.heroku tdiary.conf
```

Gemfile のコメントアウトされている箇所のうち、以下を有効にします。JRuby 用の設定は試験的なものなので、よくわからない場合はコメントアウトのままとしてください。

```
# Use tDiary in Heroku
gem 'sequel'
(省略)
#
# To use CRuby
platforms :mri do
  gem 'thin', :require => false
  gem 'pg'
end
(省略)
```

.gitignore の 9 行目の tdiary.conf を削除します。

config.ru の 30 行目に記載されているユーザー名とパスワードを変更します。この情報は重要なので、外部には公開しないでください。

```
# ユーザ名を bob, パスワードを manhattan にする場合
user == 'bob' && pass == 'manhattan'
```

上記の変更を deploy ブランチにコミットし、Heroku にアプリケーションを転送します。

```
git add .
git commit -m "deploy"
git push heroku deploy:master
```

最後に日記データを保存するデータベースのテーブルを作成します。

```
heroku run rake db:create
```

これで http://mydiary.herokuapp.com で日記を書くことができます。

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
