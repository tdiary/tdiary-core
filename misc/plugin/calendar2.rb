# calendar2.rb $Revision: 1.1 $
#
# calendar2: どこかで見たようなカレンダーを日記に追加する
#   パラメタ:
#     format: 曜日を現すStringから構成されるArray(未指定時:"日月火水木金土".split(//))
#
# Copyright (c) 2000-2001 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
def make_cal(year, month)
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

def prev_month(year, month)
  if month == 1
    [year - 1, 12]
  else
    [year, month - 1]
  end
end

def next_month(year, month)
  if month == 12
    [year + 1, 1]
  else
    [year, month + 1]
  end
end

def calendar2(format = "日月火水木金土".split(//))
  return '' if /TAMATEBAKO/ =~ ENV["HTTP_USER_AGENT"]
  year = @date.year
  month = @date.month  

  result = <<CALENDAR_HEAD
<table class="calendar" summary="calendar">
<tr>
 <td class="calendar-prev-month" colspan="2"><a href="#{@index}?date=#{"%04d%02d" % prev_month(year, month)}">先月</a></td>
 <td class="calendar-current-month" colspan="3"><a href="#{@index}?date=#{"%04d%02d" % [year, month]}">#{year}年<br>#{month}月</a></td>
 <td class="calendar-next-month" colspan="2"><a href="#{@index}?date=#{"%04d%02d" % next_month(year, month)}">来月</a></td>
</tr>
CALENDAR_HEAD
  result << "<tr>"
  result << %Q| <td class="calendar-sunday">#{format[0]}</td>\n|
  1.upto(5) do |i|
    result << %Q| <td class="calendar-weekday">#{format[i]}</td>\n|
  end
  result << %Q| <td class="calendar-saturday">#{format[6]}</td>\n|
  result << "</tr>\n"
  make_cal(year, month).each do |week|
    result << "<tr>\n"
    week.each do |day|
      if day == nil
        result << %Q| <td class="calendar-day"></td>\n|
      else
        date = "%04d%02d%02d" % [year, month, day]
        result << %Q| <td class="calendar-day">%s</td>\n| %
          if @diaries[date] == nil
            day.to_s
          else
            subtitles = []
            idx = "01"
            @diaries[date].each_paragraph do |paragraph|
              if paragraph.subtitle
                subtitles << %Q|#{idx}. #{CGI::escapeHTML(paragraph.subtitle.gsub(/<.+?>/, ''))}|
                idx.succ!
              end
            end
            %Q|<a href="#{@index}?date=#{date}" title="#{subtitles.join("&#13;&#10;")}">#{day}</a>|
          end
      end
    end
    result << "</tr>\n"
  end
  result << "</table>\n"
end

#@calendar2_cache = CacheMonth.new(@date, :calender2, method(:calendar2))
#add_update_proc @calendar2_cache.writer

