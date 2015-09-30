# -*- coding: utf-8 -*-
#
# comment_emoji_autocomplete.rb : Support the automatic input of the emoji
#                                 using jQuery UI autocomplete.
#
# Copyright (C) 2013, tamoot <tamoot+tdiary@gmail.com>
# You can redistribute it and/or modify it under GPL2 or any later version.
#

if /\A(?:day)\z/ =~ @mode
	add_header_proc do
		%Q|<link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css"/>|
	end

	enable_js('//ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js')
	enable_js('caretposition.js')
	enable_js('comment_emoji_autocomplete.js')
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
