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

==代表的なエラーの対処の仕方
 $ ruby theme_convert.rb tdiary1/tdiary1.css 
 Error!: in tdiary1/tdiary1-simple.css:3: parse error on "}"
 Are there empty blocks in your css? Check your css file.

このようなエラーが発生したときは、tdiary1/tdiary1-simple.css の 3 行目を
パースする時にエラーが発生しています。このエラーの理由は下記の「既知の制限」
によるものです。パースエラーが発生しているのは tdiary1/tdiary1.css の 3 行目
ではないことに注意してください。

修正するには、tdiary1/tdiary1-simple.css を見て問題箇所を把握してから、
tdiary1/tdiary1.css の該当箇所を調整してください。

==既知の制限

以下の記述を含むテーマファイルには使えません。

1. ブロックの中身が空のもの
 	例. span.title {
 	    }

=end
