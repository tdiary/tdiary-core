# English resource of tb-send.rb

@tb_send_label_url = 'Send TrackBack to'
@tb_send_label_section = 'Section of TrackBack source'
@tb_send_label_no_section = '(no section specify)'
@tb_send_label_current_section = '(last added section)'
if @conf['tb.no_section'] then
	@tb_send_label_excerpt = 'Excerpt (use article body in default if not specify here)'
else
	@tb_send_label_excerpt = 'Excerpt (use section body in default if not specify here)'
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
