#
# tdiary_style.rb: tDiary style class for tDiary 2.x format. $Revision: 1.12 $
#
# if you want to use this style, add @style into tdiary.conf below:
#
#    @style = 'tDiary'
#
# Copyright (C) 2001-2005, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#
module TDiary
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
				elsif /^[　 <]/e !~ lines[0]
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
			tag = false
			@body.each do |p|
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
			r = @subtitle.sub(/^(\[(.*?)\])+\s*/,'')
			if r == ""
				nil
			else
				r
			end
		end
	end

	class TdiaryDiary
		include DiaryBase
		include CategorizableDiary
	
		def initialize( date, title, body, modified = Time::now )
			init_diary
			replace( date, title, body )
			@last_modified = modified
		end
	
		def style
			'tDiary'
		end
	
		def replace( date, title, body )
			set_date( date )
			set_title( title )
			@sections = []
			append( body )
		end
	
		def append( body, author = nil )
			body.gsub( /\r/, '' ).split( /\n\n+/ ).each do |fragment|
				section = TdiarySection::new( fragment, author )
				@sections << section if section
			end
			@last_modified = Time::now
			self
		end
	
		def each_section
			@sections.each do |section|
				yield section
			end
		end
	
		def add_section(subtitle, body)
			sec = TdiarySection::new("\n\n ")
			sec.subtitle = subtitle
			sec.body     = body
			@sections << sec
			@sections.size
		end
	
		def delete_section(index)
			@sections.delete_at(index - 1)
		end
	
		def to_src
			src = ''
			each_section do |section|
				src << section.to_src
			end
			src
		end
	
		def to_html( opt, mode = :HTML )
			case mode
			when :CHTML
				to_chtml( opt )
			else
				to_html4( opt )
			end
		end
	
		def to_html4( opt )
			idx = 1
			r = ''
			each_section do |section|
				r << %Q[<div class="section">\n]
				if section.subtitle then
					r << %Q[<h3><%= subtitle_proc( Time::at( #{date.to_i} ), #{section.subtitle.dump.gsub( /%/, '\\\\045' )} ) %></h3>\n]
				end
				if /^</ =~ section.body then
					r << %Q[#{section.body}]
				elsif section.subtitle
					r << %Q[<p>#{section.body.collect{|l|l.chomp.sub( /^[　 ]/e, '')}.join( "</p>\n<p>" )}</p>\n]
				else
					r << %Q[<p><%= subtitle_proc( Time::at( #{date.to_i} ), nil ) %>]
					r << %Q[#{section.body.collect{|l|l.chomp.sub( /^[　 ]/e, '' )}.join( "</p>\n<p>" )}</p>]
				end
				r << %Q[</div>]
				idx += 1
			end
			r
		end
	
		def to_chtml( opt )
			idx = 1
			r = ''
			each_section do |section|
				if section.subtitle then
					r << %Q[<H3><%= subtitle_proc( Time::at( #{date.to_i} ), #{section.subtitle.dump.gsub( /%/, '\\\\045' )} ) %></H3>\n]
				end
				if /^</ =~ section.body then
					idx += 1
					r << section.body
				elsif section.subtitle
					r << %Q[<P>#{section.body.collect{|l|l.chomp.sub( /^[　 ]/e, '' )}.join( "</P>\n<P>" )}</P>\n]
				else
					r << %Q[<P><%= subtitle_proc( Time::at( #{date.to_i} ), nil ) %>]
					r << %Q[#{section.body.collect{|l|l.chomp.sub( /^[　 ]/e, '' )}.join( "</P>\n<P>" )}</P>\n]
				end
				idx += 1
			end
			r
		end
	
		def to_s
			"date=#{date.strftime('%Y%m%d')}, title=#{title}, body=[#{@sections.join('][')}]"
		end
	end
end
