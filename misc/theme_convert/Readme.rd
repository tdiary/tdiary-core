=begin

=theme_convert.rb
==含まれるファイル
	* Readme.rd: このファイル
	* append.rcss: 2.0 系用のツッコミ・更新フォーム部の CSS 断片
	* theme_convert.rb: 本体スクリプト

==使い方
 $ ruby theme_convert.rb hoge.css

と実行すると、hoge-2.css と hoge-simple.css が作成されます。
hoge-2.css が 2.0 系用に変換された CSS ファイルです。
細かい点はその CSS ファイルを手で修正してください。
（hoge-simple.css は一時ファイルです）

実行するためには、咳さんによる ERb というライブラリと青木峰郎さんによる Racc とが必要です。
Erb は tDiary の配布ファイルに含まれています。erb というディレクトリを theme_convert.rb と同じディレクトリに置いてください。これらのファイルについては別途 http://www2a.biglobe.ne.jp/~seki/ruby/ をごらん下さい。
Racc は多くのプラットフォームでバイナリパッケージが用意されています。rpm や deb や ports などを使ってインストールしてください。Windows 向けは Ruby 本体のパッケージに大抵含まれているようです。見つからない方は http://www.ruby-lang.org/en/raa-list.rhtml?name=Racc から入手してインストールしてください。

=end
