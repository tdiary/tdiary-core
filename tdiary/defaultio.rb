#
# defaultio.rb: tDiary IO class for tDiary 2.x format. $Revision: 1.21 $
#
module TDiary
	TDIARY_MAGIC_MAJOR = 'TDIARY2'
	TDIARY_MAGIC_MINOR = '00.00'
	TDIARY_MAGIC = "#{TDIARY_MAGIC_MAJOR}.#{TDIARY_MAGIC_MINOR}"

	def TDiary::parse_tdiary( data )
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
						headers, body = TDiary::parse_tdiary( l )
						next unless body
						comment = Comment::new(
								headers['Name'],
								headers['Mail'],
								body,
								Time::at( headers['Last-Modified'].to_i ) )
						comment.show = false if headers['Visible'] == 'false'
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
				diary.each_comment( diary.count_comments( true ) ) do |com|
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
						headers, body = TDiary::parse_tdiary( l )
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
			fhr.puts( TDiary::TDIARY_MAGIC )
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

	class DefaultIO
		include CommentIO
		include RefererIO

		def initialize( tdiary )
			@tdiary = tdiary
			@data_path = @tdiary.conf.data_path
		end
	
		#
		# block must be return boolean which dirty diaries.
		#
		def transaction( date )
			diaries = {}
			dir = date.strftime( "#{@data_path}%Y" )
			@dfile = date.strftime( "#{@data_path}%Y/%Y%m.td2" )
			cfile = comment_file( @data_path, date )
			rfile = referer_file( @data_path, date )
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
				store( fh, diaries ) if dirty & TDiary::TDiaryBase::DIRTY_DIARY != 0
				store_comment( cfile, diaries ) if dirty & TDiary::TDiaryBase::DIRTY_COMMENT != 0
				store_referer( rfile, diaries ) if dirty & TDiary::TDiaryBase::DIRTY_REFERER != 0
				if dirty or not cache then
					@tdiary.store_parser_cache( date, 'defaultio', diaries )
				end

				fh.close
				File::delete( @dfile ) if diaries.empty?
			end
		end
	
		def calendar
			calendar = {}
			Dir["#{@data_path}????"].sort.each do |dir|
				next unless %r[/\d{4}$] =~ dir
				Dir["#{dir.untaint}/??????.td2"].sort.each do |file|
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
				DefaultDiary::new( date, title, body )
			else
				raise StandardError, "bad format"
			end
		end

	private
		def restore( fh, diaries )
			fh.seek( 0 )
			begin
				major, minor = fh.gets.split( '.', 2 )
				raise StandardError, 'bad format' unless TDiary::TDIARY_MAGIC_MAJOR == major
			rescue NameError
				# no magic number when it is new file.
			end

			# read and parse diary
			while l = fh.gets( "\n.\n" )
				begin
					headers, body = TDiary::parse_tdiary( l )
					case headers['Format']
					when 'tDiary'
						diary = DefaultDiary::new( headers['Date'], headers['Title'], body, Time::at( headers['Last-Modified'].to_i ) )
						diary.show( headers['Visible'] == 'true' ? true : false )
						diaries[headers['Date']] = diary
					end
				rescue NameError
				end
			end
		end

		def store( fh, diaries )
			fh.seek( 0 )
			fh.puts( TDiary::TDIARY_MAGIC )
			diaries.each do |date,diary|
				# save diaries
				fh.puts( "Date: #{date}" )
				fh.puts( "Title: #{diary.title}" )
				fh.puts( "Last-Modified: #{diary.last_modified.to_i}" )
				fh.puts( "Visible: #{diary.visible? ? 'true' : 'false'}" )
				fh.puts( "Format: #{diary.format}" )
				fh.puts
				fh.puts( diary.to_src.gsub( /\r/, '' ).gsub( /\n\./, "\n.." ) )
				fh.puts( '.' )
			end
			fh.truncate( fh.tell )
		end
	end

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
	
		def initialize( date, title, body, modified = Time::now )
			init_diary
			replace( date, title, body )
			@last_modified = modified
		end
	
		def format
			'tDiary'
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

