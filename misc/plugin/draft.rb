# -*- coding: utf-8; -*-
#
# draft.rb: save draft data to Web Storage automatically
#
# Copyright (c) MATSUOKA Kohei <http://www.machu.jp/>
# Distributed under the GPL2 or any later version.
#
if /\A(form|edit|preview|showcomment)\z/ === @mode then
	enable_js('draft.js')
end

add_edit_proc do
	<<-EOS
	<div class="draft">
		下書き:
		<select name="drafts"></select>
		<button type="button" id="draft_load">読み込み</button>
	</div>
	EOS
end
