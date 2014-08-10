# English resource of hide-mail-field plugin

@hide_mail_field_label_conf = 'Hide Mail Field'

def hide_mail_field_conf_html
	<<-HTML
   <h3>Description of TSUKKOMI</h3>
   <p>Show messeges about hidden of E-mail field for your subscribers. This field is as same as in default spam filter preferences.<br>
	<textarea name="comment_description" cols="60" rows="5">#{h comment_description}</textarea></p>
	Ex. "Add a TSUKKOMI or Comment please. E-mail field was hidden because against spam. Please do not input E-mail address if you can see it."</p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
