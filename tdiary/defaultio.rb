#
# defaultio.rb: tDiary IO class for tDiary 2.x format. $Revision: 1.9 $
#
module DefaultIO
	TDIARY_MAGIC_MAJOR = 'TDIARY2'
	TDIARY_MAGIC_MINOR = '00.00'
	TDIARY_MAGIC = "#{TDIARY_MAGIC_MAJOR}.#{TDIARY_MAGIC_MINOR}"

	def DefaultIO::parse_tdiary( data )
		header, body = data.split( "\n\n", 2 )
		if header and body
			body.gsub!( /^\./, '' )
			headers = {}
			header.each do |l|
				l.chomp!
				key, val = l.scan( /([^:]*):\s*(.*)/ )[0]
				headers[key] = val ? val.chomp : nil
			end
		end
		[headers, body]
	end

	module CommentIO
		def comment_file( data_path, date )
			date.strftime( "#{data_path}%Y/%Y%m.tdc" )
		end

		def restore_comment( file, diaries )
			begin
				File::open( file, 'r' ) do |fh|
					while l = fh.gets( "\n.\n" )
						headers, body = DefaultIO::parse_tdiary( l )
						next unless body
						comment = Comment::new(
								headers['Name'],
								headers['Mail'],
								body,
								Time::at( headers['Last-Modified'].to_i ) )
						diaries[headers['Date']].add_comment( comment )
					end
				end
			rescue Errno::ENOENT
			end
		end

		def store_comment( file, diaries )
			fhc = File::open( file, 'w' )
			fhc.puts( TDIARY_MAGIC )
			diaries.each do |date,diary|
				diary.each_comment( diary.count_comments ) do |com|
					fhc.puts( "Date: #{date}" )
					fhc.puts( "Name: #{com.name}" )
					fhc.puts( "Mail: #{com.mail}" )
					fhc.puts( "Last-Modified: #{com.date.to_i}" )
					fhc.puts( "Visible: #{com.visible? ? 'true' : 'false'}" )
					fhc.puts
					fhc.puts( com.body.gsub( /\r/, '' ).sub( /\n+\Z/, '' ).gsub( /\n\./, "\n.." ) )
					fhc.puts( '.' )
				end
			end
			fhc.close
		end
	end

	module RefererIO
		def referer_file( data_path, date )
			date.strftime( "#{data_path}%Y/%Y%m.tdr" )
		end

		def restore_referer( file, diaries )
			begin
				File::open( file, 'r' ) do |fh|
					while l = fh.gets( "\n.\n" )
						headers, body = DefaultIO::parse_tdiary( l )
						next unless body
						body.each do |r|
							count, ref = r.chomp.split( ' ', 2 )
							next unless ref
							diaries[headers['Date']].add_referer( ref.chomp, count.to_i )
						end
					end
				end
			rescue Errno::ENOENT
			end
		end

		def store_referer( file, diaries )
			fhr = File::open( file, 'w' )
			fhr.puts( DefaultIO::TDIARY_MAGIC )
			diaries.each do |date,diary|
				fhr.puts( "Date: #{date}" )
				fhr.puts 
				diary.each_referer( diary.count_referers ) do |count,ref|
					fhr.puts( "#{count} #{ref}" )
				end
				fhr.puts( '.' )
			end
			fhr.close
		end
	end

	class IO
		include CommentIO
		include RefererIO

		def initialize( tdiary )
			@tdiary = tdiary
		end
	
		#
		# block must be return boolean which dirty diaries.
		#
		def transaction( date, diaries = {} )
			dir = date.strftime( "#{@tdiary.data_path}%Y" )
			@dfile = date.strftime( "#{@tdiary.data_path}%Y/%Y%m.td2" )
			cfile = comment_file( @tdiary.data_path, date )
			rfile = referer_file( @tdiary.data_path, date )
			begin
				Dir::mkdir( dir ) unless FileTest::directory?( dir )
				begin
					fh = File::open( @dfile, 'r+' )
				rescue
					fh = File::open( @dfile, 'w+' )
				end
      		fh.flock( File::LOCK_EX )

				cache = @tdiary.restore_parser_cache( date, 'defaultio' )
				unless cache then
					restore( fh, diaries )
					restore_comment( cfile, diaries )
					restore_referer( rfile, diaries )
				else
					diaries.update( cache )
				end
				dirty = yield( diaries ) if iterator?
				store( fh, diaries ) if dirty == TDiary::DIRTY_DIARY
				store_comment( cfile, diaries ) if dirty == TDiary::DIRTY_COMMENT
				store_referer( rfile, diaries ) if dirty == TDiary::DIRTY_REFERER
				if dirty or not cache then
					@tdiary.store_parser_cache( date, 'defaultio', diaries )
				end

				fh.close
				File::delete( @dfile ) if diaries.empty?
			end
		end
	
		def calendar
			calendar = {}
			Dir["#{@tdiary.data_path}????"].sort.each do |dir|
				next unless %r[/\d{4}] =~ dir
				Dir["#{dir}/??????.td2"].sort.each do |file|
					year, month = file.scan( %r[/(\d{4})(\d\d)\.td2$] )[0]
					next unless year
					calendar[year] = [] unless calendar[year]
					calendar[year] << month
				end
			end
			calendar
		end

		def diary_factory( date, title, body, format = 'tDiary' )
			case format
			when 'tDiary'
				TDiaryDiary::new( date, title, body )
			else
				raise "bad format"
			end
		end

	private
		def restore( fh, diaries )
			fh.seek( 0 )
			begin
				major, minor = fh.gets.split( '.', 2 )
				raise 'bad format' unless DefaultIO::TDIARY_MAGIC_MAJOR == major
			rescue NameError
				# no magic number when it is new file.
			end

			# read and parse diary
			while l = fh.gets( "\n.\n" )
				begin
					headers, body = DefaultIO::parse_tdiary( l )
					case headers['Format']
					when 'tDiary'
						diary = TDiaryDiary::new( headers['Date'], headers['Title'], body, Time::at( headers['Last-Modified'].to_i ) )
						diaries[headers['Date']] = diary
					end
				rescue NameError
				end
			end
		end

		def store( fh, diaries )
			fh.seek( 0 )
			fh.puts( DefaultIO::TDIARY_MAGIC )
			diaries.each do |date,diary|
				# save diaries
				fh.puts( "Date: #{date}" )
				fh.puts( "Title: #{diary.title}" )
				fh.puts( "Last-Modified: #{diary.last_modified.to_i}" )
				fh.puts( "Visible: #{diary.visible? ? 'true' : 'false'}" )
				fh.puts( "Format: #{diary.format}" )
				fh.puts
				fh.puts( diary.to_text.gsub( /\r/, '' ).gsub( /\n\./, "\n.." ) )
				fh.puts( '.' )
			end
		end
	end

	class TDiaryParagraph
		attr_reader :subtitle, :body
	
		def initialize( fragment, author = nil )
			@author = author
			lines = fragment.split( /\n+/ )
			if lines.size > 1 then
				if /^<</ =~ lines[0]
					@subtitle = lines.shift.chomp.sub( /^</, '' )
				elsif /^[ ¡¡<]/ !~ lines[0]
					@subtitle = lines.shift.chomp
				end
			end
			@body = lines.join( "\n" )
		end
	
		def text
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
	
		def author
			@author = @auther unless @author
			@author
		end
	end

	class TDiaryDiary
		attr_reader :date, :title
	
		include DiaryBase
	
		def initialize( date, title, body, modified = Time::now )
			init_diary
			replace( date, title, body )
			@last_modified = modified
		end
	
		def format
			'tDiary'
		end
	
		def replace( date, title, body )
			if date.type == String then
				y, m, d = date.scan( /(\d{4})(\d\d)(\d\d)/ )[0]
				@date = Time::local( y, m, d )
			else
				@date = date
			end
			@title = title
			@paragraphs = []
			append( body )
		end
	
		def append( body, author = nil )
			body.gsub( "\r", '' ).split( /\n\n+/ ).each do |fragment|
				paragraph = TDiaryParagraph::new( fragment, author )
				@paragraphs << paragraph if paragraph
			end
			@last_modified = Time::now
			self
		end
	
		def title=( t )
			@title = t
			@last_modified = Time::now
		end
	
		def each_paragraph
			@paragraphs.each do |paragraph|
				yield paragraph
			end
		end
	
		def to_text
			text = ''
			each_paragraph do |para|
				text << para.text
			end
			text
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
			each_paragraph do |paragraph|
				r << %Q[<div class="section">\n]
				if paragraph.subtitle then
					r << %Q[<h3><a ]
					if opt['anchor'] then
						r << %Q[name="p#{'%02d' % idx}" ]
					end
					r << %Q[href="#{opt['index']}<%=anchor "#{@date.strftime( '%Y%m%d' )}#p#{'%02d' % idx}" %>">#{opt['paragraph_anchor']}</a> ]
					if opt['multi_user'] and paragraph.author then
						r << %Q|[#{paragraph.author}]|
					end
					r << %Q[#{paragraph.subtitle}</h3>]
				end
				if /^</ =~ paragraph.body then
					r << %Q[#{paragraph.body}]
				elsif paragraph.subtitle
					r << %Q[<p>#{paragraph.body.collect{|l|l.chomp}.join( "</p>\n<p>" )}</p>]
				else
					r << %Q[<p><a ]
					if opt['anchor'] then
						r << %Q[name="p#{'%02d' % idx}" ]
					end
					r << %Q[href="#{opt['index']}<%=anchor "#{@date.strftime( '%Y%m%d' )}#p#{'%02d' % idx}" %>">#{opt['paragraph_anchor']}</a> #{paragraph.body.collect{|l|l.chomp}.join( "</p>\n<p>" )}</p>]
				end
				r << %Q[</div>]
				idx += 1
			end
			r
		end
	
		def to_chtml( opt )
			idx = 0
			r = ''
			each_paragraph do |paragraph|
				if paragraph.subtitle then
					r << %Q[<P><A NAME="p#{'%02d' % idx += 1}">*</A> #{paragraph.subtitle}</P>]
				end
				if /^</ =~ paragraph.body then
					idx += 1
					r << paragraph.body
				elsif paragraph.subtitle
					r << %Q[<P>#{paragraph.body.collect{|l|l.chomp}.join( "</P>\n<P>" )}</P>]
				else
					r << %Q[<P><A NAME="p#{'%02d' % idx += 1}">*</A> ]
					if opt['multi_user'] and paragraph.author then
						r << %Q|[#{paragraph.author}]|
					end
					r << %Q[#{paragraph.body.collect{|l|l.chomp}.join( "</P>\n<P>" )}</P>]
				end
			end
			r
		end
	
		def to_s
			"date=#{@date.strftime('%Y%m%d')}, title=#{@title}, body=[#{@paragraphs.join('][')}]"
		end
	end
end

