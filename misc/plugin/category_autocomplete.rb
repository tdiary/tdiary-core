# -*- coding: utf-8 -*-
#
# category_autocomplete.rb : Support the automatic input of the category
#                            using jQuery UI autocomplete.
#
# Copyright (C) 2010-2012, tamoot <tamoot+tdiary@gmail.com>
# You can redistribute it and/or modify it under GPL2 or any later version.
#

if /\A(?:form|preview|append|edit|update)\z/ =~ @mode
	add_header_proc do
		%Q|<link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css"/>|
	end

	enable_js('//ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js')
	enable_js('caretposition.js')
	enable_js('category_autocomplete.js')

	if @categories.size > 0
		categories_json = @categories.map{ |c| "\"#{c}\"" }
		add_js_setting('$tDiary.plugin.category_autocomplete')
		add_js_setting('$tDiary.plugin.category_autocomplete.candidates',
			"[#{categories_json.join(",")}]")
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
