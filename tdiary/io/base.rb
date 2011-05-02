# -*- coding: utf-8; -*-
#
# class IOBase
#  base of IO class
#
module TDiary
	class BaseIO
		def calendar
			raise StandardError, 'not implemented'
		end

		def transaction( date )
			raise StandardError, 'not implemented'
		end

		def diary_factory( date, title, body, style = nil )
			raise StandardError, 'not implemented'
		end

		def styled_diary_factory( date, title, body, style_name = 'tDiary' )
			return style( style_name.downcase )::new( date, title, body )
		end

		def load_styles
			@styles = {}
			Dir::glob( "#{TDiary::PATH}/tdiary/*_style.rb" ) do |style_file|
				require style_file.untaint
				style = File::basename( style_file ).sub( /_style\.rb$/, '' )
				@styles[style] = TDiary::const_get( "#{style.capitalize}Diary" )
			end
		end

		def style( s )
			unless @styles
				raise BadStyleError, "styles are not loaded"
			end
			r = @styles[s.downcase]
			unless r
				raise BadStyleError, "bad style: #{s}"
			end
			return r
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
