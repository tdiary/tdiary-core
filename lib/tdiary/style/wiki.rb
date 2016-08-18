#
# Wiki_style.rb: Wiki style for tDiary 2.x format. $Revision: 1.32 $
#
# if you want to use this style, add @style into tdiary.conf below:
#
#    @style = 'Wiki'
#
# Copyright (C) 2003, TADA Tadashi <t@tdtds.jp>
# Copyright (C) 2005, Kazuhiko <kazuhiko@fdiary.net>
# You can distribute this under GPL2 or any later version.
#
require 'hikidoc'
require 'uri'

module TDiary
	module Style
		class WikiSection
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
				@subtitle = subtitle ? (categories_to_string + subtitle) : nil
				@stripped_subtitle = strip_subtitle
			end

			def categories=(categories)
				@subtitle = @subtitle ? (categories_to_string + @stripped_subtitle) : nil
				@stripped_subtitle = strip_subtitle
			end

			def to_src
				r = ''
				r << "! #{@subtitle}\n" if @subtitle
				r << @body
			end

			def do_html4( date, idx, opt )
				subtitle = false
				r = @html.lstrip
				r.sub!( %r!<h3>(.+?)</h3>!m ) do
					subtitle = true
					"<h3><%= subtitle_proc( Time.at( #{date.to_i} ), #{$1.dump.gsub( /%/, '\\\\045' )} ) %></h3>"
				end
				r.sub!( %r!^<p>(.+?)</p>$!m ) do
					"<p><%= subtitle_proc( Time.at( #{date.to_i} ), #{$1.dump.gsub( /%/, '\\\\045' )} ) %></p>"
				end unless subtitle
				r.gsub( /<(\/)?tdiary-section>/, '<\\1p>' )
			end

			private

			def valid_plugin_syntax?(code)
				lambda {
					begin
						$SAFE = 1
					ensure
						eval( "BEGIN {return true}\n#{code.dup.untaint}", nil, "(plugin)", 0 )
					end
				}.call
			rescue SyntaxError
				lambda { eval('') }.call
				false
			end

			def to_html( string )
				html = HikiDoc::to_html( string,
					level: 3,
					empty_element_suffix: '>',
					use_wiki_name: false,
					allow_bracket_inline_image: false,
					plugin_syntax: method(:valid_plugin_syntax?) ).strip
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
						scheme = URI( u ).scheme rescue nil # URI::InvalidURIError
						# if 'a' elements with some attr in the plugin notation,
						# its HTML will be diffelent from link notation (then it error).
						# trap the style of HTML when u has a space because it means
						# two or more attr.
						if / / =~ u || /\A(?:http|https|ftp|mailto)\z/ =~ scheme
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
			def initialize( date, title, body, modified = Time.now )
				init_diary
				replace( date, title, body )
				@last_modified = modified
			end

			def style
				'Wiki'
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
						body1 = "#{current_section.to_src.sub( /\n+\Z/, '' )}\n\n#{body1}"
					end
					@sections << WikiSection::new( body1, author )
				end
				section = nil
				body2.each_line do |l|
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
				@last_modified = Time.now
				self
			end

			def add_section(subtitle, body)
				@sections << WikiSection::new("! #{subtitle}\n#{body}")
				@sections.size
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
