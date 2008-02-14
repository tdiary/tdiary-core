#
# Wiki_style.rb: Wiki style for tDiary 2.x format. $Revision: 1.31 $
#
# if you want to use this style, add @style into tdiary.conf below:
#
#    @style = 'Wiki'
#
# Copyright (C) 2003, TADA Tadashi <sho@spc.gr.jp>
# Copyright (C) 2005, Kazuhiko <kazuhiko@fdiary.net>
# You can distribute this under GPL.
#
require 'hikidoc'

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
			r << %Q[<%=section_enter_proc( Time::at( #{date.to_i} ) )%>\n]
			r << do_html4( date, idx, opt )
			r << %Q[<%=section_leave_proc( Time::at( #{date.to_i} ) )%>\n]
			r << "</div>\n"
		end

		def do_html4( date, idx, opt )
			subtitle = false
			r = @html.lstrip
			r.sub!( %r!<h3>(.+?)</h3>!m ) do
				subtitle = true
				"<h3><%= subtitle_proc( Time::at( #{date.to_i} ), #{$1.dump.gsub( /%/, '\\\\045' )} ) %></h3>"
			end
			r.sub!( %r!^<p>(.+?)</p>$!m ) do
				"<p><%= subtitle_proc( Time::at( #{date.to_i} ), #{$1.dump.gsub( /%/, '\\\\045' )} ) %></p>"
			end unless subtitle
			r.gsub( /<(\/)?tdiary-section>/, '<\\1p>' )
		end
	
		def chtml( date, idx, opt )
			r = %Q[<%=section_enter_proc( Time::at( #{date.to_i} ) )%>\n]
			r << do_html4( date, idx, opt )
			r << %Q[<%=section_leave_proc( Time::at( #{date.to_i} ) )%>\n]
		end

		def to_s
			to_src
		end

	private
		def valid_plugin_syntax?(code)
			lambda {
				$SAFE = 4
				eval( "BEGIN {return true}\n#{code}", nil, "(plugin)", 0 )
			}.call
		rescue SyntaxError
			lambda { eval('') }.call
			false
		end

		def to_html( string )
			html = HikiDoc::to_html( string,
				:level => 3,
				:empty_element_suffix => '>',
				:use_wiki_name => false,
				:allow_bracket_inline_image => false,
				:plugin_syntax => method(:valid_plugin_syntax?) ).strip
			html.gsub!( %r!<span class="plugin">\{\{(.+?)\}\}</span>!m ) do
				"<%=#{CGI.unescapeHTML($1)}\n%>"
			end
			html.gsub!( %r!<div class="plugin">\{\{(.+?)\}\}</div>!m ) do
				"<p><%=#{CGI.unescapeHTML($1)}\n%></p>"
			end
			html.gsub!( %r!<a href="(.+?)">(.+?)</a>! ) do
				k, u = $2, $1
				if /^(\d{4}|\d{6}|\d{8}|\d{8}-\d+)[^\d]*?#?([pct]\d+)?$/ =~ u then
					%Q[<%=my '#{$1}#{$2}', '#{escape_quote k}' %>]
				elsif /:/ =~ u
					scheme, path = u.split( /:/, 2 )
					if /\A(?:http|https|ftp|mailto)\z/ =~ scheme
      				u.sub!( /^\w+:/, '' ) if %r|://| !~ u and /^mailto:/ !~ u
						%Q[<a href="#{u}">#{k}</a>]
					elsif ( k == u )
						%Q[<%=kw '#{escape_quote u}'%>]
					else
						%Q[<%=kw '#{escape_quote u}', '#{escape_quote k}'%>]
					end
				elsif k == u
					%Q[<%=kw '#{escape_quote u}', '#{escape_quote k}'%>]
				else
					%Q[<a href="#{u}">#{k}</a>]
				end
			end
			html
		end

		def escape_quote( s )
			s.gsub( /'/, "\\\\'" )
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
			# body1 is a section starts without subtitle.
			# body2 are sections starts with subtitle.
			if /(.*?)(^![^!].*)/m =~ body
				body1 = $1
				body2 = $2
			elsif /^![^!]/ !~ body
				body1 = body
				body2 = ''
			else
				body1 = ''
				body2 = body
			end

			unless body1.empty?
				current_section = @sections.pop
				if current_section then
					body1 = "#{current_section.body.sub( /\n+\Z/, '' )}\n\n#{body1}"
				end
				@sections << WikiSection::new( body1, author )
			end
			section = nil
			body2.each do |l|
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
