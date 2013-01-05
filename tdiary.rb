# -*- coding: utf-8; -*-
=begin
== NAME
tDiary: the "tsukkomi-able" web diary system.

Copyright (C) 2001-2012, TADA Tadashi <t@tdtds.jp>
You can redistribute it and/or modify it under GPL2.
=end

TDIARY_VERSION = '3.2.0.20130105'

$:.unshift File.join(File::dirname(__FILE__), '/misc/lib').untaint
Dir["#{File::dirname(__FILE__) + '/vendor/*/lib'}"].each {|dir| $:.unshift dir.untaint }

require 'cgi'
require 'uri'
require 'logger'
require 'fileutils'
require 'pstore'
require 'json'
require 'erb'
require 'tdiary/compatible'
require 'tdiary/core_ext'

#
# module TDiary
#
module TDiary
	PATH = File::dirname( __FILE__ ).untaint

	autoload :Config,               'tdiary/config'
	autoload :Plugin,               'tdiary/plugin'
	autoload :DiaryBase,            'tdiary/style'
	autoload :CategorizableDiary,   'tdiary/style'
	autoload :UncategorizableDiary, 'tdiary/style'
	autoload :Comment,              'tdiary/comment'
	autoload :Filter,               'tdiary/filter'
	autoload :CommentManager,       'tdiary/comment_manager'
	autoload :RefererManager,       'tdiary/referer_manager'
	autoload :Dispatcher,           'tdiary/dispatcher'
	autoload :Request,              'tdiary/request'
	autoload :Response,             'tdiary/response'
	autoload :TDiaryBase,           'tdiary/base'
	autoload :TDiaryCategoryView,   'tdiary/base'
	autoload :TDiarySearch,         'tdiary/base'
	autoload :TDiaryAuthorOnlyBase, 'tdiary/author_only_base'
	autoload :TDiaryFormPlugin,     'tdiary/author_only_base'
	autoload :TDiaryConf,           'tdiary/author_only_base'
	autoload :TDiarySaveConf,       'tdiary/author_only_base'

	#
	# exception classes
	#
	class TDiaryError < StandardError; end
	class PermissionError < TDiaryError; end
	class PluginError < TDiaryError; end
	class BadStyleError < TDiaryError; end
	class NotFound < TDiaryError;	end

	# class ForceRedirect
	#  force redirect to another page
	#
	class ForceRedirect < StandardError
		attr_reader :path
		def initialize( path )
			@path = path
		end
	end

	#
	# class TDiaryAdmin
	#  base class of administration
	#
	class TDiaryAdmin < TDiaryAuthorOnlyBase
		def initialize( cgi, rhtml, conf )
			super
			begin
				@date = Time::local( @cgi.params['year'][0].to_i, @cgi.params['month'][0].to_i, @cgi.params['day'][0].to_i )
			rescue ArgumentError, NameError
				raise TDiaryError, 'bad date'
			end
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
				if diary then
					title = diary.title
				end
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

			@title = @cgi.params['title'][0]
			@body = @cgi.params['body'][0]
			if @conf.mobile_agent? && String.method_defined?(:encode)
				@title.force_encoding(@conf.mobile_encoding)
				@body.force_encoding(@conf.mobile_encoding)
			end
			@title = @conf.to_native( @title )
			@body = @conf.to_native( @body )
			@old_date = @cgi.params['old'][0]
			@hide = @cgi.params['hide'][0] == 'true' ? true : false

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
		def initialize( cgi, rhtml, conf )
			@title = cgi.params['title'][0]
			@body = cgi.params['body'][0]
			if conf.mobile_agent? && String.method_defined?(:encode)
				@title.force_encoding(conf.mobile_encoding)
				@body.force_encoding(conf.mobile_encoding)
			end
			@title = conf.to_native( @title )
			@body = conf.to_native( @body )
			@hide = cgi.params['hide'][0] == 'true' ? true : false
			super
		end

	protected
		def do_eval_rhtml( prefix )
			super
			@plugin.instance_eval { update_proc }
			anchor_str = @plugin.instance_eval( %Q[anchor "#{@diary.date.strftime('%Y%m%d')}"].untaint )
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
				@date = newdate
			end
			@author = @conf.multi_user ? @cgi.remote_user : nil

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
			old_date = @cgi.params['old'][0]

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
						com.show = @cgi.params[(idx += 1).to_s][0] == 'true' ? true : false;
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
	end

	#
	# class TDiaryDay
	#  show day mode view
	#
	class TDiaryDay < TDiaryView
		def initialize( cgi, rhtm, conf )
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
			if not @diary and @conf.bot?
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
			if @conf.mobile_agent? && String.method_defined?(:encode)
				@name.force_encoding(conf.mobile_encoding)
				@body.force_encoding(conf.mobile_encoding)
			end
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
			anchor_str = @plugin.instance_eval( %Q[anchor "#{@diary.date.strftime('%Y%m%d')}"].untaint )
			raise ForceRedirect::new( "#{@conf.index}#{anchor_str}#c#{'%02d' % @diary.count_comments( true )}" )
		end
	end

	#
	# class TDiaryMonthBase
	#  base of TDiaryMonth and TDiaryNYear
	#
	class TDiaryMonthBase < TDiaryView
		def eval_rhtml( prefix = '' )
			if @diaries.empty? and @conf.bot?
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
