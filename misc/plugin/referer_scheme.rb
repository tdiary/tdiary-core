=begin
= Meta-scheme plugin((-$Id: referer_scheme.rb,v 1.9 2005-07-23 08:07:52 zunda Exp $-))
Enables to prefix `meta' schemes to URL regexp of the refer_table. See
#{lang}/referer_scheme.rb for a documentation.

== Copyright
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL version 2 or later.
=end

unless @conf.referer_table.respond_to?( 'scheme_ymd', true ) then
	class << @conf.referer_table
		private
		def scheme_ymd( url, name )
			[
				['.*?(\d{4})[-/]?(\d{2})[-/]?(\d{2}).*', '(\1-\2-\3)'],
				['.*?(\d{4})[-/]?(\d{2}).*', '(\1-\2)'],
				['.*?(\d{2})[-/]?(\d{2}).*', '(\1-\2)'],
				['(.+)', '(\1)'],
			].each do |path, date|
				yield( url + path, name + date )
			end
			yield( url, name )
		end
	end
end

unless @conf.referer_table.respond_to?( 'scheme_tdiary', true ) then
	class << @conf.referer_table
		TdiaryDates = [
				['(?:\\?date=)?(\d{4})(\d{2})(\d{2})-(\d+)(?:\.html)?.*', '(\1-\2-\3~)'],
				['(?:\\?date=)?(\d{4})(\d{2})(\d{2})(?:\.html)?.*', '(\1-\2-\3)'],
				['(?:\\?date=)?(\d{4})(\d{2})(?:\.html)?.*', '(\1-\2)'],
				['(?:\\?date=)?(\d{2})(\d{2})(?:\.html)?.*', '(\1-\2)'],
		]
		private
		def scheme_tdiary( url, name )
			TdiaryDates.each do |a|
				yield( url + a[0], name + a[1] )
			end
			yield( url + '.*' , name )
		end
	end
end

unless @conf.referer_table.respond_to?( 'scheme_wiki', true ) then
	class << @conf.referer_table
		private
		def scheme_wiki( url, name )
			['\?([^;&$]*).*', '([^/]+)\/?$'].each do |p|
				yield( "#{url}#{p}", '\1 - ' + name )
			end
			yield( url, name )
		end
	end
end

unless @conf.referer_table.respond_to?( 'referer_scheme_each_orig' ) then

	class << @conf.referer_table
		# expands referer_table according to the meta-scheme
		alias referer_scheme_each_orig each
		def each
			self.referer_scheme_each_orig do |url, name|
				/^(\w+):/ =~ url
				if $1 && self.respond_to?( "scheme_#{$1}", true ) then
					self.send( "scheme_#{$1}", $', name ) do |expanded_url, expanded_name|
						yield( expanded_url, expanded_name )
					end
				else
					yield( url, name )
				end
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
