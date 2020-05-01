#
# 01purge_cache.rb: trigger purging caches by update diary or comment
#
# Copyright (C) 2020, TADA Tadashi <t@tdtds.jp>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# usage: 
#   add_purge_cache_proc do |pages|
#      pages.each do |page|
#         purge_cache_on_a_cdn(base_url + page)
#      end
#   end
#
@purge_cache_procs = []

def add_purge_cache_proc(&proc)
	@purge_cache_procs << proc
end

add_update_proc do
	unless @purge_cache_procs.empty?
		@purge_cache_procs.empty?
		date = @date.strftime('%Y%m%d')
		days = @diaries.keys.sort
		diary = @diaries[date]
		categories = []
		diary.each_section do |section|
			categories += section.categories
		end
		pages = [
			anchor("#{@date.strftime('%Y%m%d')}"),
			anchor("#{@date.strftime('%m%d')}"),
			anchor("#{@date.strftime('%Y%m')}"),
			(0...@conf.latest_limit).map{|i|
				days[days.index(date)+i]
			}.compact.map{|day|
				anchor("#{day}-#{@conf.latest_limit}")
			},
			categories.map{|c| "?category=#{c}"}
		].flatten
		@purge_cache_procs.each{|proc| proc.call(pages)}
	end
end
