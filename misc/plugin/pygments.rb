#
# pygments.rb: insert CSS for html formatted code with Pygments.
#
# Copyright (C) 2012 SHIBATA Hiroshi <shibata.hiroshi@gmail.com>
# You can redistribute it and/or modify it under GPL2.
#
require 'pygments'

add_header_proc do
	<<-STYLE
		<style type="text/css"><!--
		#{Pygments.css('.highlight')}
    .highlight { background: white; }
		--></style>
	STYLE
end
