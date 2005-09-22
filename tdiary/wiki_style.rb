#
# Wiki_style.rb: Wiki style for tDiary 2.x format. $Revision: 1.9 $
#
# if you want to use this style, add @style into tdiary.conf below:
#
#    @style = 'Wiki'
#
# Copyright (C) 2003, TADA Tadashi <sho@spc.gr.jp>
# Copyright (C) 2005, Kazuhiko <kazuhiko@fdiary.net>
# You can distribute this under GPL.
#
require 'tdiary/hikidoc'

module TDiary
	class WikiSection
		attr_reader :subtitle, :author
		attr_reader :categories, :stripped_subtitle
		attr_reader :subtitle_to_html, :stripped_subtitle_to_html, :body_to_html
	
		def initialize( fragment, author = nil )
			@author = author
			if fragment[0] == ?! then
				@subtitle, @body = fragment.split( /\n/, 2 )
				@subtitle.sub!( /^\!\s*/, '' )
			else
				@subtitle = nil
				@body = fragment.dup
			end
			@body = @body || ''
			@body.sub!( /[\n\r]+\Z/, '' )
			@body << "\n\n"
			@categories = get_categories
			@stripped_subtitle = strip_subtitle

			@subtitle_to_html = @subtitle ? to_html( "!#{@subtitle}" ) : ''
			@body_to_html = to_html( @body )
                        @html = @subtitle_to_html + "\n" +  @body_to_html + "\n"
                        @subtitle_to_html = strip_headings( @subtitle_to_html )
                        @body_to_html = strip_headings( @body_to_html )
			@stripped_subtitle_to_html = @stripped_subtitle ? strip_headings( to_html( "!#{@stripped_subtitle}" ) ) : nil
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

		def body
			@body.dup
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
			r = ''
			r << "! #{@subtitle}\n" if @subtitle
			r << @body
		end

		def html4( date, idx, opt )
			r = %Q[<div class="section">\n]
			r << do_html4( date, idx, opt )
			r << "</div>\n"
		end

		def do_html4( date, idx, opt )
			subtitle = false
			r = @html.dup
			r.gsub!( %r!<a href="(.+?)">(.+?)</a>! ) do
				k, u = $2, $1
				u_orig = CGI.escapeHTML( CGI.unescape( u ) )
				if /^(\d{4}|\d{6}|\d{8}|\d{8}-\d+)[^\d]*?#?([pct]\d+)?$/ =~ u_orig then
					%Q[<%=my '#{$1}#{$2}', '#{k}' %>]
				elsif /:/ =~ u_orig
					scheme, path = u_orig.split( /:/, 2 )
					if /\A(?:http|https|ftp|mailto)\z/ =~ scheme
						%Q[<a href="#{u}">#{k}</a>]
					else
						%Q[<%=kw '#{u_orig}', '#{k}'%>]
					end
				elsif k == u_orig
					%Q[<%=kw '#{u_orig}', '#{k}'%>]
				else
					%Q[<a href="#{u_orig}">#{k}</a>]
				end
			end
			r.sub!( %r!<h3>(.+?)</h3>! ) do
				subtitle = true
				"<h3><%= subtitle_proc( Time::at( #{date.to_i} ), #{idx}, #{$1.dump.gsub( /%/, '\\\\045' )} ) %></h3>"
			end
			r.gsub!( %r!<p>(.+?)</p>!m ) do
				"<p><%= subtitle_proc( Time::at( #{date.to_i} ), #{idx}, #{$1.dump.gsub( /%/, '\\\\045' )} ) %></p>"
			end unless subtitle
			r
		end
	
		def chtml( date, idx, opt )
			do_html4( date, idx, opt )
		end

		def to_s
			to_src
		end

	private
		def to_html( string )
			html = HikiDoc::new( string, :level => 3, :empty_element_suffix => '>'  ).to_html.strip
			html.gsub!( %r!<span class="plugin">\{\{(.+?)\}\}</span>! ) do
				"<%=#{CGI.unescapeHTML($1)}%>"
			end
			html.gsub!( %r!<div class="plugin">\{\{(.+?)\}\}</div>! ) do
				"<p><%=#{CGI.unescapeHTML($1)}%></p>"
			end
			html
		end

		def strip_headings( string )
			html = string
			html.sub!( /\A<h3>/, '' )
			html.sub!( %r|</h3>\z|, '' )
			html.empty? ? nil : html
		end

		def get_categories
			return [] unless @subtitle
			cat = /^(\[([^\[]+?)\])+/.match(@subtitle).to_a[0]
			return [] unless cat
			cat.scan(/\[(.*?)\]/).collect do |c|
				c[0].split(/,/)
			end.flatten
		end

		def strip_subtitle
			return nil unless @subtitle
			r = @subtitle.sub(/^(\[[^\[]+?\])+\s*/,'')
			if r == ""
				nil
			else
				r
			end
		end
	end

	class WikiDiary
		include DiaryBase
		include CategorizableDiary
	
		def initialize( date, title, body, modified = Time::now )
			init_diary
			replace( date, title, body )
			@last_modified = modified
		end
	
		def style
			'Wiki'
		end
	
		def replace( date, title, body )
			set_date( date )
			set_title( title )
			@sections = []
			append( body )
		end
	
		def append( body, author = nil )
			section = nil
			body.each do |l|
				case l
				when /^\![^!]/
					@sections << WikiSection::new( section, author ) if section
					section = l
				else
					section = '' unless section
					section << l
				end
			end
			@sections << WikiSection::new( section, author ) if section
			@last_modified = Time::now
			self
		end
	
		def each_section
			@sections.each do |section|
				yield section
			end
		end
	
		def add_section(subtitle, body)
			sec = WikiSection::new("\n")
			sec.subtitle = subtitle
			sec.body     = body
			@sections << sec
			@sections.size
		end
	
		def delete_section(index)
		  @sections.delete_at(index - 1)
		end
	
		def to_src
			r = ''
			each_section do |section|
				r << section.to_src
			end
			r
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
			r = ''
			idx = 1
			each_section do |section|
				r << section.html4( date, idx, opt )
				idx += 1
			end
			r
		end
	
		def to_chtml( opt )
			r = ''
			idx = 1
			each_section do |section|
				r << section.chtml( date, idx, opt )
				idx += 1
			end
			r
		end
	
		def to_s
			"date=#{date.strftime('%Y%m%d')}, title=#{title}, body=[#{@sections.join('][')}]"
		end
	end
end
