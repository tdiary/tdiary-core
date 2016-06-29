# -*- coding: utf-8; -*-
#
# preview.rb: view preview automatically
#
# Copyright (c) MATSUOKA Kohei <http://www.machu.jp/>
# Distributed under the GPL2 or any later version.
#

@conf['preview.interval'] ||= 10
@conf['preview.min_width'] ||= 896

if /\A(form|edit|preview)\z/ === @mode then
	enable_js('preview.js')
	add_js_setting('$tDiary.plugin.preview')
	add_js_setting('$tDiary.plugin.preview.interval', @conf['preview.interval'].to_json)
	add_js_setting('$tDiary.plugin.preview.minWidth', @conf['preview.min_width'].to_json)
end

add_conf_proc('preview', @preview_label_conf, 'update') do
	if @mode == 'saveconf'
		@conf['preview.interval'] = @cgi.params['preview.interval'][0].to_i
		@conf['preview.min_width'] = @cgi.params['preview.min_width'][0].to_i
	end
	ERB.new(%q{
		<h3><%= @preview_label_interval %></h3>
		<div>
			<p><%= @preview_label_interval_desc %></p>
			<p><input name="preview.interval" value="<%=h @conf['preview.interval'] %>"> sec</p>
		</div>
		<h3><%= @preview_label_min_width %></h3>
		<div>
			<p><%= @preview_label_min_width_desc %></p>
			<p><input name="preview.min_width" value="<%=h @conf['preview.min_width'] %>"> px</p>
		</div>
	}).result(binding)
end
