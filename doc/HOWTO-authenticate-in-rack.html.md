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

まず、利用する外部サービスに対応したライブラリを有効にします。Twitter認証では `omniauth-twitter` ライブラリを使用します。Gemfileにて以下の行が有効になっていることを確認してください。無ければ追加してください。

```
gem 'omniauth'
gem 'omniauth-twitter'
```

次に設定ファイル `config.ru` を編集します。 `use OmniAuth::Builder` ブロック内の `provier :twitter` で始まる行を有効にします。

```
# OmniAuth settings
use Rack::Session::Pool, :expire_after => 2592000
use OmniAuth::Builder do
	configure {|conf| conf.path_prefix = "#{base_dir}/auth" }
	provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
end
```

### 鍵とパスワードの取得と環境変数への設定

設定ファイル `config.ru` に書かれているTWITTER_KEYとTWITTER_SECRETは、Twitter認証を利用するための鍵 (Consumer key) とパスワード (Consumer secret) です。これらは[Twitterのサイト](https://dev.twitter.com/apps/new)から取得できます。

鍵とパスワードを取得したら環境変数に設定します。

```
export TWITTER_KEY="your_consumer_key"
export TWITTER_SECRET="your_consumer_secret"
```

ここではbashの例を書きましたが、環境変数の設定方法は環境によって異なります。たとえばherokuの場合は `heroku config` コマンドを使用します。もし環境変数が設定できない環境であれば、 `config.ru` を直接書き換えてください。

### 編集画面へのアクセスを許可するアカウントの設定

日記の編集画面へのアクセスを許可するアカウントを設定します。 `config.ru` 内の `use TDiary::Rack::Auth::OmniAuth` で始まるブロックをコメントアウトしてください。

```
map "#{base_dir}/update.rb" do
	# use TDiary::Rack::Auth::Basic, '.htpasswd'
	use TDiary::Rack::Auth::OmniAuth, :twitter do |auth|
		auth.info.nickname == 'your_twitter_screen_name'
	end
	run TDiary::Application.new(:update)
end
```

`your_twitter_screen_name` にあなたのTwitterアカウント名を設定します。

日記の編集画面にアクセスすると、Twitterのログイン画面が表示されるようになります。編集画面へは `your_twitter_screen_name` で指定したアカウントのみがアクセスできます。