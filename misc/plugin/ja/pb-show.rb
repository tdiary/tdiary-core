# Japanese resource of pb-show.rb
#

def pingback_today; '本日のPingbacks'; end
def pingback_total( total ); "(全#{total}件)"; end
def pb_show_conf_html
  <<-"HTML"
  <h3 class="subtitle">Pingback アンカー</h3>
  <p>他のweblogからのPingbackの先頭に挿入される、リンク用のアンカー文字列を指定します。なお「&lt;span class="tanchor"&gt;_&lt;/span&gt;」を指定すると、テーマによっては自動的に画像アンカーがつくようになります。</p>
  <p><input name="pingback_anchor" value="#{ h(@conf['pingback_anchor'] || @conf.comment_anchor ) }" size="40"></p>
  <h3 class="subtitle">Pingback リスト表示数</h3>
  <p>最新もしくは月別表示時に表示する、Pingbackの最大件数を指定します。なお、日別表示時にはここの指定にかかわらず最大100件のPingbackが表示されます。</p>
  <p>最大<input name="pingback_limit" value="#{ h(@conf['pingback_limit'] || @conf.comment_limit ) }" size="3">件</p>
  HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
