=begin

=theme_convert.rb
==含まれるファイル
	* Readme.rd: このファイル
	* append.rcss: 1.5 系用のツッコミ・更新フォーム部の CSS 断片
	* theme_convert.rb: 本体スクリプト

==使い方
 $ ruby theme_convert.rb hoge.css

と実行すると、hoge-2.css と hoge-simple.css が作成されます。
hoge-2.css が 1.5 系用に変換された CSS ファイルです。
細かい点はその CSS ファイルを手で修正してください。
（hoge-simple.css は一時ファイルです）

実行するためには、咳さんによる ERb というライブラリが必要です。tDiary の配布ファイルに含まれています。erb というディレクトリを theme_convert.rb と同じディレクトリに置いてください。これらのファイルについては別途 http://www2a.biglobe.ne.jp/~seki/ruby/ をごらん下さい。

=end
