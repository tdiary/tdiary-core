# -*- coding: utf-8; -*-
#
# class IOBase
#  base of IO class
#
require 'fileutils'

module TDiary
	class BaseIO
		def initialize( tdiary )
			@tdiary = tdiary
			@data_path = @tdiary.conf.data_path if @tdiary.conf.data_path
			load_styles
		end

		def calendar
			raise StandardError, 'not implemented'
		end

		def transaction(date)
			raise StandardError, 'not implemented'
		end

		def diary_factory(date, title, body, style_name = 'tDiary')
			style(style_name.downcase).new(date, title, body)
		end

		def cache_dir
			raise StandardError, 'not implemented'
		end

		def cache_path
			@_cache_path ||= cache_dir.untaint
			FileUtils.mkdir_p(@_cache_path)
			@_cache_path
		end

		def load_styles
			@styles = {}
			paths = @tdiary.conf.options['style.path'] ||
				[TDiary::PATH, TDiary.server_root].map {|base| "#{base}/tdiary/style" }
			[paths].flatten.uniq.each do |path|
				path = path.sub(/\/+$/, '').untaint
				Dir.glob("#{path}/*.rb") {|style_file| require style_file.untaint }
			end
			(["tdiary", "wiki"] + [@tdiary.conf.style]).flatten.uniq.each do |style|
				@styles[style] = TDiary::Style.const_get("#{style.capitalize}Diary")
			end
		end

		def style(s)
			unless @styles
				raise BadStyleError, "styles are not loaded"
			end
			r = @styles[s.downcase]
			unless r
				raise BadStyleError, "bad style: #{s}"
			end
			r
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
