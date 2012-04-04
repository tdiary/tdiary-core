How to testing tDiary
=====================

概要
--

tDiary-3.0.1.20101011 以降のバージョンでは tDiary を test するための仕組みがいくつか導入されています。具体的には以下の2点です。

  - Capybara と steak を使った End-to-End のテスト方法
  - RSpec2 による単体テスト方法

前者の方法は tDiary の内部構造に意識せずに、初期データからブラウザに表示される内容をテストする方法であり、後者の方法はプラグインや特定のメソッドをテストするたびに用いられる方法です。

テスト可能な tDiary 最終目標は cgi.rb に依存する仕組みから Rack のインタフェースに載せ替えた上で、tDiary の各モジュールに対してテストを実行できるようにすることです。

必要なもの
-----

tDiary でテストを実行するためには以下の環境を用意する必要があります。

  - Ruby 1.8.7 以降または Ruby 1.9.2 以降
  - RubyGems 1.3.7 以降
  - Bundler 1.0.0 以降

動かし方
----

tDiary のルートディレクトリ(Gemfile が存在する箇所) で以下のコマンドを実行します。

```
bundle install --path ~/.bundle
```
bundler によるインストールが完了すると、tDiary でテストを実行できるようになります。以下のコマンドを実行すると、tDiary に付属しているテストが全て実行されます。

```
bundle exec rake spec
```

テストのディレクトリ構成と Rake タスク
----------------------

tDiary に用意されているテストは以下の3種類で構成されています。この構成は今後も変更される可能性もあるので、Rake -T コマンドを実行して Rake タスクの内容を確認するようにしてください。

rake spec:acceptanceEnd-to-End のテストを実行しますrake spec:corecore(tDiary本体)に関わるテストを実行します。rake spec:pluginmisc/plugin 配下に存在するプラグインファイルのテストを実行します。
