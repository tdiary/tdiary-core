# -*- coding: utf-8; -*-
# Japanese resources of 60sf.rb
# Based on 50sp.rb
# Modified by KURODA Hiraku.

=begin
= スパムフィルター選択プラグイン
Please see below for an English description.

== 概要
どのフィルターを使うのか選びます

選択したフィルターはデフォルトのフィルターによる判定の後で適用されます。

== 使い方
このプラグインをplugin/ディレクトリに配置してください。

次に、tdiary.rbと同じ場所にあるtdiary.confに、
  @conf.options['sf.path'] = 'misc/filter'
などと、選択できるフィルターのあるディレクトリをtdiary.rbのあるディレク
トリからの相対パスか絶対パスで指定してください。

フィルターに設定用のプラグインが付属している場合は、フィルター用ディレク
トリの下にpluginディレクトリを作り、その中に入れておくと、フィルターを
ロードした後でプラグインもロードされます。

例えばベイズフィルタをmisc/filterに置いた場合は次のようなディレクトリ
構成になります。

misc/filter/
        |-- plugin/
        |   |-- en/spambayes.rb
        |   |-- ja/spambayes.rb
        |   `-- spambayes.rb
        `-- spambayes.rb

== オプション
:@conf.options['sf.path']
  'filter/selectable'などと、選択できるフィルターのあるディレクトリを、
  tdiary.rbのあるディレクトリからの相対パスか絶対パスで指定してください。

:@conf.options['sf.usenew']
  新しくインストールされたフィルターをデフォルトで使うようにする場合は
  trueに設定してください。新しくインストールされたフィルターを検出するの
  は、次にフィルターが選択される時です。

== 著作権について (Copyright notice)
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL version 2 or later.

Original version of these files is for selecting plugins.
Modifying for selecting filters is by KURODA Hiraku <hiraku at hinet.mydns.jp>
Feb. 2008
=end


@sf_label = 'スパムフィルター選択'
@sf_label_description = '<p>どのフィルターを使うか選択します。</p>'
@sf_label_please_select = '<p>有効にしたいフィルターにチェックしてください。フィルターのファイル名をクリックするとドキュメントが見られるかもしれません。ぜひ追加・編集してくださいね。</p>'
@sf_label_new = '<h3>新入荷！お試しください</h3>'
@sf_label_used = '<h3>使用中</h3>'
@sf_label_notused = '<h3>休憩中</h3>'
@sf_label_noplugin = '<p>選択可能なフィルターはありません。</p>'

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
