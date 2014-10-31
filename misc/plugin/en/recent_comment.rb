# en/recent_comment.rb
#
# English resources for recent_comment.rb
#
# Copyright (c) 2005 Hiroshi SHIBATA <h-sbt@nifty.com>
# Distributed under the GPL2 or any later version.
#

if @mode == 'conf' || @mode == 'saveconf'
   add_conf_proc( 'recent_comment', 'Recent TSUKKOMI', 'tsukkomi' ) do
      saveconf_recent_comment
      recent_comment_init
      <<-HTML
      <h3 class="subtitle">The number of display comment</h3>
      <p>Max <input name="recent_comment.max" value="#{h( @conf['recent_comment.max'] )}" size="3" /> item</p>
      <h3 class="subtitle">Date format</h3>
      <p>Refer to <a href="http://www.ruby-lang.org/ja/man/index.cgi?cmd=view;name=Time#strftime">Ruby's Manual</a>for the \'%\' character that can be used.</p>
      <p><input name="recent_comment.date_format" value="#{h( @conf['recent_comment.date_format'] )}" size="40" /></p>
      <h3 class="subtitle">Non display name in recent comment list</h3>
      <p>Specified The name not displayed in the list.</p>
      <p><input name="recent_comment.except_list" size="60" value="#{h( @conf['recent_comment.except_list'] )}" /></p>
      <h3 class="subtitle">HTML Template for generate</h3>
      <p>Specify how each comment is rendered.</p>
      <textarea name="recent_comment.format" cols="60" rows="3">#{h( @conf['recent_comment.format'] )}</textarea>
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
