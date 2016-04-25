# append-css.rb
#
# Append CSS fragment via Preferences Page.
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL2 or any later version.
#
add_header_proc do
	if @mode !~ /conf$/ && @conf['append-css.css'] && @conf['append-css.css'].length > 0 && !bot?
		<<-HTML if @conf['append-css.css']
		<style type="text/css"><!--
		#{@conf['append-css.css']}
		--></style>
		HTML
	else
		''
	end
end

unless @resource_loaded
	def append_css_label
		'CSSの追加'
	end

	def append_css_desc
		<<-HTML
		<h3>CSS断片</h3>
		<p>現在指定してあるテーマに、スタイルシートを追加設定する場合、
		以下にCSSの断片を入力してください。</p>
		HTML
	end
end

add_conf_proc( 'append-css', append_css_label, 'theme' ) do
	if @mode == 'saveconf'
		@conf['append-css.css'] = @cgi.params['append-css.css'][0]
	end

	<<-HTML
	#{append_css_desc}
	<p><textarea name="append-css.css" cols="60" rows="15">#{h @conf['append-css.css']}</textarea></p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
