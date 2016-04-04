#
# module CommentManager
#	 Management comments in a day. Include in Diary class.
#
module TDiary
	module CommentManager
		private
		#
		# call this method when initialize
		#
		def init_comments
			@comments = []
		end

		public
		def add_comment( com )
			@comments << com
			if not @last_modified or @last_modified < com.date
				@last_modified = com.date
			end
			com
		end

		def count_comments( all = false )
			i = 0
			@comments.each do |comment|
				i += 1 if all or comment.visible?
			end
			i
		end

		def each_comment( limit = -1 )
			@comments.each_with_index do |com,idx|
				break if idx >= limit and limit >= 0
				yield com
			end
		end

		def each_comment_tail( limit = 3 )
			idx = 0
			comments = @comments.collect {|c|
				idx += 1
				if c.visible? then
					[c, idx]
				else
					nil
				end
			}.compact
			s = comments.size - limit
			s = 0 if s < 0
			for idx in s...comments.size
				yield comments[idx][0], comments[idx][1] # idx is start with 1.
			end
		end

		def each_visible_comment( limit = -1 )
			@comments.each_with_index do |com,idx|
				break if idx >= limit and limit >= 0
				next unless com.visible?
				yield com,idx+1 # idx is start with 1.
			end
		end

		def each_visible_trackback( limit = -1 )
			i = 0
			@comments.each do |com|
				break if i >= limit and limit >= 0
				next unless /^TrackBack$/ =~ com.name
				next unless com.visible_true?
				i += 1
				yield com, i
			end
		end

		def each_visible_trackback_tail( limit = 3 )
			i = 0
			@comments.find_all {|com|
				com.visible_true? and /^TrackBack$/ =~ com.name
			}.reverse[0,limit].reverse.each do |com|
				i += 1 # i starts with 1.
				yield com,i
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
