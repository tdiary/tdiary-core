# -*- coding: utf-8 -*-
# dropdown_calendar.rb
#
# calendar: カレンダーをドロップダウンリストに置き換えるプラグイン
#   パラメタ: なし
#
# 	Copyright (C) 2003 TADA Tadashi
#	You can redistribute it and/or modify it under GPL2 or any later version.
#

@dropdown_calendar_label = '過去の日記' unless @resource_loaded

def calendar
	result = %Q[<form method="get" action="#{h @index}">\n]
	result << %Q[<div class="calendar">#{@conf.options['dropdown_calendar.label'] || @dropdown_calendar_label}\n]
	result << %Q[<select name="date">\n]
	@years.keys.sort.reverse_each do |year|
		@years[year.to_s].sort.reverse_each do |month|
			result << %Q[<option value="#{year}#{month}">#{year}-#{month}</option>\n]
		end
	end
	result << "</select>\n"
	result << %Q[<input type="submit" value="Go">\n]
	result << "</div>\n</form>"
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
