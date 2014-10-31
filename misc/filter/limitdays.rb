# -*- coding: utf-8; -*-
#
# limitdays.rb:
#
# Copyright (C) SHIBATA Hiroshi <shibata.hiroshi@gmail.com> 2008.
# Distributed under GPL2 or any later version.
#

module TDiary::Filter
	class LimitdaysFilter < Filter
		def comment_filter( diary, comment )
			if @conf.options.include?('spamfilter.date_limit') &&
					@conf.options['spamfilter.date_limit'] &&
					/\A\d+\z/ =~ @conf.options['spamfilter.date_limit'].to_s
				@date_limit = @conf.options['spamfilter.date_limit'].to_s.to_i
			else
				@date_limit = nil
			end

			if @date_limit
				now = Time.now
				today = Time.local(now.year, now.month, now.day)
				limit = today - 24 * 60 * 60 * @date_limit
				if diary.date < limit
					debug( "too old: #{diary.date} (limit >= #{limit})" )
					comment.show = false
					return false
				end
			end
			return true
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
