# edit.rb $Revision: 1.1 $
#
# navi_admin: 日毎表示で「更新」を「編集」に置き換える。その日の日記を
#             すぐに編集できます。このファイルをpluginにコピーするだけ
#             で自動的に置き変わります。
#
def navi_admin
	if @mode == 'day' then
		result = %Q[<span class="adminmenu"><a href="#{@update}?edit=true;year=#{@date.year};month=#{@date.month};day=#{@date.day}">編集</a></span>\n]
	else
		result = %Q[<span class="adminmenu"><a href="#{@update}">更新</a></span>\n]
	end
	result << %Q[<span class="adminmenu"><a href="#{@update}?conf=OK">設定</a></span>\n] if /^(latest|month|day|comment)$/ !~ @mode
	result
end
