#
# hide-mail-field.rb: Hide E-mail field in TSUKKOMI form against spams.
#
# To enable this plugin effective, you have to add '@' or '.*' into E-mail
# address field in spamfilter plugin.
#
# Copyright (C) 2007 by TADA Tadahi <sho@spc.gr.jp>
# Distributed under GPL2 or any later version.
#
add_header_proc do
	if @mode == 'day'
		<<-STYLE
		<style type="text/css"><!--
			form.comment div.mail { display: none; }
		--></style>
		STYLE
	else
		''
	end
end

add_footer_proc do
	if @mode == 'day'
		<<-SCRIPT
		<script type="text/javascript"><!--
			document.getElementsByName("mail")[0].value = "";
		//--></script>
		SCRIPT
	else
		''
	end
end

def comment_form_mobile_mail_field
	%Q|<INPUT NAME="mail" TYPE="hidden">|
end

add_conf_proc( 'hide-mail-field', @hide_mail_field_label_conf, 'security' ) do
	if @mode == 'saveconf'
		@conf['comment_description'] = @cgi.params['comment_description'][0]
	end
	hide_mail_field_conf_html
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
