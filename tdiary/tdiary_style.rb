#
# tdiary_style.rb: tDiary style class for tDiary 2.x format. $Revision: 1.1 $
#
# if you want to use this style, add @style into tdiary.conf below:
#
#    @style = 'tDiary'
#
module TDiary
	class DefaultSection
		attr_reader :subtitle, :body, :author
	
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
		end
	
		def to_src
			s = ''
			if @subtitle then
				s += "[#{@author}]" if @author
				s += '<' if /^</ =~ @subtitle
				s += @subtitle + "\n"
			end
			"#{s}#{@body}\n\n"
		end
	
		def to_s
			"subtitle=#{@subtitle}, body=#{@body}"
		end
	end

	class DefaultDiary
		include DiaryBase
		@@style = 'tDiary'
		TDiary::DefaultIO::add_style( @@style, self )
	
		def initialize( date, title, body, modified = Time::now )
			init_diary
			replace( date, title, body )
			@last_modified = modified
		end
	
		def style
			@@style
		end
	
		def replace( date, title, body )
			set_date( date )
			set_title( title )
			@sections = []
			append( body )
		end
	
		def append( body, author = nil )
			body.gsub( "\r", '' ).split( /\n\n+/ ).each do |fragment|
				section = DefaultSection::new( fragment, author )
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
					r << %Q[<h3><a ]
					if opt['anchor'] then
						r << %Q[name="p#{'%02d' % idx}" ]
					end
					r << %Q[href="#{opt['index']}<%=anchor "#{date.strftime( '%Y%m%d' )}#p#{'%02d' % idx}" %>">#{opt['section_anchor']}</a> ]
					if opt['multi_user'] and section.author then
						r << %Q|[#{section.author}]|
					end
					r << %Q[#{section.subtitle}</h3>]
				end
				if /^</ =~ section.body then
					r << %Q[#{section.body}]
				elsif section.subtitle
					r << %Q[<p>#{section.body.collect{|l|l.chomp.sub( /^[　 ]/e, '')}.join( "</p>\n<p>" )}</p>]
				else
					r << %Q[<p><a ]
					if opt['anchor'] then
						r << %Q[name="p#{'%02d' % idx}" ]
					end
					r << %Q[href="#{opt['index']}<%=anchor "#{date.strftime( '%Y%m%d' )}#p#{'%02d' % idx}" %>">#{opt['section_anchor']}</a> #{section.body.collect{|l|l.chomp.sub( /^[　 ]/e, '' )}.join( "</p>\n<p>" )}</p>]
				end
				r << %Q[</div>]
				idx += 1
			end
			r
		end
	
		def to_chtml( opt )
			idx = 0
			r = ''
			each_section do |section|
				if section.subtitle then
					r << %Q[<P><A NAME="p#{'%02d' % idx += 1}">*</A> #{section.subtitle}</P>]
				end
				if /^</ =~ section.body then
					idx += 1
					r << section.body
				elsif section.subtitle
					r << %Q[<P>#{section.body.collect{|l|l.chomp.sub( /^[　 ]/e, '' )}.join( "</P>\n<P>" )}</P>]
				else
					r << %Q[<P><A NAME="p#{'%02d' % idx += 1}">*</A> ]
					if opt['multi_user'] and section.author then
						r << %Q|[#{section.author}]|
					end
					r << %Q[#{section.body.collect{|l|l.chomp.sub( /^[　 ]/e, '' )}.join( "</P>\n<P>" )}</P>]
				end
			end
			r
		end
	
		def to_s
			"date=#{date.strftime('%Y%m%d')}, title=#{title}, body=[#{@sections.join('][')}]"
		end
	end
end

