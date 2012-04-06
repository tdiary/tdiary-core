Install to heroku
=====================

概要
--

tDiary-3.1.3 以降のバージョンでは tDiary を PasS である [heroku](http://www.heroku.com) で動かすことが可能です。heroku を利用することで以前のバージョンで必要とされていてサーバーの用意や CGI として動作させるための環境構築を行う事なく、 tDiary を動かして日記を書くことが可能となります。

必要なもの
-----

tDiary を heroku で動作させるためには以下のツールが必要となります。

  - [git](http://git-scm.com)
  - Ruby 1.8.7 以降
  - RubyGems 1.3.7 以降
  - Bundler 1.0.0 以降

また、よくわからない場合は heroku が配布している [heroku toolbelt](https://toolbelt.heroku.com) を用いると簡単に上記のツールをインストールすることができます。

動かし方
----

tDiary の最新版を取得します。

```
git clone git://github.com/tdiary/tdiary-core.git
```

heroku コマンドを用いて heroku でアプリケーションを作成します。なお、heroku のアカウント作成方法は本ドキュメントでは省略します。tDiary のルートディレクトリ(Gemfile が存在する箇所) で以下のコマンドを実行します。

```
cd tdiary-core
heroku create mydiary -s cedar
heroku addon:add memcache
```

heroku 専用の作業ブランチを作成します。

```
git checkout -b deploy
```

作業ブランチで heroku で動かすために必要な設定ファイルを変更、または新規作成します。

```
cp tdiary.conf.heroku tdiary.conf
```

Gemfile のコメントアウトされている箇所のうち、以下を有効にします。JRuby 用の設定は試験的なものなので、よくわからない場合はコメントアウトのままとしてください。

```
# Use tDiary in Heroku
gem 'sequel'
gem 'dalli'
#
# To use CRuby
platforms :mri do
  gem 'thin', :require => false
  gem 'pg'
end
```

.gitignore の 9 行目の tdiary.conf を削除します。

config.ru の 30 行目に記載されているユーザー名とパスワードを変更します。この情報は重要なので、外部には公開しないでください。

```
# ユーザ名を bob, パスワードを manhattan にする場合
user == 'bob' && pass == 'manhattan'
```

上記の変更を deploy ブランチにコミットし、heroku にアプリケーションを転送します。

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
