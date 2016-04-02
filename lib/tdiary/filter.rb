#
# module/class Filter
#
module TDiary
	module Filter
		class Filter
			include ViewHelper

			DEBUG_NONE = 0
			DEBUG_SPAM = 1
			DEBUG_FULL = 2

			def initialize( cgi, conf )
				@cgi, @conf = cgi, conf

				if @conf.options.include?('filter.debug_mode')
					@debug_mode = @conf.options['filter.debug_mode']
				else
					@debug_mode = DEBUG_NONE
				end
			end

			def comment_filter( diary, comment )
				true
			end

			def referer_filter( referer )
				true
			end

			def debug( msg, level = DEBUG_SPAM )
				return if @debug_mode == DEBUG_NONE
				return if @debug_mode == DEBUG_SPAM and level == DEBUG_FULL

				TDiary.logger.info("#{@cgi.remote_addr}->#{(@cgi.params['date'][0] || 'no date').dump}: #{msg}")
			end
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
