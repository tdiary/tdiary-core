# -*- coding: utf-8; -*-

module TDiary
	module CacheIO
		def restore_cache( prefix )
			if cache_enable?( prefix )
				File::open( "#{cache_path}/#{cache_file( prefix )}" ) {|f| f.read } rescue nil
			end
		end

		def store_cache( cache, prefix )
			if cache_file( prefix )
				File::open( "#{cache_path}/#{cache_file( prefix )}", 'w' ) do |f|
					f.flock(File::LOCK_EX)
					f.write( cache )
				end
			end
		end

		def clear_cache( target = /.*/ )
			Dir::glob( "#{cache_path}/*.r[bh]*" ).each do |c|
				File::delete( c.untaint ) if target =~ c
			end
		end

	private

		def restore_parser_cache(date, key)
			return nil if @tdiary.ignore_parser_cache

			file = date.strftime("#{cache_path}/%Y%m.parser")
			obj = nil
			begin
				PStore.new(file).transaction do |cache|
					begin
						ver = cache.root?('version') ? cache['version'] : nil
						if ver == TDIARY_VERSION and cache.root?(key)
							obj = cache[key]
						else
							clear_cache
						end
						cache.abort
					rescue PStore::Error
					end
				end
			rescue
				clear_parser_cache( date )
			end
			obj
		end

		def store_parser_cache(date, obj, key)
			return nil if @tdiary.ignore_parser_cache

			file = date.strftime("#{cache_path}/%Y%m.parser")
			begin
				PStore::new(file).transaction do |cache|
					begin
						cache[key] = obj
						cache['version'] = TDIARY_VERSION
					rescue PStore::Error
					end
				end
			rescue
				clear_parser_cache(date)
			end
		end

		def clear_parser_cache(date)
			file = date.strftime("#{cache_path}/%Y%m.parser")

			begin
				File.delete(file)
				File.delete(file + '~')
			rescue
			end

			nil
		end

		def cache_file( prefix )
			if @tdiary.is_a?(TDiaryMonth)
				"#{prefix}#{@tdiary.rhtml.sub( /month/, @tdiary.date.strftime( '%Y%m' ) ).sub( /\.rhtml$/, '.rb' )}"
			elsif @tdiary.is_a?(TDiaryLatest)
				if @tdiary.cgi.params['date'][0] then
					nil
				else
					"#{prefix}#{@tdiary.rhtml.sub( /\.rhtml$/, '.rb' )}"
				end
			else
				nil
			end
		end

		def cache_exists?( prefix )
			cache_file( prefix ) && FileTest::file?( "#{cache_path}/#{cache_file( prefix )}" )
		end

		def cache_enable?( prefix )
			if @tdiary.is_a?(TDiaryView)
				cache_exists?( prefix ) && (File::mtime( "#{cache_path}/#{cache_file( prefix )}" ) > @tdiary.last_modified)
			else
				cache_exists?( prefix )
			end
		end
	end
end
