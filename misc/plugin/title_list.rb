# -*- coding: utf-8 -*-
# titile_list.rb
#
# title_list: 現在表示している月のタイトルリストを表示
#   パラメタ(カッコ内は未指定時の値):
#     rev:       逆順表示(false)
#
# 備考: タイトルリストを日記に埋め込むには、レイアウトを工夫しなければ
# なりません。ヘッダやフッタでtableタグを使ったり、CSSを書き換える必
# 要があるでしょう。
#
# Copyright (c) 2005 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL2 or any later version.
#
def title_list( rev = false )
	result = %Q|<ul class="title-list">\n|
	keys = @diaries.keys.sort
	keys = keys.reverse if rev
	keys.each do |date|
		next unless @diaries[date].visible?
		result << %Q[<li><a href="#{h( @index )}#{h anchor( date )}">#{h( @diaries[date].date.strftime( @date_format ) )}</a>\n\t<ul class="title-list-item">\n]
		if !@plugin_files.grep(/\/category.rb$/).empty? and @diaries[date].categorizable?
			@diaries[date].each_section do |section|
				result << %Q[\t<li>#{section.stripped_subtitle_to_html}</li>\n] if section.stripped_subtitle
			end
		else
			@diaries[date].each_section do |section|
				result << %Q[<li>#{section.subtitle_to_html}</li>\n] if section.subtitle
			end
		end
		result << "\t</ul>\n</li>\n"
	end
	apply_plugin( result << "</ul>\n" )
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
