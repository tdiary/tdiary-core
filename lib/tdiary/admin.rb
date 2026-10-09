module TDiary
	#
	# class TDiaryAdmin
	#  base class of administration
	#
	class TDiaryAdmin < TDiaryAuthorOnlyBase
		def initialize( cgi, rhtml, conf )
			super

			ymd = %w(year month day).map {|key| @request.param( key ) }
			begin
				y, m, d = ymd.map( &:to_i )
			rescue NameError
				raise BadDateError, 'bad date'
			end
			# Time::local would roll 2/30 over into March, and the data files
			# are named after a four digit year
			unless (1000..9999).cover?( y ) and Date.valid_date?( y, m, d )
				raise BadDateError, ymd.join( '-' )
			end
			@date = Time::local( y, m, d )
		end
	end

	#
	# class TDiaryForm
	#  show diary append form
	#
	class TDiaryForm < TDiaryAdmin
		def csrf_protection_get_is_okay; true; end

		def initialize( cgi, rhtml, conf )
			begin
				super
			rescue TDiaryError
			end

			@date = Time::now + (@conf.hour_offset * 3600).to_i
			title = ''
			@io.transaction( @date ) do |diaries|
				@diaries = diaries
				diary = self[@date]
				title = diary.title if diary
				DIRTY_NONE
			end
			@diary = @io.diary_factory( @date, title, '', @conf.style )
		end
	end

	#
	# class TDiaryEdit
	#  show edit diary form
	#
	class TDiaryEdit < TDiaryAdmin
		def csrf_protection_get_is_okay; true; end

		def initialize( cgi, rhtm, conf )
			super

			@io.transaction( @date ) do |diaries|
				@diaries = diaries
				@diary = self[@date]
				if @diary then
					@conf.style = @diary.style
				else
					@diary =  @io.diary_factory( @date, '', '', @conf.style )
				end
				DIRTY_NONE
			end
		end
	end

	#
	# class TDiaryPreview
	#  preview diary
	#
	class TDiaryPreview < TDiaryAdmin
		def initialize( cgi, rhtm, conf )
			super

			@title = @request.param('title')
			@body = @request.param('body')
			@title = @conf.to_native( @title )
			@body = @conf.to_native( @body )
			@old_date = @request.param('old')
			@hide = @request.param('hide') == 'true' ? true : false

			@io.transaction( @date ) do |diaries|
				@diaries = diaries
				diary = @diaries[@date.strftime( '%Y%m%d' )]
				@conf.style = diary.style if diary
				@diary = @io.diary_factory( @date, @title, @body, @conf.style )
				@diary.show( ! @hide )
				DIRTY_NONE
			end
		end

		def eval_rhtml( prefix = '' )
			begin
				@show_result = true
				r = do_eval_rhtml( prefix )
			rescue PluginError, SyntaxError, ArgumentError
				@exception = $!.dup
				@show_result = false
				r = super
			end
			r
		end
	end

	#
	# class TDiaryUpdate
	#  super class of diary saving classes
	#
	class TDiaryUpdate < TDiaryAdmin
		def initialize( request, rhtml, conf )
			@title = request.param('title')
			@body = request.param('body')
			@title = conf.to_native( @title )
			@body = conf.to_native( @body )
			@hide = request.param('hide') == 'true' ? true : false
			super
		end

	protected

		def do_eval_rhtml( prefix )
			super
			@plugin.instance_eval { update_proc }
			anchor_str = @plugin.instance_eval( %Q[anchor "#{@diary.date.strftime('%Y%m%d')}"] )
			@io.clear_cache( /(latest|#{@date.strftime( '%Y%m' )})/ )
			raise ForceRedirect::new( "#{@conf.index}#{anchor_str}" )
		end
	end

	#
	# class TDiaryAppend
	#  append diary
	#
	class TDiaryAppend < TDiaryUpdate
		def initialize( cgi, rhtml, conf )
			begin
				super
			rescue TDiaryError
				# a post without a date goes to today, a wrong date to nowhere
				raise if %w(year month day).any? {|key| @request.valid?( key ) }
				@date = newdate
			end

			@author = @conf.multi_user ? @request.remote_user : nil

			@io.transaction( @date ) do |diaries|
				@diaries = diaries
				@diary = self[@date] || @io.diary_factory( @date, @title, '', @conf.style )
				self << @diary.append( @body, @author )
				@diary.set_title( @title ) unless @title.empty?
				@diary.show( ! @hide )
				DIRTY_DIARY
			end
		end

	protected

		def newdate
			Time::now + (@conf.hour_offset * 3600).to_i
		end
	end

	#
	# class TDiaryReplace
	#  replace diary
	#
	class TDiaryReplace < TDiaryUpdate
		def initialize( cgi, rhtm, conf )
			super
			old_date = @request.param('old')

			@io.transaction( @date ) do |diaries|
				@diaries = diaries
				@diary = self[@date]
				if @diary then
					if @date.strftime( '%Y%m%d' ) != old_date then
						@diary.append( @body, @append )
						@diary.set_title( @title ) if @title.length > 0
					else
						@diary.replace( @date, @title, @body )
					end
				else
					@diary = @io.diary_factory( @date, @title, @body, @conf.style )
				end
				@diary.show( ! @hide )
				self << @diary
				DIRTY_DIARY
			end
		end
	end

	#
	# class TDiaryRetry
	#  show the update form again with the text that was not saved
	#
	class TDiaryRetry < TDiaryAuthorOnlyBase
		def initialize( request, rhtml, conf, rejected )
			super( request, rhtml, conf )
			@rejected = rejected

			y, m, d = @request.param( 'old' ).to_s.scan( /\A(\d{4})(\d\d)(\d\d)\z/ )[0]
			if y and Date.valid_date?( y.to_i, m.to_i, d.to_i ) then
				@date = Time::local( y.to_i, m.to_i, d.to_i )
			else
				@date = Time::now + (@conf.hour_offset * 3600).to_i
			end
			title = @conf.to_native( @request.param( 'title' ) || '' )
			body = @conf.to_native( @request.param( 'body' ) || '' )

			@io.transaction( @date ) do |diaries|
				@diaries = diaries
				diary = self[@date]
				@conf.style = diary.style if diary
				@diary = @io.diary_factory( @date, title, body, @conf.style )
				@diary.show( @request.param( 'hide' ) != 'true' )
				DIRTY_NONE
			end
		end

	protected

		# plugins add their parts of the form by mode, so keep the one the
		# rejected form had
		def mode
			if @request.valid?( 'append' ) or @request.valid?( 'appendpreview' ) then
				'form'
			else
				'edit'
			end
		end
	end

	#
	# class TDiaryShowComment
	#  change visible mode of comments
	#
	class TDiaryShowComment < TDiaryAdmin
		def initialize( cgi, rhtml, conf )
			super

			@io.transaction( @date ) do |diaries|
				@diaries = diaries
				dirty = DIRTY_NONE
				@diary = self[@date]
				if @diary then
					idx = 0
					@diary.each_comment do |com|
						com.show = @request.param((idx += 1).to_s) == 'true' ? true : false;
					end
					self << @diary
					@io.clear_cache( /(latest|#{@date.strftime( '%Y%m' )})/ )
					dirty = DIRTY_COMMENT
				end
				dirty
			end
		end

		def eval_rhtml( prefix = '' )
			load_plugins
			@plugin.instance_eval { update_proc }
			super
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
