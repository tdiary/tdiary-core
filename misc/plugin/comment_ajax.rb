if @mode == 'day' and not bot? then
	enable_js('comment_ajax.js')
	add_js_setting('$tDiary.plugin.comment_ajax')
	add_js_setting('$tDiary.plugin.comment_ajax.theme', %Q["#{theme_url}"])
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vi: ts=3 sw=3
