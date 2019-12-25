# Install to PaaS

## 概要

tDiary-3.1.3 以降のバージョンでは tDiary を [Heroku](http://www.heroku.com) のような PasS で動かすことが可能です。PaaS を利用することで、3.1.3 以前のバージョンで必要とされていた Apache のような http サーバーの用意や CGI として動作させるための環境設定を行う事なく、 tDiary を動かして日記を書くことが可能となります。

## 動かし方 - Heroku の場合

Webブラウザだけあれば動作させることが可能です。

日記の更新時にTwitterのOAuthを使って認証するようになっています。あらかじめ[Twitter Developpers](https://developer.twitter.com/en/apps)にてアプリケーションを作成し、API key と API secret key を取得しておきます。

続いて GitHub 上にある[tDiaryのリポジトリ](https://github.com/tdiary/tdiary-core)から、Herokuボタンを使ってデプロイしてください(トップページ下部のREADMEにあります)。

Heroku の New App ページになったら、下記の情報を入力して、Deploy for Free ボタンを押します。

* App Name (任意)
* TWITTER_KEY: Twitter の API key
* TWITTER_SECRET: Twitter の API secret key
* TWITTER_NAME: 認証に使う Twitter のユーザ名

「Deployed to Heroku」まで進めば利用可能です。「View it」のリンクから日記に飛んで下さい。

【注意】View itから飛んだ先のURLは https://～ になっています。いったん http://～ にしないと認証が通らないので注意してください。なお、設定画面で「日記のURL」を https://～ に変更することで https での利用が可能です。

また、tDiary 5.10 より、amazonプラグインを利用する場合に特別な設定が必要になっています。[tDiary 5.1.0のリリース](http://www.tdiary.org/20191129.html)にある方法でAmazon PA-APIのアクセスキーとシークレットキーを取得し、Herokuの環境変数(Settings→Config Vars)にてぞれぞれ以下の変数に指定します。

* AMAZON_ACCESS_KEY
* AMAZON_SECRET_KEY

あとはtDiaryの設定画面から、AmazonのアソシエイトIDを指定すれば利用できます。

## memcache アドオンを使う方法 - Heroku の場合

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
# require 'tdiary/cache/file'
# To use memcache addon
require 'tdiary/cache/memcached'
```

この状態を Heroku に反映させます。

```
git add .
git commit -m "enable memcache"
git push heroku deploy:master
```

git push コマンドが完了すると memcached をキャッシュの保存先とした tDiary が利用可能となります。
