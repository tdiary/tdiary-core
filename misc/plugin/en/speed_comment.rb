def speed_comment_label
	'Speed TSUKKOMI'
end

def speed_comment_html
	<<-HTML
	<h3>Size of the form of Speed TSUKKOMI</h3>
	<p>Name: <input name="speed_comment.name_size" size="5" value="#{h( @conf['speed_comment.name_size'])} || 20 "></p>
	<p>Body: <input name="speed_comment.body_size" size="5" value="#{h( @conf['speed_comment.body_size'])} || 40 "></p>
	HTML
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
