# -*- coding: utf-8; -*-
#
# lazy_referer.rb: lazy loading referer
#
# Copyright (C) 2013 by MATSUOKA Kohei <kmachu@gmail.com>
# You can distribute it under GPL.
#

if @mode == 'day' and not bot? then
	enable_js('referer.js')
	add_js_setting('$tDiary.plugin.referer')
	add_js_setting('$tDiary.plugin.referer.today', referer_today.to_json)
	add_js_setting('$tDiary.plugin.referer.volatile', volatile_referer.to_json)

	#
	# overwrite method: draw only referer area (content will feach with ajax)
	#
	def referer_of_today_long( diary, limit )
		return if limit == 0
		date = diary.date.strftime('%Y%m%d')
		# FIXME: endpoint is should created by TDiary::Plugin, because easy customize routing
		endpoint = "#{@conf.index}?plugin=referer&date=#{date}"
		%Q[<div id="referer" data-date="#{h date}" data-endpoint="#{h endpoint}" class="caption">#{referer_today}</div>\n]
	end
end

def lazy_referer_to_array( diary )
	array = []
	# FIXME: referer_limit isn't correct (hard coding at skel)
	limit = 100
	diary.each_referer( limit ) do |count,href|
		array.push({
			:count => count,
			:href => href,
			:title => disp_referer( @conf.referer_table, href )
		})
	end
	array.sort! {|a,b| b[:count] <=> a[:count] }
end

#
# return referer of date as json
#
add_content_proc('referer') do |date|
	referer = { date => [], 'volatile' => [] }

	diary = @diaries[date]
	referer_load_current( diary )
	referer[date] = lazy_referer_to_array( diary )

	# TODO: return volatile referer at every diary?
	if latest_day?( diary )
		volatile = RefererDiary::new( @conf.latest_limit )
		referer_load_volatile( volatile )
		referer['volatile'] = lazy_referer_to_array ( volatile )
	end
	referer.to_json
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
