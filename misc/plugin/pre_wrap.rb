#
# pre_wrap.rb: word wrapping style for preformat (<pre>)
#
# Copyright (C) 2010 TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2 or any later version.
#
add_header_proc do
	<<-STYLE
		<style type="text/css"><!--
			div.section pre, div.commentbody a {
				white-space: -moz-pre-wrap;
				white-space: -pre-wrap;
				white-space: -o-pre-wrap;
				white-space: pre-wrap;
				word-wrap: break-word;
			}
		--></style>
	STYLE
end
