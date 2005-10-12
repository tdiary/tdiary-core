#
# etdiary_style.rb: tDiary style class for etDiary format.
# $Id: etdiary_style.rb,v 1.16 2005-10-12 06:20:33 tadatadashi Exp $
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
	
		def subtitle=(subtitle)
			cat_str = ""
			@categories.each {|cat|
				cat_str << "[#{cat}]"
			}
			cat_str << " " unless cat_str.empty?
			@subtitle = subtitle
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
					@subtitle = cat_str + subtitle
					@anchor_type = :H3
				end
			else
				@subtitle = nil
				@anchor_type = nil
			end
			@stripped_subtitle = strip_subtitle
		end
	
		def body=(str)
			@bodies = str.split(/\n/)
		end
	
		def categories=(categories)
			@categories = categories
			cat_str = ""
			categories.each {|cat|
				cat_str << "[#{cat}]"
			}
			@subtitle = @subtitle ? (cat_str + @stripped_subtitle) : nil
			@stripped_subtitle = strip_subtitle
		end
	
		def set_body( bodies )
			@bodies = bodies
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
			@subtitle.sub(/^(\[(.*?)\])+\s*/,'')
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
				$stderr.puts name
				if fragment.subtitle
					r << %Q[<%= subtitle_proc( Time::at( #{date.to_i} ), #{fragment.subtitle.dump.gsub( /%/, '\\\\045' )} ) %>]
				else
					r << %Q[<%= subtitle_proc( Time::at( #{date.to_i} ), nil ) %>]
				end
			end

			case fragment.anchor_type
			when :P
				r
			when :H4
				"<h4>" + r + ":</h4>\n"
			when :H3
				"<h3>" + r + "</h3>\n"
			end
		end
		def section_start( date )
			%Q[<div class="section">\n<%=section_enter_proc( Time::at( #{date.to_i} ) )%>\n]
		end
		def section_end( date )
			"<%=section_leave_proc( Time::at( #{date.to_i} ) )%>\n</div>\n"
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
			return "<A NAME=\"#{name}\"></A>" if :A == fragment.anchor_type
			r = ""
			if fragment.subtitle
				r << %Q[<%= subtitle_proc( Time::at( #{date.to_i} ), #{fragment.subtitle.dump.gsub( /%/, '\\\\045' )} ) %>]
			else
				r << %Q[<%= subtitle_proc( Time::at( #{date.to_i} ), nil ) %>]
			end
			@idx += 1
			case fragment.anchor_type
			when :P
				r
			when :H4
				r + ": "
			when :H3
				"<H3>" + r + "</H3>\n"
			end
		end
		def section_start( date )
			"<%=section_enter_proc( Time::at( #{date.to_i} ) )%>\n"
		end
		def section_end
			"<%=section_leave_proc( Time::at( #{date.to_i} ) )%>\n"
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
	
		def each_paragraph
			@sections.each do |fragment|
				yield fragment
			end
		end
	
		def each_section
			section = nil
			each_paragraph do |fragment|
				if section and nil == fragment.anchor_type then
					section << fragment.body
				else
					yield section if section and section.anchor_type
					section = fragment.dup
					section.set_body( [ fragment.body ] )
				end
			end
			yield section if section
		end
	
		def add_section(subtitle, body)
			sec = EtdiarySection::new( '' )
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
			each_paragraph do |fragment|
				src << fragment.to_src
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
			r = f.section_start( date )
			each_paragraph do |fragment|
				if :H3 == fragment.anchor_type and r != f.section_start( date ) then
					r << f.section_end( date ) << "\n" << f.section_start( date )
				end
				r << to_html_section(fragment,f)
			end
			r + f.section_end( date )
		end

		def to_s
			"date=#{date.strftime('%Y%m%d')}, title=#{title}, " \
				+ "body=[#{@sections.join('][')}]"
		end
	end
end
