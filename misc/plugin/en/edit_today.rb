# English resources of edit_today plugin.

@edit_today_caption = 'Edit'

def edit_today_edit_label( date )
	date.strftime( 'Edit %Y-%m-%d' )
end

def edit_today_conf_html
	<<-HTML
	<h3 class="subtitle">Link String</h3>
	<p>Specify string to link to edit page. If you have image file, you can specify icon on this link.</p>
	<p><input name="edit_today_caption" size="70" value="#{h @conf['edit_today.caption']}"></p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
