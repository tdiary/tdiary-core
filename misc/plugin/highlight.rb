#
# highlight.rb: Highlighting the element jumped from other pages.
#
# Copyright (C) 2003 by Ryuji SAKAI
# Copyright (C) 2003 by Kazuhiro NISHIYAMA
# You can redistribute it and/or modify it under GPL2.
#

title = (@conf.html_title.gsub(/\\/, '\\\\\\') || '').gsub(/"/, '\\"')
add_js_setting('$tDiary.title', %Q|"#{title}(#{@date.strftime('%Y-%m-%d')})"|)

if @mode == 'day' and not bot? then
	enable_js('highlight.js')
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vi: ts=3 sw=3
