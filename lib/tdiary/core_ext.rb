require 'emot'

module TDiary
	module RequestExtension
		# backward compatibility, returns NOT mobile phone always
		def mobile_agent?
			false
		end

		# backward compatibility, returns NOT smartphone always
		def smartphone?
			false
		end
	end
end

=begin
== String class
enhanced String class
=end
class String
	def make_link
		r = %r<(((http[s]{0,1}|ftp)://[\(\)%#!/0-9a-zA-Z_$@.&+-,'"*=;?:~-]+)|([0-9a-zA-Z_.-]+@[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+\.[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+))>
		return self.
			gsub( / /, "\001" ).
			gsub( /</, "\002" ).
			gsub( />/, "\003" ).
			gsub( /&/, '&amp;' ).
			gsub( /\"/, "\004").
			gsub( r ){ $1 == $2 ? "<a href=\"#$2\">#$2</a>" : "<a href=\"mailto:#$4\">#$4</a>" }.
			gsub( /\004/, '&quot;' ).
			gsub( /\003/, '&gt;' ).
			gsub( /\002/, '&lt;' ).
			gsub( /^\001+/ ) { $&.gsub( /\001/, '&nbsp;' ) }.
			gsub( /\001/, ' ' ).
			gsub( /\t/, '&nbsp;' * 8 )
	end

	def emojify
		self.to_str.gsub(/:([a-zA-Z0-9_+-]+):/) do |match|
			emoji_alias = $1.downcase
			emoji_url = %Q[<img src='//www.webpagefx.com/tools/emoji-cheat-sheet/graphics/emojis/%s.png' width='20' height='20' title='%s' alt='%s' class='emoji' />]
			if emoji_alias == 'plus1' or emoji_alias == '+1'
				emoji_url % (['plus1']*3)
			elsif Emot.unicode(emoji_alias)
				emoji_url % ([CGI.escape(emoji_alias)]*3)
			else
				match
			end
		end
	end
end

require 'tdiary/cgi_compat'

# the @cgi facade for Rack-hosted requests. Kept as a toplevel constant
# because plugins switch behaviour with @cgi.is_a?(RackCGI).
class RackCGI < TDiary::CGICompat; end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
