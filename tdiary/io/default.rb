# -*- coding: utf-8; -*-
#
# defaultio.rb: tDiary IO class for tDiary 2.x - 4.x format.
#
# Copyright (C) 2001-2005, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2.
#
require 'fileutils'
require 'tdiary/io/base'

module TDiary
	TDIARY_MAGIC_MAJOR = 'TDIARY2'
	TDIARY_MAGIC_MINOR = '01.00'
	TDIARY_MAGIC = "#{TDIARY_MAGIC_MAJOR}.#{TDIARY_MAGIC_MINOR}"

	module IO
		module Comment
			def comment_file( data_path, date )
				date.strftime( "#{data_path}%Y/%Y%m.tdc" )
			end

			def restore_comment( file, diaries )
				minor = ''
				begin
					File::open( file ) do |fh|
						fh.flock( File::LOCK_SH )

						major, minor = fh.gets.chomp.split( /\./, 2 )
						unless TDIARY_MAGIC_MAJOR == major then
							raise StandardError, 'bad file format.'
						end

						s = fh.read
						s = migrate_to_01( s ) if minor == '00.00' and !@tdiary.conf['stop_migrate_01']
						s.split( /\r?\n\.\r?\n/ ).each do |l|
							headers, body = Default.parse_tdiary( l )
							next unless body
							comment = ::TDiary::Comment::new(
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
				return minor == '00.00' ? TDiaryBase::DIRTY_COMMENT : TDiaryBase::DIRTY_NONE
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

		module Referer
			def referer_file( data_path, date )
				date.strftime( "#{data_path}%Y/%Y%m.tdr" )
			end

			def restore_referer( file, diaries )
				begin
					File::open( file ) do |fh|
						fh.flock( File::LOCK_SH )
						fh.read.split( /\r?\n\.\r?\n/ ).each do |l|
							headers, body = Default.parse_tdiary( l )
							next unless body
							body.each do |r|
								count, ref = r.chomp.split( / /, 2 )
								next unless ref
								diaries[headers['Date']].add_referer( ref.chomp, count.to_i )
							end
						end

						# convert to referer plugin format
						diaries.each do |date,diary|
							fname = file.sub( /\.tdr$/, "#{date[6,2]}.tdr".untaint )
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
					File::rename( file, file.sub( /\.tdr$/, '.tdr~' ) )
				rescue Errno::ENOENT
				end
				return TDiaryBase::DIRTY_NONE
			end

			def store_referer( file, diaries )
				return
			end
		end

		class Default < Base
			include Comment
			include Referer
			include Cache

			class << self
				def parse_tdiary( data )
					header, body = data.split( /\r?\n\r?\n/, 2 )
					headers = {}
					if header then
						header.lines.each do |l|
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

				def load_cgi_conf(conf)
					conf.class.class_eval { attr_accessor :data_path }
					raise TDiaryError, 'No @data_path variable.' unless conf.data_path

					conf.data_path += '/' if /\/$/ !~ conf.data_path
					raise TDiaryError, 'Do not set @data_path as same as tDiary system directory.' if conf.data_path == "#{TDiary::PATH}/"

					File::open( "#{conf.data_path.untaint}tdiary.conf" ){|f| f.read }
				rescue IOError, Errno::ENOENT
				end

				def save_cgi_conf(conf, result)
					File::open( "#{conf.data_path.untaint}tdiary.conf", 'w' ) {|o| o.print result }
				rescue IOError, Errno::ENOENT
				end
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
					FileUtils.mkdir_p(dir)
					begin
						fh = File::open( @dfile, 'r+' )
					rescue
						fh = File::open( @dfile, 'w+' )
					end
					fh.flock( File::LOCK_EX )

					cache = restore_parser_cache( date, 'default' )
					force_save = TDiaryBase::DIRTY_NONE
					unless cache then
						force_save |= restore( fh, diaries )
						force_save |= restore_comment( cfile, diaries )
						force_save |= restore_referer( rfile, diaries )
					else
						diaries.update( cache )
					end
					dirty = yield( diaries ) if iterator?
					store( fh, diaries ) if ((dirty | force_save) & TDiaryBase::DIRTY_DIARY) != 0
					store_comment( cfile, diaries ) if ((dirty | force_save) & TDiaryBase::DIRTY_COMMENT) != 0
					store_referer( rfile, diaries ) if ((dirty | force_save) & TDiaryBase::DIRTY_REFERER) != 0
					if dirty != TDiaryBase::DIRTY_NONE or not cache then
						store_parser_cache(date, diaries, 'default')
					end

					if diaries.empty?
						begin
							if fh then
								fh.close
								fh = nil
							end
							File::delete( @dfile )
						rescue Errno::ENOENT
						end
						begin
							store_parser_cache(date, nil, nil)
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

			def cache_dir
				@tdiary.conf.cache_path || "#{@data_path}/cache"
			end

			private

			def restore( fh, diaries )
				begin
					fh.seek( 0 )
					begin
						major, minor = fh.gets.chomp.split( /\./, 2 )
						unless TDIARY_MAGIC_MAJOR == major then
							raise StandardError, 'bad file format.'
						end

						# read and parse diary
						style_name = ''
						s = fh.read
						s = migrate_to_01( s ) if minor == '00.00' and !@tdiary.conf['stop_migrate_01']
						s.split( /\r?\n\.\r?\n/ ).each do |l|
							headers, body = Default.parse_tdiary( l )
							style_name = headers['Format'] || 'tDiary'
							diary = style( style_name )::new( headers['Date'], headers['Title'], body, Time::at( headers['Last-Modified'].to_i ) )
							diary.show( headers['Visible'] == 'true' ? true : false )
							diaries[headers['Date']] = diary
						end
					rescue NameError
						# no magic number when it is new file.
					end
				end
				return minor == '00.00' ? TDiaryBase::DIRTY_DIARY : TDiaryBase::DIRTY_NONE
			end

			def store( fh, diaries )
				begin
					fh.seek( 0 )
					fh.puts( TDIARY_MAGIC )
					diaries.sort_by {|date, diary| date}.each do |date,diary|
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

			def migrate_to_01( day )
				@tdiary.conf.migrate_to_utf8( day )
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
