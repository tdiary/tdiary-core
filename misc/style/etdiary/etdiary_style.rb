#
# etdiary_style.rb: tDiary style class for etDiary format.
# $Id: etdiary_style.rb,v 1.11 2004-08-13 07:06:48 shirai-kaoru Exp $
#
# if you want to use this style, add @style into tdiary.conf below:
#
#    @style = 'etDiary'
#
module TDiary
	class EtdiarySection
		attr_reader :subtitle, :bodies, :author, :anchor_type
		attr_reader :categories, :stripped_subtitle

		alias :subtitle_to_html :subtitle
		alias :stripped_subtitle_to_html :stripped_subtitle
	
		def initialize( title, author = nil )
			@subtitle = title
			if @subtitle then
				if "" == @subtitle then
					@subtitle = nil
					@anchor_type = :P
				elsif "<>" == @subtitle then
					@subtitle = nil
					@anchor_type = :A
				elsif /^<>/ =~ @subtitle then
					@subtitle = @subtitle[2..-1]
					@anchor_type = :H4
				else
					@anchor_type = :H3
				end
			else
				@subtitle = nil
				@anchor_type = nil
			end
			@bodies = []
			@categories = get_categories
			@stripped_subtitle = strip_subtitle
		end
	
		def body
			if @bodies then
				@bodies.join('')
			else
				''
			end
		end
		alias :body_to_html :body

		def << (string)
			@bodies << string
		end

		def to_src
			s = ''
			case @anchor_type
			when :A
				s << "<<<>>>\n"
			when :P
				s << "<<>>\n"
			when :H4
				s << "[#{@author}]" if @author
				s << "<<<>" + @subtitle + ">>\n"
			when :H3
				s << "[#{@author}]" if @author
				s << "<<" + @subtitle + ">>\n"
			end
			s + ( if "" != body then body else "\n" end )
		end
	
		def to_s
			"subtitle=#{@subtitle}, body=#{body}"
		end

		def get_categories
			return [] unless @subtitle
			cat = /^(\[(.*?)\])+/.match(@subtitle).to_a[0]
			return [] unless cat
			cat.scan(/\[(.*?)\]/).collect do |c|
				c[0].split(/,/)
			end.flatten
		end

		def categorized_subtitle
			return "" unless @subtitle
			cat = /^(\[(.*?)\])+/.match(@subtitle).to_a[0]
			return @stripped_subtitle unless cat
			cat.gsub(/\[(.*?)\]/) do
				$1.split(/,/).collect do |c|
					%Q|<%= category_anchor("#{c}") %>|
				end.join
			end + @stripped_subtitle
		end

		def strip_subtitle
			return nil unless @subtitle
			@subtitle.sub(/^(\[(.*?)\])+/,'')
		end
	end

	class EtHtml4Factory
		def initialize( opt, idx = 1 )
			@opt = opt
			@idx = idx
		end
		def title( date, fragment )
			return nil if nil == fragment.anchor_type
			name = 'p%02d' % @idx
			@idx += 1
			if :A == fragment.anchor_type then
				if @opt['anchor'] then
					return "<a name=\"#{name}\"></a>"
				else
					return nil
				end
			end

			r = ''
			if @opt['index']
				r << "<a"
				r << " name=\"#{name}\"" if @opt['anchor']
				r << " href=\"" + @opt['index']
				r << "<%=anchor \"" + date.strftime('%Y%m%d') + "#" + name + "\" %>\">"
				r << @opt['section_anchor'] + "</a>"
			end
			r << "[" + fragment.author + "]" if fragment.author
			r << fragment.categorized_subtitle if fragment.subtitle

			case fragment.anchor_type
			when :P
				r
			when :H4
				"<h4>" + r + ":</h4>\n"
			when :H3
				"<h3>" + r + "</h3>\n"
			end
		end
		def section_start
			"<div class=\"section\">\n"
		end
		def section_end
			"</div>\n"
		end
		def block_title?( fragment )
			case fragment.anchor_type
			when :H3, :H4
				true
			else
				false
			end
		end
		def p_start
			"<p>"
		end
		def p_end
			"</p>"
		end
		def pre_start
			"<pre>"
		end
		def pre_end
			"</pre>"
		end
	end

	class EtCHtmlFactory
		def initialize( opt, idx = 1 )
			@opt = opt
			@idx = idx
		end
		def title( date, fragment )
			return nil if nil == fragment.anchor_type
			name = 'p%02d' % @idx
			@idx += 1
			r = "<A NAME=\"#{name}\">"
			return r + "</A>" if :A == fragment.anchor_type
			r << "*" if :A != fragment.anchor_type
			r << "</A> "
			r << "[" + fragment.author + "]" if fragment.author
			r << fragment.subtitle if fragment.subtitle
			case fragment.anchor_type
			when :P
				r
			when :H4
				r + ": "
			when :H3
				"<H3>" + r + "</H3>\n"
			end
		end
		def section_start
			""
		end
		def section_end
			""
		end
		def block_title?( fragment )
			case fragment.anchor_type
			when :H3
				true
			else
				false
			end
		end
		def p_start
			"<P>"
		end
		def p_end
			"</P>"
		end
		def pre_start
			"<PRE>"
		end
		def pre_end
			"</PRE>"
		end
	end

	class EtdiaryDiary
		include DiaryBase
		include CategorizableDiary
		
		TAG_BEG_REGEXP = /\A<([A-Za-z][0-9A-Za-z]*)([^>]*)>([^\r]*)\z/
		TAG_END_REGEXP = /\A([^\r]*)<\/([A-Za-z][0-9A-Za-z]*)>\n*\z/
		PRE_REGEXP     = /\A<[Pp][Rr][Ee][^>]*>([^\r]*)<\/[Pp][Rr][Ee]>\n*\z/
		TITLE_REGEXP   = /\A<<([^\r]*?)>>[^>]/
	
		def initialize( date, title, body, modified = Time::now )
			init_diary
			set_date( date )
			set_title( title )
			@sections = []
			if body != '' then
				append( body )
			end
			@last_modified = modified
		end
	
		def style
			'etDiary'
		end
	
		def replace( date, title, body )
			set_date( date )
			set_title( title )
			@sections = []
			append( body )
		end

		def append( body, author = nil )
			section = nil
			buffer = nil
			tag_kind = nil
			body.gsub(/\r/,'').sub(/\A\n*/,'').sub(/\n*\z/,"\n\n").each("") do |fragment|
				if buffer and TAG_END_REGEXP =~ fragment and $2.downcase == tag_kind then
					section << buffer + fragment.sub(/\n*\z/,"\n\n")
					tag_kind = nil
					buffer = nil
				elsif buffer then
					buffer << fragment
				else
					if section
						@sections << section
					end
					title = TITLE_REGEXP.match(fragment+"\n").to_a[1]
					section = EtdiarySection::new( title, author )
					fragment = fragment[ title.length + 4 .. -1 ].sub(/\A\n/,'') if title
					if TAG_BEG_REGEXP =~ fragment then
						tag_kind = $1.downcase
						if TAG_END_REGEXP =~ fragment and $2.downcase == tag_kind then
							section << fragment.sub(/\n*\z/,"\n\n")
							tag_kind = nil
						else
							buffer = fragment
						end
					else
						section << fragment
					end
				end
			end
      if buffer
        section << buffer << "</#{tag_kind}>(tDiary warning: tag &lt;#{tag_kind}&gt; is not terminated.)"
      end
			if section
				@sections << section
			end
			@last_modified = Time::now
			self
		end
	
		def each_section
			@sections.each do |section|
				yield section
			end
		end
	
		def to_src
			src = ''
			each_section do |section|
				src << section.to_src
			end
			src.sub(/\n*\z/,"\n")
		end
	
		def to_html_section(section, factory)
			r = ''
			s = if section.bodies then section.body else nil end
			t = factory.title( date, section )
			if factory.block_title?(section) then
				r << t if t
				t = nil
			end
			if s && PRE_REGEXP =~ s then
				r << factory.p_start << t << factory.p_end << "\n" if t
				r << factory.pre_start
				r << $1.gsub(/&/,"&amp;").gsub(/</,"&lt;").gsub(/>/,"&gt;")
				r << factory.pre_end << "\n"
			elsif s && /\A</ =~ s then
				r << factory.p_start << t << factory.p_end << "\n" if t
				r << s.sub( /\n*\z/, "\n" )
			else
				r << factory.p_start if t || s
				r << t if t
				r << s.sub(/\A\n*/,"\n").sub(/\n*\z/, "\n") if s
				r << factory.p_end << "\n" if t || s
			end
			r
		end

		def to_html( opt, mode = :HTML )
			case mode
			when :CHTML
				f = EtCHtmlFactory::new(opt)
			else
				f = EtHtml4Factory::new(opt)
			end
			r = f.section_start
			each_section do |section|
				if :H3 == section.anchor_type and r != f.section_start then
					r << f.section_end << "\n" << f.section_start
				end
				r << to_html_section(section,f)
			end
			r + f.section_end
		end

		def to_s
			"date=#{date.strftime('%Y%m%d')}, title=#{title}, " \
				+ "body=[#{@sections.join('][')}]"
		end
	end
end
