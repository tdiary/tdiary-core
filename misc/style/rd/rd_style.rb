#
# rd_style.rb: RD style for tDiary 2.x format. $Revision: 1.2 $
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
	class RD2tDiaryVisitor < RD2HTMLVisitor
		METACHAR = { "<" => "&lt;", ">" => "&gt;", "&" => "&amp;" }

		def initialize( date=nil, idx=nil, opt=nil, author=nil )
		  	@td_date = date
			@td_idx = idx
			@td_opt = opt
			@td_author = author
			super()
		end

		def visit(tree)
			install_ref_extension
			super
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
			if element.level == 3
				r = %Q[<h#{element.level}><a ]

				if @td_opt['anchor'] then
					r << %Q[name="p#{'%02d' % @td_idx}"]
				end
				r << %Q[href="#{@td_opt['index']}<%=anchor "#{@td_date.strftime( '%Y%m%d' )}#p#{'%02d' % @td_idx}" %>">#{@td_opt['section_anchor']}</a>]
				if @td_opt['multi_user'] and @td_author then
					r << %Q|[#{@td_author}]|
				end

				r << %Q[#{categorized_subtitle(title)}</h#{element.level}>]
			else
				r = %Q[<h#{element.level}>#{title}</h#{element.level}>]
			end
			r
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
			%Q|<%=fn "#{content}"%>|
		end

		def install_ref_extension
			extend RefExtension
			@ref_extension = []
			(methods + private_methods).sort.each do |m|
				if /^ref_ext/ =~ m
					@ref_extension.push(m.intern)
				end
			end
			@ref_extension.push(:default_ref_ext)
		end

		module RefExtension
			def apply_to_RefToElement(element, content)
				content = content.join("")
				apply_ref_extension(element, element_label(element), content)
			end
			private

			def apply_ref_extension(element, label, content)
				@ref_extension.each do |entry|
					result = __send__(entry, element, label, content)
					return result if result
				end
			end

			def element_label(element)
				case element
				when RDElement
					element.to_label
				else
					element
				end
			end

			def default_ref_ext(element, label, content)
				if anchor = refer(element)
					content = content.sub(/^function#/, "")
					%Q[<a href="\##{anchor}">#{content}</a>]
				else
					# warning?
					label = hyphen_escape(element.to_label)
					%Q[<!-- Reference, RDLabel "#{label}" doesn't exist -->] +
					%Q[<em class="label-not-found">#{content}</em><!-- Reference end -->]
					#' 
				end
			end

			def ref_ext_RubyML(element, label, content)
				return nil unless /^(ruby-(?:talk|list|dev|math)):(.+)$/ =~ label
				ml = $1
				article = $2.sub(/^0+/, '')
				content = "[#{label}]" if label == content

				%Q[<a href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/#{ ml }/#{ article }">#{ content }</a>]
			end

			def ref_ext_RAA(element, label, content)
				return nil unless /^RAA:(.+)$/ =~ label
				name = CGI.escape($1)
				content = "[#{label}]" if label == content
				%Q[<a href="http://www.ruby-lang.org/en/raa-list.rhtml?name=#{ name }">#{ content }</a>]
			end

			def ref_ext_IMG(element, label, content)
				return nil unless /^IMG:(.+)$/ =~ label
				label.to_s == content.to_s and content = $1
				%Q[<img src="#{$1}" alt="#{content}" />]
			end
		end # RefExtension

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

	end

	class Headline
		MARK2LEVEL["="] = 3
		MARK2LEVEL["=="] = 4
		MARK2LEVEL["==="] = 5
		MARK2LEVEL["===="] = 6
	end

end

module TDiary
	class RDSection
		include RD

		attr_reader :subtitle, :author
		attr_reader :categories, :stripped_subtitle
	
		def initialize( fragment, author = nil )
			@author = author
			if fragment[0] == ?= then
				@subtitle, @body = fragment.split( /\n/, 2 )
				@subtitle.sub!( /^\=\s*/, '' )
			else
				@subtitle = nil
				@body = fragment.dup
			end

			@categories = get_categories
			@stripped_subtitle = strip_subtitle
		end

		def body
		  	@body + "\n"
		end

		def to_src
			r = ''
			r << "= #{@subtitle}\n" if @subtitle
			r << @body.dup
		end

		def html4( date, idx, opt)
			visitor = RD2tDiaryVisitor.new( date, idx, opt, @author )
			src = to_src.to_a
			if src.find{|i| /\S/ === i } and !src.find{|i| /^=begin\b/ === i }
				src.unshift("=begin\n").push("=end\n")
			end
			tree = RDTree.new( src, nil, nil)
			tree.parse

			r = %Q[<div class="section">\n]
			r << visitor.visit( tree )
			r << "</div>\n"
		end
		alias :chtml :html4

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
			r = @subtitle.sub(/^(\[(.*?)\])+/,'')
			if r == ""
				nil
			else
				visitor = RD2tDiaryVisitor.new
				tree = RDTree.new( ["=begin\n", r.strip, "=end\n"], nil, nil )
				visitor.visit( tree.parse ).gsub(/<\/?p>/, '')
			end
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


