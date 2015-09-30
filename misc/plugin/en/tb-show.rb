# English resource of tb-show.rb
#

def tb_show_conf_html
	<<-"HTML"
	<h3 class="subtitle">TrackBack anchor</h3>
	<p>TrackBack anchor is inserted into begining of each TrackBacks from other weblogs. So You can specify '&lt;span class="tanchor"&gt;_&lt;/span&gt;">', image anchor will be shown Image anchor by themes.</p>
	<p><input name="trackback_anchor" value="#{ h(@conf['trackback_anchor'] || @conf.comment_anchor ) }" size="40"></p>
	<h3 class="subtitle">TrackBack display style</h3>
	<p>In Latest or Month mode, you can specify style of trackbacks displayed.</p>
	<p><select name="trackback_shortview_mode">
	#{ [["num_in_reflist", "Show number of TrackBacks in referer list (always)"],
	    ["num_in_reflist_if_exists", "Show number of TrackBacks in referer list (if exists)"],
	    ["shortlist", "Show short list of TrackBacks"]
	   ].map{ |op|
	     "<option value='#{op[0]}' #{'selected' if @conf['trackback_shortview_mode'] == op[0]}>#{op[1]}</option>\n"
	   }.to_s }
	</select></p>
	<h3 class="subtitle">Number of TrackBacks</h3>
	<p>In Latest or Month mode, you can specify number of visible TrackBacks. So in Dayly mode, all of TrackBacks are shown.</p>
	<p><input name="trackback_limit" value="#{ h( @conf['trackback_limit'] || @conf.comment_limit )}" size="3"> TrackBacks</p>
        <h3 class="subtitle">Show TrackBack URL</h3>
        <p>In Latest or Month mode, you can specify TrackBack URL will be shown or not in each days.</p>
	<p><select name="trackback_disp_pingurl">
	<option value="true" #{'selected' if @conf['trackback_disp_pingurl']}>Show</options>
	<option value="false" #{'selected' if !@conf['trackback_disp_pingurl']}>Hide</options>
	</select></p>
	HTML
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
