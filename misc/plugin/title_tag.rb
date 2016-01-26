# Copyright (c) 2003 URABE Shyouhei <root@mput.dip.jp>
#
# Permission is hereby granted, free of  charge, to any person obtaining a copy
# of  this code, to  deal in  the code  without restriction,  including without
# limitation  the rights  to  use, copy,  modify,  merge, publish,  distribute,
# sublicense, and/or sell copies of the code, and to permit persons to whom the
# code is furnished to do so, subject to the following conditions:
#
#     The above copyright notice and this permission notice shall be
#     included in all copies or substantial portions of the code.
#
# THE  CODE IS  PROVIDED "AS  IS",  WITHOUT WARRANTY  OF ANY  KIND, EXPRESS  OR
# IMPLIED,  INCLUDING BUT  NOT LIMITED  TO THE  WARRANTIES  OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE  AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS  OR COPYRIGHT  HOLDERS  BE LIABLE  FOR  ANY CLAIM,  DAMAGES OR  OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF  OR IN CONNECTION WITH  THE CODE OR THE  USE OR OTHER  DEALINGS IN THE
# CODE.

# title_tag2.rb to enhance <title> element of generating HTML
# $Id: title_tag.rb,v 1.6 2008-03-02 09:01:45 kazuhiko Exp $
# To use, just put this file into plugin folder.

alias :title_tag2 :title_tag

module ::TDiary
	module Style
		module BaseDiary
			def all_subtitles_to_html
				titles = Array.new
				each_section do |section|
					titles << (section.subtitle_to_html || '').strip
				end
				return titles
			end

			def all_stripped_subtitles_to_html
				return all_subtitles_to_html unless categorizable?
				titles = Array.new
				each_section do |section|
					titles << (section.stripped_subtitle_to_html || '').strip
				end
				return titles
			end
		end
	end
end

def title_tag
	if @mode == 'day' and diary = @diaries[@date.strftime('%Y%m%d')] then
		if !diary.visible? then
			return title_tag2
		end
		site_title = title_tag2.gsub( /<.*?>/, '')
		day_title = ''
		if  !diary.title.empty? then
			day_title << apply_plugin(diary.title, true) << ':'
		end
		t2 = ''
		if @plugin_files.grep(/\/category.*\.rb$/).empty? then
			t2 << diary.all_subtitles_to_html.delete_if{|s|s.size == 0}.join(', ')
		else
			t2 << diary.all_stripped_subtitles_to_html.delete_if{|s|s.size == 0}.join(', ')
		end
		sub_part = "#{h day_title} #{@conf.shorten(apply_plugin(t2, true))}"
		if sub_part.size <= 1
			return "<title>#{h( site_title )}</title>"
		else
			return "<title>#{sub_part} - #{h( site_title )}</title>"
		end
	elsif @mode == 'categoryview' then
		return @conf.shorten("<title>#{h( @html_title )}#{h( category_title() )}</title>")
	else
		return title_tag2
	end
end

# Local Variables:
# mode: ruby
# code: utf-8
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# fill-column: 79
# default-justification: full
# End:
# vi: ts=3 sw=3
