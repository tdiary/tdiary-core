# ja/recent_trackback3.rb
#
# English resources for recent_trackback3.rb
#
# Copyright (c) 2004 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

if @mode == 'conf' || @mode == 'saveconf'
add_conf_proc( 'recent_trackback3', 'Recent TrackBacks', 'tsukkomi' ) do
	saveconf_recent_trackback3
	recent_trackback3_init
 	checked = "t" == @conf['recent_trackback3.tree'] ? ' checked' : ''

	<<-HTML
	<h3 class="subtitle">The number of trackbacks</h3>
	<p>Max <input name="recent_trackback3.n" value="#{h( @conf['recent_trackback3.n'] )}" size="3"> entries</p>

	<h3 class="subtitle">Format specification for date</h3>
	<p>See <a href="http://www.rubycentral.com/ref/ref_c_time.html#strftime">ruby's reference manual</a>.</p>
	<p><input name="recent_trackback3.date_format" value="#{h( @conf['recent_trackback3.date_format'] )}" size="40"></p>
 
 	<h3 class="subtitle">Tree View mode</h3>
 	<p><label for="recent_trackback3.tree"><input id="recent_trackback3.tree" name="recent_trackback3.tree" type="checkbox" value="t"#{checked} />used Tree View</label></p>
 
 	<h3 class="subtitle">length of title at Tree View mode</h3>
 	<p>Input length of title at Tree View mode. When Tree view mode is not used, it doesn't relate.</p>
 	<p>Max <input name="recent_trackback3.titlelen" value="#{h( @conf['recent_trackback3.titlelen'] )}" size="3" /> characters.</p>
 
	<h3 class="subtitle">Template</h3>
	<p>Specify how each trackback is rendered.</p>
	<textarea name="recent_trackback3.format" cols="60" rows="3">#{h( @conf['recent_trackback3.format'] )}</textarea>
	<p><em>$digit</em> in the template is replaced as follows.</p>
	<dl>
		<dt>$2</dt><dd>the TrackBack's URL</dd>
		<dt>$3</dt><dd>the TrackBack's excerpt</dd>
		<dt>$4</dt><dd>the sender of the TrackBack</dd>
		<dt>$5</dt><dd>when the TrackBack is received</dd>
	</dl>
	HTML
end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
