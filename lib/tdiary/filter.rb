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

			def initialize( request, conf )
				if request.respond_to?( :cgi_compat )
					@request = request
					# filter subclasses read the request through the @cgi facade
					@cgi = request.cgi_compat
				else
					# transitional: 60sf.rb constructs spam filters with the
					# @cgi facade handed to plugins
					@cgi = request
					@request = request.respond_to?( :request ) ? request.request : nil
				end
				@conf = conf

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
