=begin
= emptDiary style((-$Id: emptdiary_style.rb,v 1.1 2003-02-18 01:38:04 tadatadashi Exp $-))

== Summary
This style is an extension to the tDiary style which allows plug-in
arguments to have empty lines. In short, this style preserves empty
lines between <% and %> when splltting the input into sections.

The latest version of this file shall be downloaded from
((<URL:http://zunda.freeshell.org/d/tdiary/emptdiary_style.rb>)).

== Usage
if you want to use this style, add the following line into tdiary.conf:
  @style = 'emptdiary'
Please see  emptdiary_style.rd.ja or emptdiary_style.rd.en for further
explanation.

== Acknowledgements
This style is realized using TdiarySection and TdiaryDiary as
super-classes. I thank the authors of tdiary_style.rb for providing such
flexible classes.

== Copyright
Copyright 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution,
and distribution of modified versions of this work under the terms
of GPL version 2 or later.                                                  
=end
=begin ChangeLog
* Mon Feb 17, 2003 zunda <zunda at freeshell.org>
- copied from zunda_style.rb, with which I used for preliminary tests.
=end
 
require 'tdiary/tdiary_style'

module TDiary
	class EmptdiarySection < TdiarySection
		def initialize( fragment, author = nil )
			@author = author
			lines = fragment.split( /\n/, 2 )
                        # we only have to divide the text into title and body
			if lines.size > 1 then
				if /^<</ =~ lines[0]
					@subtitle = lines.shift.chomp.sub( /^</, '' )
				elsif /^[¡¡ <]/e !~ lines[0]
					@subtitle = lines.shift.chomp
				end
			end
			@body = lines.join( "\n" )
			@categories = get_categories
			@stripped_subtitle = strip_subtitle
		end
	end

	class EmptdiaryDiary < TdiaryDiary
		def style
		  'emptdiary'
		end
	
		def append( body, author = nil )
                        # first make an array of sections
			sections = Array.new
			fragment = ''
			nest = 0
			remain = (body.gsub("\r", '')+"\n\n").gsub(/.*?(\n\n+|<%|%>)/m) do
				fragment += $&
				case $1
				when '<%'
					nest += 1
				when '%>'
					nest -= 1
				else
					if nest == 0 then
						fragment.sub! (/\n+\z/, '')
						sections << fragment unless fragment.empty?
						fragment = ''
					end
				end
				''
			end
			fragment += remain
			fragment.sub! (/\n+\z/, '')
			sections << fragment unless fragment.empty?
                        # add the sections to the diary
			sections.each do |fragment|
				section = EmptdiarySection::new( fragment, author )
				@sections << section if section
			end
			@last_modified = Time::now
			self
		end
	end
end
