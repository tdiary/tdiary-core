# -*- coding: utf-8; -*-
#
# class Comment
#	Management a comment.
#
module TDiary
	class Comment
		attr_reader :name, :mail, :body, :date

		def initialize( name, mail, body, date = Time::now )
			@name, @mail, @body, @date = name, mail, body, date
			@show = true
		end

		def shorten( length = 120 )
			matched = body.gsub( /\n/, ' ' ).scan( /^.{0,#{length - 2}}/u )[0]

			unless $'.empty? then
				matched + '..'
			else
				matched
			end
		end

		def visible?; @show; end
		def show=( s ); @show = s; end

		def ==( c )
			(@name == c.name) and (@mail == c.mail) and (@body == c.body)
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
