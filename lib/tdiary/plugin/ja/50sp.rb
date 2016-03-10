# -*- coding: utf-8; -*-
# Japanese resources of 50sp.rb

=begin
= プラグイン選択プラグイン((-$Id: 50sp.rb,v 1.3 2008-03-02 09:01:21 kazuhiko Exp $-))
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
  @conf.options['sp.path'] = 'misc/plugin'
などと、選択できるプラグインのあるディレクトリをtdiary.rbのあるディレク
トリからの相対パスか絶対パスで指定してください。

== オプション
:@conf.options['sp.path']
  'plugin/selectable'などと、選択できるプラグインのあるディレクトリを、
  tdiary.rbのあるディレクトリからの相対パスか絶対パスで指定してください。

:@conf.options['sp.usenew']
  新しくインストールされたプラグインをデフォルトで使うようにする場合は
  trueに設定してください。新しくインストールされたプラグインを検出するの
  は、次にプラグインが選択される時です。

== TODO
選択されていたプラグインが消去された時にどうするか。現在の実装では、プラ
グイン読み込み時には無視して、次に選択をしなおした時に消える。

== 著作権について (Copyright notice)
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL version 2 or later.
=end


@sp_label = 'プラグイン選択'
@sp_label_description = '<p>どのプラグインを使うか選択します。</p>'
@sp_label_please_select = '<p>有効にしたいプラグインにチェックしてください。プラグインのファイル名をクリックするとドキュメントが見られるかもしれません。ぜひ追加・編集してくださいね。</p>'
@sp_label_new = '<h3>新入荷！お試しください</h3>'
@sp_label_used = '<h3>使用中</h3>'
@sp_label_notused = '<h3>休憩中</h3>'
@sp_label_noplugin = '<p>選択可能なプラグインはありません。</p>'

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
