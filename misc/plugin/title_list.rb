# titile_list.rb $Revision: 1.1 $
#
# title_list: 現在表示している月のタイトルリストを表示
#   パラメタ: なし
#
# 備考: タイトルリストを日記に埋め込むは、レイアウトを工夫しなければ
# なりません。ヘッダやフッタでtableタグを使ったり、CSSを書き換える必
# 要があるでしょう。
#
def title_list( rev = false )
	result = ''
	keys = @diaries.keys.sort
	keys = keys.reverse if rev
	keys.each do |date|
		result << %Q[<p class="recentitem"><a href="#{@index}?date=#{date}">#{@diaries[date].date.strftime( @date_format )}</a></p>\n<div class="recentsubtitles">\n]
		@diaries[date].each_paragraph do |paragraph|
			result << %Q[#{paragraph.subtitle}<br>\n] if paragraph.subtitle
		end
		result << "</div>\n"
	end
	result
end

