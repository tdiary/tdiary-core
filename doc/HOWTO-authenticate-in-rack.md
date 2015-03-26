How to authenticate in rack
===========================

概要
----

tDiaryをCGI/FastCGI環境で動かす場合は、WebサーバのBasic認証機能を使って認証を実現しています。一方、Rack環境で動かす場合には、Rackミドルウェアにて認証を実現します。ここでは、Rack環境での認証の導入方法を説明します。

認証方法
----

Rack環境では、以下の認証方法が利用できます。

  - Basic認証
  - 外部サービス認証

Basic認証はCGI/FastCGI環境と同様に、 `.htpasswd` ファイルによる認証を提供します。外部サービス認証はOpenIDやOAuthなどの仕組みを使って、TwitterやGitHubなどの外部のサービスによる認証を提供します。

Basic認証の使い方
----

Basic認証では、パスワードを2つの方法で格納できます。通常はパスワードがハッシュ化されて保存される1の方法を利用してください。

  1. IDとパスワードを格納する.htpasswdファイルを作成する
  2. 設定ファイル (config.ru) にIDとパスワードを記述する

htpasswdコマンドを使って`.htpasswd`ファイルを作成します。

```
htpasswd -cd .htpasswd username
```

-cオプションはファイルの新規作成、-dオプションは暗号化にCRYPT方式を利用します。現時点ではCRYPT方式にのみ対応しており、MD5やSHA1方式には対応していないため、必ず-dオプションを指定してください。

外部サービス認証
----

外部サービス認証は、[OmniAuth](https://github.com/intridea/omniauth)という認証フレームワークを利用して実現しています。設定方法は、利用する外部サービスによって若干異なります。 ここでは、Twitter認証を利用する場合を例にとって説明します。

### ライブラリを有効にする

利用する外部サービスに対応したライブラリを有効にします。Twitter認証では `omniauth-twitter` ライブラリを使用します。Gemfile.localにて以下の行が有効になっていることを確認してください。無ければ追加してください。

```
gem 'omniauth'
gem 'omniauth-twitter'
```

### Twitter Appsへのアプリケーションの登録

Twitter 認証を使うためには、Twitter のサイトにてアプリケーションを登録する必要があります。[Twitter Apps](https://dev.twitter.com/apps/new)にアクセスし、以下の情報を入力して新しいアプリケーションを登録してください。

  - Name: アプリケーションの名前です。設置する日記のタイトルを設定すると分かりやすいでしょう。
  - Description: アプリケーションの説明です。迷ったら「日記へログインするためのTwitter認証」などとすると良いでしょう。
  - Website: アプリケーションのURLです。設置する日記のトップページを設定すると分かりやすいでしょう。
  - Callback URL: 認証後に移動するURLです。Websiteと同じURLを設定してください。

Name, Description, Websiteに設定した値は、Twitterのアプリ連携画面（認証画面）に表示されます。また、Callback URLを空欄にするとTwitter認証が動作しなくなります。任意のURLで良いので設定してください。

### 鍵とパスワードの取得と環境変数への設定

Twitterのサイトから鍵とパスワードを取得したら、鍵 (Consumer key) とパスワード (Consumer secret) をそれぞれ環境変数として設定します。

```
export TWITTER_KEY="your_consumer_key"
export TWITTER_SECRET="your_consumer_secret"
```

ここではbashの例を書きましたが、環境変数の設定方法は環境によって異なります。たとえばherokuの場合は `heroku config` コマンドを使用します。もし環境変数が設定できない環境であれば、 `config.ru` を直接書き換えてください。

### 編集画面へのアクセスを許可するアカウントの設定

日記の編集画面へのアクセスを許可するアカウントを設定します。 環境変数TWITTER_NAMEにログインを許可したい twitter のアカウント名(スクリーンネーム)を設定して下さい。

```
export TWITTER_NAME='your_twitter_screen_name'
```

日記の編集画面にアクセスすると、Twitterのログイン画面が表示されるようになります。編集画面へは `your_twitter_screen_name` で指定したアカウントのみがアクセスできます。

サポートしている外部サービス認証の一覧
----

### Twitter

Gemfile.localの記述

```
gem 'omniauth'
gem 'omniauth-twitter'
```

環境変数の設定

```
export TWITTER_KEY="your_consumer_key"        # Consumer Key (API Key)
export TWITTER_SECRET="your_consumer_secret"  # Consumer Secret (API Secret)
export TWITTER_NAME="your_screen_name"        # アクセスを許可するアカウント名
```

KeyとSecretは [Twitter Application Management](https://apps.twitter.com/) にて取得できます。

### Facebook

Gemfile.localの記述

```
gem 'omniauth'
gem 'omniauth-facebook'
```

環境変数の設定

```
export FACEBOOK_KEY="your_app_id"               # App ID
export FACEBOOK_SECRET="your_app_secret"        # App Secret
export FACEBOOK_EMAIL="your_email@example.com"  # アクセスを許可するアカウントのメールアドレス
```

IDとSecretは [Facebook Developers](https://developers.facebook.com/) にて取得できます。
設定画面にてWebsiteの「Site URL」と「Mobile Site URL」には、設置する日記のアドレスを指定してください。

### Google

Gemfile.localの記述

```
gem 'omniauth'
gem 'omniauth-google-oauth2'
```

環境変数の設定

```
export GOOGLE_CLIENT_ID="your_client_id"          # クライアント ID
export GOOGLE_CLIENT_SECRET="your_client_secret"  # クライアント シークレット	
export GOOGLE_EMAIL="your_email@gmail.com"        # アクセスを許可するアカウントのメールアドレス
```

IDとシークレットは [Google Developers Console](https://code.google.com/apis/console/) にて取得できます。
設定画面にて「リダイレクトURL」には、設定する日記のアドレスの末尾に `update.rb/auth/google_oauth2/callback` を加えたものを指定してください。
日記のアドレスが `http://diary.example.com/` の場合、リダイレクトURLは `http://diary.example.com/update.rb/auth/google_oauth2/callback` となります。

また、Google Developers Consoleの「APIと認証」にて、Google+ APIのステータスをonにしてください。

### GitHub

Gemfile.localの記述

```
gem 'omniauth'
gem 'omniauth-github'
```

環境変数の設定

```
export GITHUB_KEY="your_client_id"          # Cliend ID
export GITHUB_SECRET="your_client_secret"   # Cliend Secret
export GITHUB_NAME="your_github_nickname"   # アクセスを許可するアカウント名
```

Cliend ID と Cliend Secret は、 [New OAuth Application](https://github.com/settings/applications/new) にて取得できます。
設定画面にて「Authorization callback URL」には、設置する日記のアドレスを指定してください。
