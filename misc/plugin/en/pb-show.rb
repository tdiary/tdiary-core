# English resource of pb-show.rb
#
def pingback_today; "Today's Pingbacks"; end
def pingback_total( total ); "(Total: #{total})"; end
def pb_show_conf_html
  <<-"HTML"
  <h3 class="subtitle">Pingback anchor</h3>
  <p>Pingback anchor is inserted into begining of each Pingbacks from other weblogs. So You can specify '&lt;span class="tanchor"&gt;_&lt;/span&gt;">', image anchor will be shown Image anchor by themes.</p>
  <p><input name="trackback_anchor" value="#{ h(@conf['trackback_anchor'] || @conf.comment_anchor ) }" size="40"></p>
  <h3 class="subtitle">Number of Pingbacks</h3>
  <p>In Latest or Month mode, you can specify number of visible Pingbacks. So in Dayly mode, all of Pingbacks are shown.</p>
  <p><input name="trackback_limit" value="#{ h( @conf['trackback_limit'] || @conf.comment_limit )}" size="3"> Pingbacks</p>
  HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
