module TDiary
	#
	# class TDiaryView
	#  base of view mode classes
	#
	class TDiaryView < TDiaryBase
		def initialize( cgi, rhtml, conf )
			super

			unless referer_filter( @cgi.referer )
				def @cgi.referer; nil; end
			end

			# save referer to latest
			if (!@conf.referer_day_only or (@cgi.params['date'][0] and @cgi.params['date'][0].length == 8)) and @cgi.referer then
				ym = latest_month
				@date = ym ? Time::local( ym[0], ym[1] ) : Time::now
				@io.transaction( @date ) do |diaries|
					@diaries = diaries
					dirty = DIRTY_NONE
					@diaries.keys.sort.reverse_each do |key|
						@diary = @diaries[key]
						break if @diary.visible?
					end
					if @diary then
						@diary.add_referer( @cgi.referer )
						dirty = DIRTY_REFERER
					end
					dirty
				end
				@date = @diary.date if @diary
			end
		end

		def last_modified
			lm = Time::at( 0 )
			@diaries.each_value do |diary|
				lmd = diary.last_modified
				lm = lmd if lm < lmd and diary.visible?
			end
			lm
		end

	protected

		def each_day
			@diaries.keys.sort.each do |date|
				diary = @diaries[date]
				next unless diary.visible?
				yield diary
			end
		end

		def latest_month
			result = nil
			calendar
			@years.keys.sort.reverse_each do |year|
				@years[year.to_s].sort.reverse_each do |month|
					result = [year, month]
					break
				end
				break
			end
			result
		end

		def oldest_month
			result = nil
			calendar
			@years.keys.sort.each do |year|
				@years[year.to_s].sort.each do |month|
					result = [year, month]
					break
				end
				break
			end
			result
		end

	private

		def load_filters
			return if @filters

			@filters = []
			filter_path = @conf.filter_path || "{#{PATH},#{TDiary.server_root}}/tdiary/filter"
			Dir::glob( "#{filter_path}/*.rb" ).sort.each do |file|
				require file.untaint
				@filters << TDiary::Filter::const_get( "#{File::basename( file, '.rb' ).capitalize}Filter" )::new( @cgi, @conf )
			end
		end

		def all_filters
			load_filters
			@filters + (load_plugins.sf_filters || [])
		end

		def comment_filter( diary, comment )
			all_filters.each do |filter|
				return false unless filter.comment_filter( diary, comment )
				break unless comment.visible?
			end
			true
		end

		def referer_filter( referer )
			all_filters.each do |filter|
				return false unless filter.referer_filter( referer )
			end
			true
		end
	end

	#
	# class TDiaryDay
	#  show day mode view
	#
	class TDiaryDay < TDiaryView
		def initialize( cgi, rhtml, conf )
			super

			begin
				# time is noon for easy to calc leap second.
				@date = Time::local( *@cgi.params['date'][0].scan( /^(\d{4})(\d\d)(\d\d)$/ )[0] ) + 12*60*60
				load( @date )
			rescue ArgumentError, NameError
				raise TDiaryError, 'bad date'
			end
			@diary = nil if @diary and not @diary.visible?
		end

		def last_modified
			@diary ? @diary.last_modified : Time::at( 0 )
		end

		def eval_rhtml( prefix = '' )
			if not @diary and bot?
				raise NotFound
			else
				super(prefix)
			end
		end

	protected

		def load( date )
			if not @diary or (@diary.date.dup + 12*60*60).gmtime.strftime( '%Y%m%d' ) != date.dup.gmtime.strftime( '%Y%m%d' ) then
				@io.transaction( date ) do |diaries|
					@diaries = diaries
					dirty = DIRTY_NONE
					@diary = self[date]
					if @diary and @cgi.referer then
						@diary.add_referer( @cgi.referer )
						dirty = DIRTY_REFERER
					end
					dirty
				end
			else
				@diary = self[date]
			end
		end

		def cookie_name
			@cgi.cookies['tdiary'][0] or ''
		end

		def cookie_mail
			@cgi.cookies['tdiary'][1] or ''
		end
	end

	#
	# class TDiaryDayWithoutFilter
	#
	class TDiaryDayWithoutFilter < TDiaryDay
		def referer_filter(referer); end
	end

	#
	# class TDiaryComment
	#  save a comment
	#
	class TDiaryComment < TDiaryDay
		def initialize( cgi, rhtml, conf )
			super
		end

	protected

		def load( date )
			@date = date
			@name = @cgi.params['name'][0]
			@mail = @cgi.params['mail'][0]
			@body = @cgi.params['body'][0]
			@name = @conf.to_native( @name )
			@body = @conf.to_native( @body )
			@comment = Comment::new( @name, @mail, @body )

			dirty = DIRTY_NONE
			@io.transaction( @date ) do |diaries|
				@diaries = diaries
				@diary = self[@date]
				if @diary and comment_filter( @diary, @comment ) then
					@diary.add_comment( @comment )
					dirty = DIRTY_COMMENT
					cookie_path = File::dirname( @cgi.script_name )
					cookie_path += '/' if cookie_path !~ /\/$/
					@cookies << CGI::Cookie::new( {
						'name' => 'tdiary',
						'value' => [@name,@mail],
						'path' => cookie_path,
						'expires' => Time::now.gmtime + 90*24*60*60 # 90days
					} )
					@io.clear_cache( /(latest|#{@date.strftime( '%Y%m' )})/ )
				else
					@comment = nil
				end
				dirty
			end
		end

		def do_eval_rhtml( prefix )
			load_plugins
			@plugin.instance_eval { update_proc } if @comment
			if @conf.request.xhr?
				super
			else
				anchor_str = @plugin.instance_eval( %Q[anchor "#{@diary.date.strftime('%Y%m%d')}"].untaint )
				raise ForceRedirect::new( "#{@conf.index}#{anchor_str}#c#{'%02d' % @diary.count_comments( true )}" )
			end
		end
	end

	#
	# class TDiaryMonthBase
	#  base of TDiaryMonth and TDiaryNYear
	#
	class TDiaryMonthBase < TDiaryView
		def eval_rhtml( prefix = '' )
			if @diaries.empty? and bot?
				raise NotFound
			else
				super(prefix)
			end
		end
	end

	#
	# class TDiaryMonth
	#  show month mode view
	#
	class TDiaryMonth < TDiaryMonthBase
		def initialize( cgi, rhtml, conf )
			super

			begin
				date = Time::local( *@cgi.params['date'][0].scan( /^(\d{4})(\d\d)$/ )[0] )
				d1 = @date.dup.gmtime if @date
				d2 = date.dup.gmtime
				if not @date or d1.year != d2.year or d1.month != d2.month then
					@date = date
					@io.transaction( @date ) do |diaries|
						@diaries = diaries
						@diary = @diaries[@diaries.keys.sort.reverse[0]]
						DIRTY_NONE
					end
				end
			rescue ArgumentError, NameError
				raise TDiaryError, 'bad date'
			end
		end
	end

	#
	# class TDiaryNYear
	#  show nyear mode view
	#
	class TDiaryNYear < TDiaryMonthBase
		def initialize(cgi, rhtml, conf)
			super

			@diaries = {}
			month, day = @cgi.params['date'][0].scan(/^(\d\d)(\d\d)$/)[0]
			nyear(month).each do |y, m|
				@date = Time::local(y, m)
				@io.transaction(@date) do |diaries|
					ymd = y + m + day
					@diaries[ymd] = diaries[ymd] if diaries[ymd]
					DIRTY_NONE
				end
			end
		end

	protected

		def nyear(month)
			r = []
			calendar
			@years.keys.reverse_each do |year|
				r << [year, month] if @years[year].include? month
			end
			r
		end
	end

	#
	# class TDiaryMonthWithoutFilter
	#
	class TDiaryMonthWithoutFilter < TDiaryMonth
		def referer_filter(referer); end
	end

	#
	# class TDiaryLatest
	#  show latest mode view
	#
	class TDiaryLatest < TDiaryView
		def initialize( cgi, rhtml, conf )
			super

			if @cgi.params['date'][0] then
				ym = [@cgi.params['date'][0][0,4].to_i, @cgi.params['date'][0][4,2].to_i]
				@date = nil
			else
				ym = latest_month
			end

			unless @date then
				@date = ym ? Time::local( ym[0], ym[1] ) : Time::now
				@io.transaction( @date ) do |diaries|
					@diaries = diaries
					if @cgi.params['date'][0] then
						@diary = @diaries[@cgi.params['date'][0][0,8]]
						@date = @diary.date if @diary
					end
					unless @diary then
						@diaries.keys.sort.reverse_each do |d|
							diary = @diaries[d]
							if diary.visible?
								@diary = diary
								break
							end
						end
						@diary = @diaries[@diaries.keys.sort.reverse[0]] unless @diary
						@date = @diary.date if @diary
					end
					DIRTY_NONE
				end
			end

			if ym then
				# read +2 days for calc ndays.prev in count_diaries method
				limit = limit_size( @conf.latest_limit ) + 2

				# read next month data until limit
				y = ym[0].to_i
				m = ym[1].to_i
				latest = latest_month
				diaries_tmp = {}.update( @diaries )
				diaries_size = count_diaries_after( diaries_tmp )
				while ( latest and diaries_size < limit )
					date = if m == 12 then
						Time::local( y += 1, m = 1 )
					else
						Time::local( y, m += 1 )
					end
					break if date > Time::local( *latest )
					@io.transaction( date ) do |diaries|
						diaries_tmp.update( diaries )
						diaries_size = count_diaries_after( diaries_tmp )
						DIRTY_NONE
					end
				end

				# read prev month data until limit
				y = ym[0].to_i
				m = ym[1].to_i
				oldest = oldest_month
				diaries_size = count_diaries_before( @diaries )
				while ( oldest and diaries_size < limit )
					date = if m == 1 then
						Time::local( y -= 1, m = 12 )
					else
						Time::local( y, m -= 1 )
					end
					break if date < Time::local( *oldest )
					@io.transaction( date ) do |diaries|
						@diaries.update( diaries )
						diaries_size = count_diaries_before( @diaries )
						DIRTY_NONE
					end
				end
			end
		end

		def latest( limit = 5 )
			start = start_date
			limit = limit_size( limit )
			idx = 0
			@diaries.keys.sort.reverse_each do |date|
				next if date > start
				diary = @diaries[date]
				next unless diary.visible?
				yield diary
				idx += 1
				break if idx >= limit
			end
		end

	protected

		def count_diaries_after( diaries )
			start = start_date
			limit = limit_size( @conf.latest_limit )
			diaries_size = 0
			continue_exist = true
			diaries.keys.sort.each do |date|
				if diaries[date].visible? and date > start then
					continue_exist = true if diaries_size < limit
					@conf['ndays.next'] = date if diaries_size < limit
					diaries_size += 1
				end
			end
			@conf['ndays.next'] = nil unless continue_exist
			diaries_size
		end

		def count_diaries_before( diaries )
			start = start_date
			limit = limit_size( @conf.latest_limit )
			diaries_size = 0
			continue_exist = false
			diaries.keys.sort.reverse_each do |date|
				if diaries[date].visible? and date <= start then
					continue_exist = true if diaries_size >= limit
					@conf['ndays.prev'] = date if diaries_size <= limit
					diaries_size += 1
				end
			end
			@conf['ndays.prev'] = nil unless continue_exist
			diaries_size
		end

		def start_date
			if @cgi.params['date'][0] then
				@cgi.params['date'][0][0,8]
			else
				'99999999' # max of date string
			end
		end

		def limit_size( default_limit )
			if @cgi.params['date'][0] then
				date = @cgi.params['date'][0]
				limit = date[9,date.length-9].to_i
				limit = 30 if limit > 30
				limit
			else
				default_limit
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
# vim: ts=3
