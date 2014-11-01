# -*- coding: utf-8 -*-
# footnote.rb
#
# fn: 脚注plugin
#   パラメタ:
#     text: 脚注本文
#     mark: 脚注マーク('*')
#
# Copyright (C) 2007 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL2 or any later version.

# initialize variables
@fn_fragment_fm = ''
@fn_fragment_f = ''
@fn_notes = []
@fn_marks = []

add_body_enter_proc do |date|
	fn_initialize( date )
	''
end

add_section_enter_proc do |date, index|
	fn_initialize( date, index ) unless @conf.style =~ /blog/i
	''
end

def fn_initialize( date, section = 1 )
	@fn_fragment_fm = sprintf( 'fm%s-%02d-%%02d', date.strftime( '%Y%m%d' ), section )
	@fn_fragment_f = @fn_fragment_fm.sub( /^fm/, 'f' )
	@fn_notes = []
	@fn_marks = []
end

def fn( text, mark = '*' )
	@fn_notes += [text]
	@fn_marks += [mark]
	idx = @fn_notes.size

	r = %Q|<span class="footnote">|
	if feed? then
		r << %Q|#{mark}#{idx}|
	else
		r << %Q|<a |
		r << %Q|name="#{@fn_fragment_fm % idx}" |
		r << %Q|href="##{@fn_fragment_f % idx}" |
		r << %Q|title="#{h text}">|
		r << %Q|#{h mark}#{idx}|
		r << %Q|</a>|
	end
	r << %Q|</span>|
end

# print footnotes
add_section_leave_proc do |date, index|
	@conf.style =~ /blog/i ? '' : fn_put
end

add_body_leave_proc do |date|
	fn_put
end

def fn_put
	if @fn_notes.size > 0 then
		r = %Q|<div class="footnote">\n|
		@fn_notes.each_with_index do |fn, idx|
			r << %Q|\t<p class="footnote">|
			if feed? then
				r << %Q|#{h @fn_marks[idx]}#{idx+1}|
			else
				r << %Q|<a |
				r << %Q|name="#{@fn_fragment_f % (idx+1)}" |
				r << %Q|href="##{@fn_fragment_fm % (idx+1)}">|
				r << %Q|#{h @fn_marks[idx]}#{idx+1}|
				r << %Q|</a>|
			end
			r << %Q|&nbsp;#{@fn_notes[idx]}</p>\n|
		end
		@fn_notes.clear
		r << %Q|</div>\n|
	else
		''
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
