# Japanese resources of 01sp.rb $Revision: 1.2 $

=begin
= プラグイン選択プラグイン((-$Id: 01sp.rb,v 1.2 2003-09-30 09:41:21 tadatadashi Exp $-))
Please see below for an English description.

== 概要
どのプラグインを使うのか選びます

このプラグインは00defaults.rbの次に読まれ、このプラグイン自身から選択可
能なプラグインが読まれます。その後にデフォルトのパスにあるプラグインが読
み込まれますので、同じメソッドを定義している場合には、デフォルトのパスの
ものが有効になります。

== 使い方
このプラグインをplugin/ディレクトリに配置してください。

また、00defaults.rbやこのプラグインなど、絶対に必要なプラグイン以外は、
httpサーバーから見られる別のディレクトリに移してください。以下の例では、
pluginディレクトリの下にselectableというディレクトリを作っています。

最後に、tdiary.rbと同じ場所にあるtdiary.confに、
  @options['sp.path'] = 'misc/plugin'
などと、選択できるプラグインのあるディレクトリをtdiary.rbのあるディレク
トリからの相対パスか絶対パスで指定してください。

secure==trueな日記でも使えます。

== オプション
:@options['sp.path']
  'plugin/selectable'などと、選択できるプラグインのあるディレクトリを、
  tdiary.rbのあるディレクトリからの相対パスか絶対パスで指定してください。

:@options['sp.showhelp']
  注釈を表示したい場合にはtrueに設定してください。

:@options['sp.showsource']
  ソースを表示したい場合にはtrueに設定してください。

:@options['sp.showmandatory']
  絶対に必要なプラグインの情報を表示したい場合にはtrueに設定してください。

:@options['sp.usenew']
  新しくインストールされたプラグインをデフォルトで使うようにする場合は
  trueに設定してください。新しくインストールされたプラグインを検出するの
  は、次にプラグインが選択される時です。

== TODO
選択されていたプラグインが消去された時にどうするか。現在の実装では、プラ
グイン読み込み時には無視して、次に選択をしなおした時に消える。

== 著作権について (Copyright notice)
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL
version 2 or later.

You should be able to find the latest version of this pluigin at
((<URL:http://zunda.freeshell.org/d/plugin/select_plugins.rb>)).
=end


@sp_label = 'プラグイン選択'
@sp_label_description = '<p>どのプラグインを使うか選択します。</p>'
@sp_label_mandatory = %Q|<h4>常に使われるプラグイン</h4>
				<p>使うかどうか選択することはできません。</p>|
@sp_label_optional = "<h4>使うかどうか選択できるプラグイン</h4>"
@sp_label_optional2 = "<p>有効にしたいプラグインにチェックしてください。</p>"
@sp_label_comment = "注釈"
@sp_label_source = "ソース"
@sp_label_new = '[新入荷！お試しください。]'
@sp_label_noplugin = "<li>選択可能なプラグインはありません。"
