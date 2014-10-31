# en/recent_comment3.rb
#
# English resources for recent_comment3.rb
#
# Copyright (c) 2005 Hiroshi SHIBATA <h-sbt@nifty.com>
# Distributed under the GPL2 or any later version.
#

if @mode == 'conf' || @mode == 'saveconf'
   add_conf_proc( 'recent_comment3', 'Recent TSUKKOMI', 'tsukkomi' ) do
      saveconf_recent_comment3
      recent_comment3_init
      checked = "t" == @conf['recent_comment3.tree'] ? ' checked' : ''

      <<-HTML
      <h3 class="subtitle">The number of display comment</h3>
      <p>Max <input name="recent_comment3.max" value="#{h( @conf['recent_comment3.max'] )}" size="3" /> item</p>

      <h3 class="subtitle">Date format</h3>
      <p>Refer to <a href="http://www.ruby-lang.org/ja/man/index.cgi?cmd=view;name=Time#strftime">Ruby's Manual</a>for the \'%\' character that can be used.</p>
      <p><input name="recent_comment3.date_format" value="#{h( @conf['recent_comment3.date_format'] )}" size="40" /></p>

      <h3 class="subtitle">Non display name in recent comment list</h3>
      <p>Specified The name not displayed in the list. Name is delimited by ","</p>
      <p><input name="recent_comment3.except_list" size="60" value="#{h( @conf['recent_comment3.except_list'] )}" /></p>

      <h3 class="subtitle">Tree View mode</h3>
      <p><label for="recent_comment3.tree"><input id="recent_comment3.tree" name="recent_comment3.tree" type="checkbox" value="t"#{checked} />used Tree View</label></p>

      <h3 class="subtitle">length of title at Tree View mode</h3>
      <p>Input length of title at Tree View mode. When Tree view mode is not used, it doesn't relate.</p>
      <p>Max <input name="recent_comment3.titlelen" value="#{h( @conf['recent_comment3.titlelen'] )}" size="3" /> characters.</p>

      <h3 class="subtitle">HTML Template for generate</h3>
      <p>Specify how each comment is rendered.</p>
      <textarea name="recent_comment3.format" cols="60" rows="3">#{h( @conf['recent_comment3.format'] )}</textarea>
      <p><em>$digit</em> in the template is replaced as follows.</p>
      <dl>
      <dt>$2</dt><dd>comment's URL</dd>
      <dt>$3</dt><dd>comment's shortening display</dd>
      <dt>$4</dt><dd>name of comment's author</dd>
      <dt>$5</dt><dd>when the comment is received</dd>
      </dl>
      <h3 class="subtitle">Message for no comment</h3>
      <p>Specify the message to be shown when there is no comment entry.</p>
      <p><input name="recent_comment.notfound_msg" value="#{h( @conf['recent_comment.notfound_msg'] )}" size="40" /></p>
      HTML
   end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
