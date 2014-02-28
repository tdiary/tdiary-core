# -*- coding: utf-8 -*-
# ja/recent_comment3.rb
#
# Japanese resources for recent_comment3.rb
#
# Copyright (c) 2005 SHIBATA Hiroshi <h-sbt@nifty.com>
# Distributed under the GPL
#

if @mode == 'conf' || @mode == 'saveconf'
   add_conf_proc( 'recent_comment3', '最近のツッコミ', 'tsukkomi' ) do
      saveconf_recent_comment3
      recent_comment3_init
      checked = "t" == @conf['recent_comment3.tree'] ? ' checked' : ''

      <<-HTML
      <h3 class="subtitle">表示するツッコミの数</h3>
      <p>最大 <input name="recent_comment3.max" value="#{h( @conf['recent_comment3.max'] )}" size="3" /> 件</p>

      <h3 class="subtitle">日付フォーマット</h3>
      <p>使用できる\'%\'文字については<a href="http://www.ruby-lang.org/ja/man/index.cgi?cmd=view;name=Time#strftime">Rubyのマニュアル</a>を参照．</p>
      <p><input name="recent_comment3.date_format" value="#{h( @conf['recent_comment3.date_format'] )}" size="40" /></p>

      <h3 class="subtitle">一覧に表示しない名前</h3>
      <p>リストに表示しない名前を","で区切って指定します．</p>
      <p><input name="recent_comment3.except_list" size="60" value="#{h( @conf['recent_comment3.except_list'] )}" /></p>

      <h3 class="subtitle">ツリー表示機能</h3>
      <p><label for="recent_comment3.tree"><input id="recent_comment3.tree" name="recent_comment3.tree" type="checkbox" value="t"#{checked} />ツリー表示機能を使用する</label></p>

      <h3 class="subtitle">ツリー表示時のタイトルの長さ</h3>
      <p>ツリー表示機能を使用する時のタイトルの長さを指定します。ツリー表示機能を使用しない場合には関係ありません。</p>
      <p>最大 <input name="recent_comment3.titlelen" value="#{h( @conf['recent_comment3.titlelen'] )}" size="3" /> 文字</p>

      <h3 class="subtitle">生成するHTMLのテンプレート</h3>
      <p>各ツッコミをどのようなHTMLで表示するかを指定します．</p>
      <textarea name="recent_comment3.format" cols="70" rows="3">#{h( @conf['recent_comment3.format'] )}</textarea>
      <p>テンプレート中の<em>$数字</em>はそれぞれ以下の内容で置き換えられます．必要のないものは指定しなくても構いません．</p>
      <dl>
      <dt>$2</dt><dd>ツッコミのURL．</dd>
      <dt>$3</dt><dd>ツッコミの短縮表示</dd>
      <dt>$4</dt><dd>ツッコミした人の名前</dd>
      <dt>$5</dt><dd>ツッコミの時刻．「日付フォーマット」で指定した形式で表示されます。</dd>
      </dl>
      <h3 class="subtitle">ツッコミがないときのメッセージ</h3>
      <p>表示するツッコミがない場合に表示する内容を指定します．</p>
      <p><input name="recent_comment.notfound_msg" value="#{h(@conf['recent_comment.notfound_msg'])}" size="40" /></p>
      HTML
   end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
