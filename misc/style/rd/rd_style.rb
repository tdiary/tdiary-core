#
# rd_style.rb: RD style for tDiary 2.x format. $Revision: 1.23 $
# based on Wiki style which Copyright belongs to TADA Tadashi.
#
# if you want to use this style, install RDtool
# and add @style into tdiary.conf below:
#
#    @style = 'RD'
#
# about RDtool: http://raa.ruby-lang.org/list.rhtml?name=rdtool
#
# ref_extension codes come from rd2html-ext
#   http://raa.ruby-lang.org/list.rhtml?name=rd2html-ext
#
# You can distribute this under GPL.
#
require 'rd/rdfmt'
require 'rd/rd2html-lib'

module RD
	TDIARY_BASE_LEVEL = 2

	class RD2tDiaryVisitor < RD2HTMLVisitor
		def initialize( date=nil, idx=nil, opt=nil, author=nil )
		  	@td_date = date
			@td_idx = idx
			@td_opt = opt
			@td_author = author
			super()
		end

	  	def apply_to_DocumentElement(element, content)
			ret = ""
			ret << html_body(content) + "\n"
			ret
		end

		def html_body(contents)
			content = contents.join("\n")
		end
		private :html_body

		def apply_to_Headline(element, title)
			level = element.level + TDIARY_BASE_LEVEL
			if level == 3
				r = %Q[<h#{level}><a ]

				if @td_opt['anchor'] then
					r << %Q[name="p#{'%02d' % @td_idx}"]
				end
				r << %Q[href="#{@td_opt['index']}<%=anchor "#{@td_date.strftime( '%Y%m%d' )}#p#{'%02d' % @td_idx}" %>">#{@td_opt['section_anchor']}</a> ]
				if @td_opt['multi_user'] and @td_author then
					r << %Q|[#{@td_author}]|
				end

				r << %Q[#{categorized_subtitle(title)}</h#{level}>]
			else
				r = %Q[<h#{level}>#{title}</h#{level}>]
			end
			r
		end

		def apply_to_DescListItem(element, term, description)
			%Q[<dt>#{term}</dt>] +
			if description.empty? then
				"\n"
			else
				%Q[\n<dd>\n#{description.join("\n").chomp}\n</dd>]
			end
		end

		def apply_to_MethodList(element, items)
			if /^(<.+>)?$/ =~ element.items[0].term.to_label
				%Q[#{items.join("\n").chomp}\n]
			else
				%Q[<dl>\n#{items.join("\n").chomp}\n</dl>]
			end
		end

		def apply_to_MethodListItem(element, term, description)
			case term
			when /^&lt;([^\s]+)\s*.*&gt;/
				closetag = "</#{CGI.unescapeHTML($1)}>"
				r = CGI.unescapeHTML(term)
				if description.size > 0
					r << %Q[\n#{description.join("\n")}\n]
					r << closetag
				end
				r
			when ''
				"<hr>"
			else
				super
			end
		end

		# use for tDiary plugin :-p
		def apply_to_Keyboard(element, content)
		  	plugin, args = content.join("").split(/\s+/, 2)
			%Q[<%=#{plugin} #{args}%>]
		end

		# use for native html
		def apply_to_Index(element, content)
		  	CGI.unescapeHTML(content.join)
		end

		def apply_to_Footnote(element, content)
			heredoc_id = "%0.32b" % rand( 0x100000000 )
			%Q|<%=fn <<'#{heredoc_id}' \n #{content.join}\n#{heredoc_id}\n%>|
		end

		def apply_to_RefToElement(element, content)
			label = element.to_label
			key, opt = label.split(/:/, 2)

			case key
			when "IMG"
				ref_ext_IMG(label, content.join, opt)
			when "RAA"
				ref_ext_RAA(label, content.join, opt)
			when /^ruby-(talk|list|dev|math|ext|core)$/
				ref_ext_RubyML(label, content.join, key, opt)
			when /^(\d{4}|\d{6}|\d{8})[^\d]*?#?([pct]\d\d)?$/
				%Q[<%=my "#{key}","#{content.join}"%>]
			else
				opt = "" unless opt # case of no ":"
				%Q[<%=a "#{key}","#{opt}","#{content.join}"%>]
			end
		end

		private
		def categorized_subtitle( title )
			cat = /^(\[(.*?)\])+/.match(title.to_s).to_a[0]
			subtitle = $'

			if cat
				r =
				cat.scan(/\[(.*?)\]/).collect do |c|
			  		%Q|<%= category_anchor("#{c[0]}") %>|
				end.join + subtitle
			else
				r = title.to_s
			end
			r
		end

		def ref_ext_RubyML(label, content, ml, article)
			article.sub!(/^0+/, '')
			content = "[#{label}]" if label == content

			%Q[<a href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/#{ ml }/#{ article }">#{ content }</a>]
		end

		def ref_ext_RAA(label, content, name)
			name = CGI.escape(name)
			content = "[#{label}]" if label == content
			%Q[<a href="http://raa.ruby-lang.org/list.rhtml?name=#{ name }">#{ content }</a>]
		end

		def ref_ext_IMG(label, content, src)
			label.to_s == content.to_s and content = src
			%Q[<img src="#{src}" alt="#{content}">]
		end
	end

	class RD2tDiaryCHTMLVistor < RD2tDiaryVisitor
		def apply_to_Headline(element, title)
			level = element.level + TDIARY_BASE_LEVEL
			if level == 3
				r = %Q[<H#{level}><A NAME="p#{'%02d' % @td_idx}">*</A> ]

				if @td_opt['multi_user'] and @td_author then
					r << %Q|[#{@td_author}]|
				end
				
				r << %Q[#{categorized_subtitle(title)}</H#{level}>]
			else
				r = %Q[<H#{level}>#{title}</H#{level}>]
			end
			r
		end
	end

	class RDInlineParser
		def on_error(et, ev, values)
			lines_of_rest = @src.rest.to_a.length
			prev_words = prev_words_on_error(ev)
			at = 4 + prev_words.length
			message = <<-MSG
RD syntax error: line #{@blockp.line_index - lines_of_rest - 1}:
...#{prev_words} #{(ev||'')} #{next_words_on_error()} ...
MSG
			message << " " * at + "^" * (ev ? ev.length : 0) + "\n"
			raise ParseError, message
		end
	end

end

module TDiary
	class RDSection
		include RD

		attr_reader :author, :categories, :subtitle, :stripped_subtitle
		attr_reader :body_to_html, :subtitle_to_html, :stripped_subtitle_to_html
	
		def initialize( fragment, author = nil )
			@author = author
			if /\A=(?!=)/ =~ fragment then
				@subtitle, @body = fragment.split( /\n/, 2 )
				@subtitle.sub!( /^\=\s*/, '' )
			else
				@subtitle = nil
				@body = fragment.dup
			end
			@body = @body || ''
			@body.sub!( /[\n\r]+\Z/, '' )
			@body << "\n\n"

			@categories = get_categories
			@stripped_subtitle = strip_subtitle

			@subtitle_to_html = manufacture(@subtitle, true)
			@stripped_subtitle_to_html = manufacture(@stripped_subtitle, true)
			@body_to_html = manufacture(@body, false)
		end

		def body
		  	@body.dup
		end

		def to_src
			r = ''
			r << "= #{@subtitle}\n" if @subtitle
			r << @body
		end

		def html( date, idx, opt, mode = :HTML)
			if mode == :CHTML
				visitor = RD2tDiaryCHTMLVistor.new( date, idx, opt, @author)
				section_open = ''
				section_close = ''
			else
				visitor = RD2tDiaryVisitor.new( date, idx, opt, @author )
				section_open = %Q[<div class="section">\n]
				section_close = "</div>\n"
			end

			src = to_src.to_a
			src.unshift("=begin\n").push("=end\n")
			tree = RDTree.new( src, nil, nil)
			begin
				tree.parse
			rescue ParseError
				raise SyntaxError, $!.message
			end

			r = "#{section_open}#{visitor.visit( tree )}#{section_close}"
		end

		private
		def manufacture(str, subtitle = false)
			return nil unless str
			src = str.strip.to_a.unshift("=begin\n").push("=end\n")
			visitor = RD2tDiaryVisitor.new
			tree = RDTree.new(src, nil, nil)
			begin
				r = visitor.visit( tree.parse )
				r.gsub!(/<\/?p>/, '') if subtitle
				r
			rescue ParseError
				str
			end
		end

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
			@subtitle.sub(/^(\[(.*?)\])+/,'')
		end
	end

	class RdDiary
		include DiaryBase
		include CategorizableDiary
	
		def initialize( date, title, body, modified = Time::now )
			init_diary
			replace( date, title, body )
			@last_modified = modified
		end
	
		def style
			'RD'
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
				when /^=(begin|end)\b/
				  	# do nothing
				when /^=[^=]/
				  	@sections << RDSection::new( section, author ) if section
					section = l
				else
					section = '' unless section
					section << l
				end
			end
			@sections << RDSection::new( section, author ) if section
			@last_modified = Time::now
			self
		end
	
		def each_section
			@sections.each do |section|
				yield section
			end
		end
	
		def to_src
			r = ''
			each_section do |section|
				r << section.to_src
			end
			r
		end
	
		def to_html( opt, mode = :HTML )
			r = ''
			idx = 1
			each_section do |section|
				r << section.html( date, idx, opt, mode )
				idx += 1
			end
			return r
		end
	
		def to_s
			"date=#{date.strftime('%Y%m%d')}, title=#{title}, body=[#{@sections.join('][')}]"
		end
	end
end


