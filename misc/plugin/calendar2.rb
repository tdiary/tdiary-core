# calendar2.rb
#
# calendar2: add calendar as table layout.
#   parameter:
#     days_format: Array of weekday name stats with Sunday. (optional)
#     navi_format: Array of navigation label on top of calendar. (optional)
#     show_todo:   You can write todo list into future diary as hidden with a
#                  subtitle. if calendar2 find this parameter string in future
#                  diary, it popup your todo. (optional)
#
#   options:
#     calendar2.show_image: true or false. show a image that makes by image.rb
#                  on each date. default is falase, and use only non secure mode.
#                  and if you want to change image size, add CSS to your theme.
#                  for example (25x25 pixel image):
#
#                      td.calendar-day img {
#                         width: 25px;
#                         height: 25px;
#                         border: 0;
#                      }
#
# Copyright (c) 2001,2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
@calendar2_image_dir = @options && @options['image.dir'] || './images/'
@calendar2_image_dir.chop! if /\/$/ =~ @calendar2_image_dir
@calendar2_image_url = @options && @options['image.url'] || "#{base_url}images/"
@calendar2_image_url.chop! if /\/$/ =~ @calendar2_image_url
@calendar2_imageex_yearlydir = @options && @options['image_ex.yearlydir'] || 0
@calendar2_show_image = @options && @options['calendar2.show_image'] || false

def calendar2_make_cal(year, month)
	result = []
	t = Time.local(year, month, 1)
	r = Array.new(t.wday, nil)
	r << 1
	2.upto(31) do |i|
		break if Time.local(year, month, i).month != month
		r << i
	end
	r += Array.new((- r.size) % 7, nil)
	0.step(r.size - 1, 7) do |i|
		result << r[i, 7]
	end
	result
end

def calendar2_prev_current_next
	yyyymm = if /^(latest|search)$/ =~ @mode
					Time.now
				else
					@date
				end.strftime "%Y%m"
	yms = [yyyymm]
	@years.keys.each do |y|
		yms |= @years[y].collect {|i| y + i}
	end
	yms.sort!
	yms.unshift nil
	yms.push nil
	i = yms.index(yyyymm)
	yms[i - 1, 3]
end

def calendar2_make_anchor(ym, str)
	if ym
		%Q|<a href="#{h @index}#{anchor ym}">#{str}</a>|
	else
		str
	end
end

def calender2_make_image(diary, date)
	f_list = []

	/[^_]image(?:_left|_right|_gps)?\s*\(?\s*([0-9]*)\s*\,?\s*'[^']*'/ =~ diary.to_s
	if $1 == nil
		return nil
	end

	image_dir = (@calendar2_imageex_yearlydir == 0 ? @calendar2_image_dir : %Q|#{@calendar2_image_dir}/#{date[0,4]}|)
	image_url = (@calendar2_imageex_yearlydir == 0 ? @calendar2_image_url : %Q|#{@calendar2_image_url}/#{date[0,4]}|)

	f_list = Dir.glob(%Q|#{image_dir}/#{date}_#{$1}*|.untaint)
	if f_list[0]
		file = File.basename(f_list[0])
		file = %Q|s#{file}| if File.exist?(%Q|#{image_dir}/s#{file}|.untaint)
		%Q|<img src="#{image_url}/#{file}">|
	else
		nil
	end
end

def calendar2(days_format = nil, navi_format = nil, show_todo = nil)
 	days_format ||= @calendar2_days_format
	navi_format ||= @calendar2_navi_format

	return '' if /TAMATEBAKO/ =~ @cgi.user_agent
	date = if /^(latest|search)$/ =~ @mode
				Time.now
			else
				@date
			end
	year = date.year
	month = date.month
	p_c_n = calendar2_prev_current_next

	result = <<CALENDAR_HEAD
<table class="calendar" summary="calendar">
<tr>
 <td class="image" colspan="7"></td>
</tr>
<tr>
 <td class="calendar-prev-month" colspan="2">#{calendar2_make_anchor(p_c_n[0], navi_format[0] % [year, month])}</td>
 <td class="calendar-current-month" colspan="3">#{calendar2_make_anchor(p_c_n[1], navi_format[1] % [year, month])}</td>
 <td class="calendar-next-month" colspan="2">#{calendar2_make_anchor(p_c_n[2], navi_format[2] % [year, month])}</td>
</tr>
CALENDAR_HEAD
	result << "<tr>"
	result << %Q| <td class="calendar-sunday">#{days_format[0]}</td>\n|
	1.upto(5) do |i|
		result << %Q| <td class="calendar-weekday">#{days_format[i]}</td>\n|
	end
	result << %Q| <td class="calendar-saturday">#{days_format[6]}</td>\n|
	result << "</tr>\n"
	calendar2_make_cal(year, month).each do |week|
		result << "<tr>\n"
		week.each do |day|
			if day == nil
				result << %Q| <td class="calendar-day"></td>\n|
			else
				date = "%04d%02d%02d" % [year, month, day]
				result << %Q| <td class="calendar-day">%s</td>\n| %
					if @diaries[date] == nil
						day.to_s
					elsif ! @diaries[date].visible?
						if show_todo
							todos = []
							@diaries[date].each_section do |section|
								if show_todo === section.subtitle
									todos << section.body
								end
							end
							if todos.size != 0
								%Q|<a title="#{h todos.join( "\n" )}"><span class="calendar-todo">#{day}</span></a>|
							else
								day.to_s
							end
						else
							day.to_s
						end
					else
						subtitles = []
						idx = "01"
						@diaries[date].each_section do |section|
							if section.subtitle
								text = section.subtitle_to_html
							else
								text = section.body_to_html
							end
							subtitles << h( %Q|#{idx}. #{@conf.shorten(apply_plugin( text, true ))}| )
							idx.succ!
						end
						day_img = ((@calendar2_show_image and !@conf.secure) ? calender2_make_image(@diaries[date], date) : day.to_s)
						day_img = day.to_s if day_img == nil
            %Q|<a href="#{h @index}#{anchor date}" title="#{subtitles.join("&#13;&#10;")}">#{day_img}</a>|
					end
			end
		end
		result << "</tr>\n"
	end
	result << "</table>\n"
end

#@calendar2_cache = CacheMonth.new(@date, :calender2, method(:calendar2))
#add_update_proc @calendar2_cache.writer

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
