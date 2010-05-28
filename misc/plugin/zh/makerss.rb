# makerss.rb Chinese resources
def makerss_tsukkomi_label( id )
	"TSUKKOMI to #{id[0,4]}-#{id[4,2]}-#{id[6,2]}[#{id[/[1-9]\d*$/]}]"
end

@makerss_conf_label = 'RSS feeds'

def makerss_conf_html
	<<-HTML
	<h3>RSS feeds settings</h3>
	<p>RSS feeds provides contents of your diary in a machine-readable format.
		Information in RSS is read with RSS readers and posted on other web sites.</p>
	#{%Q[<p class="message">Cannot write to file '#{@makerss_full.file}'.<br>This file have to writable by your web server.</p>] unless @makerss_full.writable?}
	<ul>
	<li><select name="makerss.hidecontent">
		<option value="f"#{' selected' unless @conf['makerss.hidecontent']}>Include</option>
		<option value="t"#{' selected' if @conf['makerss.hidecontent']}>Hide</option></select>
		encoded contents of your diary in the feed.
	<li>Include summary of your contents<select name="makerss.shortdesc">
		<option value="f"#{' selected' unless @conf['makerss.shortdesc']}>as long as possible</option>
		<option value="t"#{' selected' if @conf['makerss.shortdesc']}>only some portion</option></select>
		in the feed.
	<li><select name="makerss.comment_link">
		<option value="f"#{' selected' unless @conf['makerss.comment_link']}>Insert</option>
		<option value="t"#{' selected' if @conf['makerss.comment_link']}>Don't Insert </option></select>
		a link to TSUKKOMI form into encoded text.
	</ul>

	<h3>Feed without TSUKKOMI</h3>
	<p>Standard feed contains your diary and also TSUKKOMIs by your diary readers. If you want to make a feed without TSUKKOMIs, set this preference below. So, when standard feed has encoded contens, this feed contain encoded text of TSUKKOMI also.</p>
	#{%Q[<p class="message">Cannot write to file '#{@makerss_no_comments.file}'.<br>This file have to writable by your web server.</p>]  if @conf['makerss.no_comments'] and !@makerss_no_comments.writable?}
	<ul>
	<li><select name="makerss.no_comments">
		<option value="t"#{' selected' if @conf['makerss.no_comments']}>Feed</option>
		<option value="f"#{' selected' unless @conf['makerss.no_comments']}>Don't feed</option></select> RSS without TSUKKOMI.</li>
	</ul>
	HTML
end

@makerss_edit_label = "A little modify (don't update feeds)"

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
