#
# defaultio.rb: tDiary IO class for tDiary 2.x format. $Revision: 1.40 $
#
# Copyright (C) 2001-2005, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#
module TDiary
	TDIARY_MAGIC_MAJOR = 'TDIARY2'
	TDIARY_MAGIC_MINOR = '00.00'
	TDIARY_MAGIC = "#{TDIARY_MAGIC_MAJOR}.#{TDIARY_MAGIC_MINOR}"

	def TDiary::parse_tdiary( data )
		header, body = data.split( /\r?\n\r?\n/, 2 )
		headers = {}
		if header then
			header.each do |l|
				l.chomp!
				key, val = l.scan( /([^:]*):\s*(.*)/ )[0]
				headers[key] = val ? val.chomp : nil
			end
		end
		if body then
			body.gsub!( /^\./, '' )
		else
			body = ''
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
					fh.flock( File::LOCK_SH )
					fh.read.split( /\r?\n\.\r?\n/ ).each do |l|
						headers, body = TDiary::parse_tdiary( l )
						next unless body
						comment = Comment::new(
								headers['Name'],
								headers['Mail'],
								body,
								Time::at( headers['Last-Modified'].to_i ) )
						comment.show = false if headers['Visible'] == 'false'
						diaries[headers['Date']].add_comment( comment ) if headers['Date']
					end
				end
			rescue Errno::ENOENT
			end
		end

		def store_comment( file, diaries )
			File::open( file, File::WRONLY | File::CREAT ) do |fhc|
				fhc.flock( File::LOCK_EX )
				fhc.rewind
				fhc.truncate( 0 )
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
			end
		end
	end

	module RefererIO
		def referer_file( data_path, date )
			date.strftime( "#{data_path}%Y/%Y%m.tdr" )
		end

		def restore_referer( file, diaries )
			begin
				File::open( file, 'r' ) do |fh|
					fh.flock( File::LOCK_SH )
					fh.read.split( /\r?\n\.\r?\n/ ).each do |l|
						headers, body = TDiary::parse_tdiary( l )
						next unless body
						body.each do |r|
							count, ref = r.chomp.split( / /, 2 )
							next unless ref
							diaries[headers['Date']].add_referer( ref.chomp, count.to_i )
						end
					end

					# convert to referer plugin format
					File::rename( file, file.sub( /\.tdr$/, '.tdr~' ) )
					diaries.each do |date,diary|
						fname = file.sub( /\.tdr$/, "#{date[6,2]}.tdr" )
						File::open( fname, File::WRONLY | File::CREAT ) do |fhr|
							fhr.flock( File::LOCK_EX )
							fhr.rewind
							fhr.truncate( 0 )
							fhr.puts( TDiary::TDIARY_MAGIC )
							fhr.puts( "Date: #{date}" )
							fhr.puts 
							diary.each_referer( diary.count_referers ) do |count,ref|
								fhr.puts( "#{count} #{ref}" )
							end
							fhr.puts( '.' )
						end
					end
				end
			rescue Errno::ENOENT
			end
		end

		def store_referer( file, diaries )
			return
		end
	end

	class DefaultIO < IOBase
		include CommentIO
		include RefererIO

		def initialize( tdiary )
			@tdiary = tdiary
			@data_path = @tdiary.conf.data_path
			load_styles
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
				store( fh, diaries ) if dirty & TDiaryBase::DIRTY_DIARY != 0
				store_comment( cfile, diaries ) if dirty & TDiaryBase::DIRTY_COMMENT != 0
				store_referer( rfile, diaries ) if dirty & TDiaryBase::DIRTY_REFERER != 0
				if dirty != TDiaryBase::DIRTY_NONE or not cache then
					@tdiary.store_parser_cache( date, 'defaultio', diaries )
				end

				if diaries.empty?
					begin
						File::delete( @dfile )
					rescue Errno::ENOENT
					end
					begin
						@tdiary.store_parser_cache( date, nil, nil)
					rescue Errno::ENOENT
					end
				end
				# delete dispensable data directory
				begin
					Dir.delete( dir ) if Dir.new( dir ).entries.reject {|f| "." == f or ".." == f}.empty?
				rescue Errno::ENOENT
				end
			ensure
				fh.close if fh
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

		def diary_factory( date, title, body, style = 'tDiary' )
			styled_diary_factory( date, title, body, style )
		end

	private
		def restore( fh, diaries )
			begin
				fh.seek( 0 )
				begin
					major, minor = fh.gets.split( /\./, 2 )
					unless TDIARY_MAGIC_MAJOR == major then
						raise StandardError, 'bad file format.'
					end

					# read and parse diary
					fh.read.split( /\r?\n\.\r?\n/ ).each do |l|
						headers, body = TDiary::parse_tdiary( l )
						style_name = headers['Format'] || 'tDiary'
						diary = eval( "#{style( style_name )}::new( headers['Date'], headers['Title'], body, Time::at( headers['Last-Modified'].to_i ) )" )
						diary.show( headers['Visible'] == 'true' ? true : false )
						diaries[headers['Date']] = diary
					end

				rescue NameError
					# no magic number when it is new file.
				end
			end
		end

		def store( fh, diaries )
			begin
				fh.seek( 0 )
				fh.puts( TDIARY_MAGIC )
				diaries.each do |date,diary|
					# save diaries
					fh.puts( "Date: #{date}" )
					fh.puts( "Title: #{diary.title}" )
					fh.puts( "Last-Modified: #{diary.last_modified.to_i}" )
					fh.puts( "Visible: #{diary.visible? ? 'true' : 'false'}" )
					fh.puts( "Format: #{diary.style}" )
					fh.puts
					fh.puts( diary.to_src.gsub( /\r/, '' ).gsub( /\n\./, "\n.." ) )
					fh.puts( '.' )
				end
				fh.truncate( fh.tell )
			end
		end
	end
end
