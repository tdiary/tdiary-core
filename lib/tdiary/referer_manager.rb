# -*- coding: utf-8; -*-
#
# module RefererManager
#	Management referers in a day. Include in Diary class.
#

module TDiary
	module RefererManager
		private
		#
		# call this method when initialize
		#
		def init_referers
			@referers = {}
			@new_referer = true # for compatibility
		end

		public
		def add_referer( ref, count = 1 )
			newer_referer
			ref = ref.sub( /#.*$/, '' ).sub( /\?\d{8}$/, '' )
			if /^([^:]+:\/\/)([^\/]+)/ =~ ref
				ref = $1 + $2.downcase + $'
			end
			begin
				uref = CGI::unescape( ref )
			rescue ::Encoding::CompatibilityError
				return
			end
			if pair = @referers[uref] then
				pair = [pair, ref] if pair.class != Array # for compatibility
				@referers[uref] = [pair[0] + count, pair[1]]
			else
				@referers[uref] = [count, ref]
			end
		end

		def clear_referers
			@referers = {}
		end

		def count_referers
			@referers.size
		end

		def each_referer( limit = 10 )
			newer_referer
			# dirty workaround to avoid recursive sort that
			# causes SecurityError in @secure=true
			# environment since
			# http://svn.ruby-lang.org/cgi-bin/viewvc.cgi?view=rev&revision=16081
			@referers.values.sort_by{|e| "%08d_%s" % e}.reverse.each_with_index do |ary,idx|
				break if idx >= limit
				yield ary[0], ary[1]
			end
		end

		private
		def newer_referer
			unless @new_referer then # for compatibility
				@referers.keys.each do |ref|
					count = @referers[ref]
					if count.class != Array then
						@referers.delete( ref )
						@referers[CGI::unescape( ref )] = [count, ref]
					end
				end
				@new_referer = true
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
