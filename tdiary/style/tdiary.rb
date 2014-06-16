# -*- coding: utf-8; -*-
#
# tdiary_style.rb: tDiary style class for tDiary 2.x format. $Revision: 1.16 $
#
# if you want to use this style, add @style into tdiary.conf below:
#
#    @style = 'tDiary'
#
# Copyright (C) 2001-2005, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2.
#
module TDiary
	module Style
		class TdiarySection
			attr_reader :subtitle, :body, :author
			attr_reader :categories, :stripped_subtitle

			alias :subtitle_to_html :subtitle
			alias :stripped_subtitle_to_html :stripped_subtitle

			def initialize( fragment, author = nil )
				@author = author
				lines = fragment.split( /\n+/ )
				if lines.size > 1 then
					if /^<</ =~ lines[0]
						@subtitle = lines.shift.chomp.sub( /^</, '' )
					elsif /^[　 <]/u !~ lines[0]
						@subtitle = lines.shift.chomp
					end
				end
				@body = lines.join( "\n" )

				@categories = get_categories
				@stripped_subtitle = strip_subtitle
			end

			def subtitle=(subtitle)
				cat_str = ""
				@categories.each {|cat|
					cat_str << "[#{cat}]"
				}
				cat_str << " " unless cat_str.empty?
				@subtitle = subtitle ? (cat_str + subtitle) : nil
				@stripped_subtitle = strip_subtitle
			end

			def body=(str)
				@body = str
			end

			def categories=(categories)
				@categories = categories
				cat_str = ""
				categories.each {|cat|
					cat_str << "[#{cat}]"
				}
				cat_str << " " unless cat_str.empty?
				@subtitle = @subtitle ? (cat_str + @stripped_subtitle) : nil
				@stripped_subtitle = strip_subtitle
			end

			def to_src
				s = ''
				if @stripped_subtitle then
					s += "[#{@author}]" if @author
					cat_str = ""
					@categories.each {|cat|
						cat_str << "[#{cat}]"
					}
					cat_str << " " unless cat_str.empty?
					s += cat_str
					s += '<' if /^</=~@subtitle
					s += @stripped_subtitle + "\n"
				else
					#s += ' ' unless @body =~ /\A\s</
				end
				"#{s}#{@body}\n\n"
			end

			def body_to_html
				html = ""
				@body.lines.each do |p|
					if p[0] == ?< then
						html = @body.dup
						break
					end
					html << "<p>#{p}</p>"
				end
				html
			end

			def to_s
				"subtitle=#{@subtitle}, body=#{@body}"
			end

			def categorized_subtitle
				@categories.collect do |c|
					%Q|<%= category_anchor("#{c}") %>|
				end.join + @stripped_subtitle.to_s
			end

			private
			def get_categories
				return [] unless @subtitle
				cat = /^(\[(.*?)\])+/.match(@subtitle).to_a[0]
				return [] unless cat
				cat.scan(/\[(.*?)\]/).collect do |c|
					c[0].split(/,/)
				end.flatten
			end

			def strip_subtitle
				return nil unless @subtitle
				@subtitle.sub( /^(\[(.*?)\])+\s*/, '' )
			end
		end

		class TdiaryDiary
			def initialize( date, title, body, modified = Time::now )
				init_diary
				replace( date, title, body )
				@last_modified = modified
			end

			def style
				'tDiary'
			end

			def append( body, author = nil )
				body.gsub( /\r/, '' ).split( /\n\n+/ ).each do |fragment|
					section = TdiarySection::new( fragment, author )
					@sections << section if section
				end
				@last_modified = Time::now
				self
			end

			def add_section(subtitle, body)
				sec = TdiarySection::new("\n\n ")
				sec.subtitle = subtitle
				sec.body     = body
				@sections << sec
				@sections.size
			end

			def to_html4( opt )
				r = ''
				each_section do |section|
					r << %Q[<div class="section">\n]
					r << %Q[<%= section_enter_proc( Time::at( #{date.to_i} ) ) %>\n]
					if section.subtitle then
						r << %Q[<h3><%= subtitle_proc( Time::at( #{date.to_i} ), #{section.subtitle.dump.gsub( /%/, '\\\\045' )} ) %></h3>\n]
					end
					if /^</ =~ section.body then
						r << %Q[#{section.body}]
					elsif section.subtitle
						r << %Q[<p>#{section.body.lines.collect{|l|l.chomp.sub( /^[　 ]/u, '')}.join( "</p>\n<p>" )}</p>\n]
					else
						r << %Q[<p><%= subtitle_proc( Time::at( #{date.to_i} ), nil ) %>]
						r << %Q[#{section.body.lines.collect{|l|l.chomp.sub( /^[　 ]/u, '' )}.join( "</p>\n<p>" )}</p>]
					end
					r << %Q[<%= section_leave_proc( Time::at( #{date.to_i} ) ) %>\n]
					r << %Q[</div>]
				end
				r
			end

			def to_chtml( opt )
				r = ''
				each_section do |section|
					r << %Q[<%= section_enter_proc( Time::at( #{date.to_i} ) ) %>\n]
					if section.subtitle then
						r << %Q[<H3><%= subtitle_proc( Time::at( #{date.to_i} ), #{section.subtitle.dump.gsub( /%/, '\\\\045' )} ) %></H3>\n]
					end
					if /^</ =~ section.body then
						r << section.body
					elsif section.subtitle
						r << %Q[<P>#{section.body.lines.collect{|l|l.chomp.sub( /^[　 ]/u, '' )}.join( "</P>\n<P>" )}</P>\n]
					else
						r << %Q[<P><%= subtitle_proc( Time::at( #{date.to_i} ), nil ) %>]
						r << %Q[#{section.body.lines.collect{|l|l.chomp.sub( /^[　 ]/u, '' )}.join( "</P>\n<P>" )}</P>\n]
					end
					r << %Q[<%= section_leave_proc( Time::at( #{date.to_i} ) ) %>\n]
				end
				r
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
