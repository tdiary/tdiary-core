# -*- coding: utf-8 -*-
# calendar3.rb
#
# calendar3: 現在表示している月のカレンダーを表示します．
#  パラメタ: なし
#
# tdiary.confで指定するオプション:
#   @options['calendar3.show_todo']
#     パラグラフのサブサイトルとここで指定した文字列が一致し
#     かつその日の日記が非表示の場合，そのパラグラフの内容を
#     予定としてpopupする．
#
#   @options['calendar3.show_popup']
#     JavaScriptによるpopupを表示するかどうか．
#     省略時の値はtrueなので，表示したくない場合のみfalseを設定する．
#
# Copyright (c) 2001,2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL2 or any later version.
#
#
# sample CSS for calendar3
#
# .calendar-popup {
#         display: none;
#         text-align: left;
#         position: absolute;
#         border-style: solid;
#         border-width: 1px;
#         padding: 0 1ex 0 1ex;
# }
#
# .calendar-sunday {
#         color: red;
# }
#
# .calendar-saturday {
#         color: blue;
# }
#
# .calendar-weekday {
#         color: black;
# }
#
# .calendar-normal {
# }
#
# .calendar-day {
#         font-weight: bold;
# }
#
# .calendar-todo {
#         border-style: solid;
#         border-color: red;
#         border-width: 1px;
# }
#
=begin ChengeLog
2003-09-25 TADA Tadashi <sho@spc.gr.jp>
	* use @conf.shorten.

2003-03-25 Junichiro Kita <kita@kitaj.no-ip.com>
	* add css to navigation links to next, current, prev month.

2003-02-27 Junichiro Kita <kita@kitaj.no-ip.com>
	* @options['calendar.show_popup']

2003-01-07 Junichiro Kita <kita@kitaj.no-ip.com>
   * append sample css

2003-01-07 MURAI Kensou <murai@dosule.com>
	* modify javascript for popdown-delay

2002-12-20 TADA Tadashi <sho@spc.gr.jp>
	* use Plugin#apply_plugin.
=end

module Calendar3
	WEEKDAY = 0
	SATURDAY = 1
	SUNDAY = 2

	STYLE = {
		WEEKDAY => "calendar-weekday",
		SATURDAY => "calendar-saturday",
		SUNDAY => "calendar-sunday",
	}

	def make_cal(year, month)
		result = []
		1.upto(31) do |i|
			t = Time.local(year, month, i)
			break if t.month != month
			case t.wday
			when 0
				result << [i, SUNDAY]
			when 1..5
				result << [i, WEEKDAY]
			when 6
				result << [i, SATURDAY]
			end
		end
		result
	end

	def prev_month(year, month)
		if month == 1
			year -= 1
			month = 12
		else
			month -= 1
		end
		[year, month]
	end

	def next_month(year, month)
		if month == 12
			year += 1
			month = 1
		else
			month += 1
		end
		[year, month]
	end

	module_function :make_cal, :next_month, :prev_month
end

def calendar3
	return '' if bot?
	show_todo = @options['calendar3.show_todo']
	show_todo = Regexp.new(show_todo) if show_todo
	result = ''
	if @options.has_key? 'calendar3.erb'
		result << %Q|<p class="message">@options['calendar3.erb'] is obsolete!<p>|
	end

	if /^(latest|search)$/ =~ @mode
		date = Time.now
	else
		date = @date
	end
	year = date.year
	month = date.month

	result << %Q|<span class="calendar-prev-month"><a href="#{h @index}#{anchor "%04d%02d" % Calendar3.prev_month(year, month)}">&lt;&lt;</a></span>\n|
	result << %Q|<span class="calendar-current-month"><a href="#{h @index}#{anchor "%04d%02d" % [year, month]}">#{"%04d/%02d" % [year, month]}</a>/</span>\n|
	#Calendar3.make_cal(year, month)[(day - num >= 0 ? day - num : 0)..(day - 1)].each do |day, kind|
	Calendar3.make_cal(year, month).each do |day, kind|
		date = "%04d%02d%02d" % [year, month, day]
		if @diaries[date].nil?
			result << %Q|<span class="calendar-normal"><a class="#{Calendar3::STYLE[kind]}">#{day}</a></span>\n|
 		elsif !@diaries[date].visible?
			todos = []
			if show_todo
				@diaries[date].each_section do |section|
					if show_todo === section.subtitle
						todos << h( section.body_to_html ).gsub( /\n/, "&#13;&#10;" )
					end
				end
			end
			if todos.size != 0
				result << %Q|<span class="calendar-todo"><a class="#{Calendar3::STYLE[kind]}" title="#{day}日の予定:&#13;&#10;#{todos.join "&#13;&#10;"}">#{day}</a></span>\n|
			else
				result << %Q|<span class="calendar-normal"><a class="#{Calendar3::STYLE[kind]}">#{day}</a></span>\n|
			end
		else
			if @calendar3_show_popup
				result << %Q|<span class="calendar-day" id="target-#{day}" onmouseover="popup(document.getElementById('target-#{day}'),document.getElementById('popup-#{day}'), document.getElementById('title-#{day}'));" onmouseout="popdown(document.getElementById('popup-#{day}'));">\n|
			else
				result << %Q|<span class="calendar-day" id="target-#{day}">\n|
			end
			result << %Q|  <a class="#{Calendar3::STYLE[kind]}" id="title-#{day}" title="|
			i = 1
			r = []
			if !@plugin_files.grep(/\/category.rb$/).empty? and @diaries[date].categorizable?
				@diaries[date].each_section do |section|
					if section.stripped_subtitle
						text = apply_plugin( section.stripped_subtitle_to_html, true )
						r << %Q|#{i}. #{h text}|
					end
					i += 1
				end
			else
				@diaries[date].each_section do |section|
					if section.subtitle
						text = apply_plugin( section.subtitle_to_html, true )
						r << %Q|#{i}. #{h text}|
					end
					i += 1
				end
			end
			result << r.join("&#13;&#10;")
			result << %Q|" href="#{h @index}#{anchor date}">#{day}</a>\n|
			if @calendar3_show_popup
				result << %Q|  <span class="calendar-popup" id="popup-#{day}">\n|
				i = 1
				if !@plugin_files.grep(/\/category.rb$/).empty? and @diaries[date].categorizable?
					@diaries[date].each_section do |section|
						if section.stripped_subtitle
							text = apply_plugin( section.body_to_html, true )
							subtitle = apply_plugin( section.stripped_subtitle_to_html )
							result << %Q|    <a href="#{h @index}#{anchor "%s#p%02d" % [date, i]}" title="#{h @conf.shorten( text )}">#{i}</a>. #{subtitle}<br>\n|
						end
						i += 1
					end
				else
					@diaries[date].each_section do |section|
						if section.subtitle
							text = apply_plugin( section.body_to_html, true )
							subtitle = apply_plugin( section.subtitle_to_html )
							result << %Q|    <a href="#{h @index}#{anchor "%s#p%02d" % [date, i]}" title="#{h @conf.shorten( text )}">#{i}</a>. #{subtitle}<br>\n|
						end
						i += 1
					end
				end
				result << %Q|  </span>\n|
			end
			result << %Q|</span>\n|
		end
	end
	result << %Q|<span class="calendar-next-month"><a href="#{h @index}#{anchor "%04d%02d" % Calendar3.next_month(year, month)}">&gt;&gt;</a></span>\n|
	result
end

@calendar3_show_popup = true
if @options.has_key?('calendar3.show_popup')
	@calendar3_show_popup = @options['calendar3.show_popup']
end
if /w3m|MSIE.*Mac/ === @cgi.user_agent
	@calendar3_show_popup = false
	add_header_proc do
    <<JAVASCRIPT
  <script type="text/javascript">
  <!--
  function popup(target,element,notitle) {
  }

  function popdown(element) {
  }
  // -->
</script>
JAVASCRIPT
	end
end
if @calendar3_show_popup
	enable_js('calendar3.js')
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: set ts=3:
