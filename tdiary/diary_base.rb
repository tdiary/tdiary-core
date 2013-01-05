#
# module DiaryBase
#  Base module of Diary.
#
module TDiary
	module SectionBase
		def body
			@body.dup
		end

		def body=(str)
			@body = str
		end

		def html4(date, idx, opt)
			r = %Q[<div class="section">\n]
			r << %Q[<%=section_enter_proc( Time.at( #{date.to_i} ) )%>\n]
			r << do_html4( date, idx, opt )
			r << %Q[<%=section_leave_proc( Time.at( #{date.to_i} ) )%>\n]
			r << "</div>\n"
		end

		def chtml(date, idx, opt)
			r = %Q[<%=section_enter_proc( Time.at( #{date.to_i} ) )%>\n]
			r << do_html4( date, idx, opt )
			r << %Q[<%=section_leave_proc( Time.at( #{date.to_i} ) )%>\n]
		end

		def to_s
			to_src
		end

		def categories_to_string
			@categories = categories
			cat_str = ""
			categories.each {|cat| cat_str << "[#{cat}]"}
			cat_str << " " unless cat_str.empty?
		end
	end

	module DiaryBase
		include ERB::Util
		include CommentManager
		include RefererManager

		def init_diary
			init_comments
			init_referers
			@show = true
		end

		def date
			@date
		end

		def set_date( date )
			if date.class == String then
				y, m, d = date.scan( /^(\d{4})(\d\d)(\d\d)$/ )[0]
				raise ArgumentError::new( 'date string needs YYYYMMDD format.' ) unless y
				@date = Time::local( y, m, d )
			else
				@date = date
			end
		end

		def title
			@title || ''
		end

		def set_title( title )
			@title = title
			@last_modified = Time::now
		end

		def show( s )
			@show = s
		end

		def visible?
			@show != false;
		end

		def last_modified
			@last_modified ? @last_modified : Time::at( 0 )
		end

		def last_modified=( lm )
			@last_modified  = lm
		end

		def eval_rhtml( opt, path = '.' )
			ERB::new( File::open( "#{path}/skel/#{opt['prefix']}diary.rhtml" ){|f| f.read }.untaint ).result( binding )
		end
	end

	#
	# module CategorizableDiary
	#
	module CategorizableDiary
		def categorizable?; true; end
	end

	#
	# module UncategorizableDiary
	#
	module UncategorizableDiary
		def categorizable?; false; end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
