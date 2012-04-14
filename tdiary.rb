# -*- coding: utf-8; -*-
=begin
== NAME
tDiary: the "tsukkomi-able" web diary system.

Copyright (C) 2001-2012, TADA Tadashi <t@tdtds.jp>
You can redistribute it and/or modify it under GPL2.
=end

TDIARY_VERSION = '3.1.2.20120414'

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

	autoload :Config,           'tdiary/config'
	autoload :Plugin,           'tdiary/plugin'
	autoload :Comment,          'tdiary/comment'
	autoload :CommentManager,   'tdiary/comment_manager'
	autoload :RefererManager,   'tdiary/referer_manager'
	autoload :Filter,           'tdiary/filter'
	autoload :Dispatcher,       'tdiary/dispatcher'
	autoload :Request,          'tdiary/request'
	autoload :Response,         'tdiary/response'

	#
	# module DiaryBase
	#  Base module of Diary.
	#
	module DiaryBase
		include ERB::Util
		include CommentManager
		include RefererManager

		def init_diary
			init_comments
			init_referers
			@show = true
		end

		def date
			@date
		end

		def set_date( date )
			if date.class == String then
				y, m, d = date.scan( /^(\d{4})(\d\d)(\d\d)$/ )[0]
				raise ArgumentError::new( 'date string needs YYYYMMDD format.' ) unless y
				@date = Time::local( y, m, d )
			else
				@date = date
			end
		end

		def title
			@title || ''
		end

		def set_title( title )
			@title = title
			@last_modified = Time::now
		end

		def show( s )
			@show = s
		end

		def visible?
			@show != false;
		end

		def last_modified
			@last_modified ? @last_modified : Time::at( 0 )
		end

		def last_modified=( lm )
			@last_modified  = lm
		end

		def eval_rhtml( opt, path = '.' )
			ERB::new( File::open( "#{path}/skel/#{opt['prefix']}diary.rhtml" ){|f| f.read }.untaint ).result( binding )
		end
	end

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
	# module CategorizableDiary
	#
	module CategorizableDiary
		def categorizable?; true; end
	end

	#
	# module UncategorizableDiary
	#
	module UncategorizableDiary
		def categorizable?; false; end
	end

	#
	# class TDiaryBase
	#  tDiary CGI
	#
	class TDiaryBase
		include ERB::Util

		DIRTY_NONE = 0
		DIRTY_DIARY = 1
		DIRTY_COMMENT = 2
		DIRTY_REFERER = 4

		attr_reader :cookies
		attr_reader :date
		attr_reader :diaries
		attr_reader :cgi, :rhtml, :conf
		attr_reader :ignore_parser_cache

		def initialize( cgi, rhtml, conf )
			@cgi, @rhtml, @conf = cgi, rhtml, conf
			@diaries = {}
			@cookies = []
			@io = @conf.io_class.new( self )
			@logger = @conf.logger || load_logger
			@ignore_parser_cache = false
		end

		def eval_rhtml( prefix = '' )
			begin
				r = do_eval_rhtml( prefix )
			rescue PluginError, SyntaxError, ArgumentError
				r = ERB::new( File::open( "#{PATH}/skel/plugin_error.rhtml" ) {|f| f.read }.untaint ).result( binding )
			rescue Exception
				raise
			end
			return r
		end

		def last_modified
			nil
		end

		def []( date )
			@diaries[date.strftime( '%Y%m%d' )]
		end

		def calendar
			@years = @io.calendar unless @years
		end

	protected
		def do_eval_rhtml( prefix )
			# load plugin files
			load_plugins

			# load and apply rhtmls
			r = @io.restore_cache( prefix )

			if r.nil?
				files = ["header.rhtml", @rhtml, "footer.rhtml"]
				rhtml = files.collect {|file|
					path = "#{PATH}/skel/#{prefix}#{file}"
					begin
						File::open( "#{path}.#{@conf.lang}" ) {|f| f.read }
					rescue
						File::open( path ) {|f| f.read }
					end
				}.join
				begin
					r = ERB::new( rhtml.untaint ).result( binding )
				rescue => e
					if defined?(::Encoding) && e.class == ::Encoding::CompatibilityError
						# migration error on ruby 1.9 only 1st time, reload.
						raise ForceRedirect::new( @conf.base_url )
					end
				end
				r = ERB::new( r ).src
				@io.store_cache( r, prefix ) unless @diaries.empty?
			end

			# apply plugins
			r = @plugin.eval_src( r.untaint, @conf.secure ) if @plugin
			@cookies += @plugin.cookies
			r
		end

		def mode
			self.class.to_s.sub( /^TDiary::TDiary/, '' ).downcase
		end

		def load_plugins
			calendar
			@plugin = Plugin::new(
				'conf' => @conf,
				'mode' => mode,
				'diaries' => @diaries,
				'cgi' => @cgi,
				'years' => @years,
				'cache_path' => @io.cache_path,
				'date' => @date,
				'comment' => @comment,
				'last_modified' => last_modified,
				'logger' => @logger
			)
		end

		def <<( diary )
			@diaries[diary.date.strftime( '%Y%m%d' )] = diary
		end

		def delete( date )
			@diaries.delete( date.strftime( '%Y%m%d' ) )
		end

		def load_filters
			return if @filters

			@filters = []
			filter_path = @conf.filter_path || "#{PATH}/tdiary/filter"
			Dir::glob( "#{filter_path}/*.rb" ).sort.each do |file|
				require file.untaint
				@filters << TDiary::Filter::const_get( "#{File::basename( file, '.rb' ).capitalize}Filter" )::new( @cgi, @conf, @logger )
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

		def load_logger
			return if @logger

			log_path = (@conf.log_path || "#{@conf.data_path}log").untaint
			FileUtils.mkdir_p(log_path) unless FileTest.directory?(log_path)

			@logger = Logger.new(File.join(log_path, "debug.log"), 'daily')
			@logger.level = Logger.const_get(@conf.log_level || 'DEBUG')
			@logger
		end
	end

	#
	# class TDiaryAuthorOnlyBase
	#  base class for author-only access pages
	#
	class TDiaryAuthorOnlyBase < TDiaryBase
		def csrf_protection_get_is_okay
			false
		end

		def initialize( cgi, rhtml, conf )
			super
			csrf_check( cgi, conf )
		end
		private

		def csrf_check( cgi, conf )
			# CSRF condition check
			protection_method = conf.options['csrf_protection_method']
			masterkey = conf.options['csrf_protection_key']
			updaterb_regexp = conf.options['csrf_protection_allowed_referer_regexp_for_update']

			protection_method = 1 unless protection_method

			return if protection_method == -1 # don't use this setting!

			check_key = (protection_method & 2 != 0)
			check_referer = (protection_method & 1 != 0)

			masterkey = '' unless masterkey

			updaterb_regexp = '' unless updaterb_regexp

			if (masterkey != '' && check_key)
				@csrf_protection = %Q[<input type="hidden" name="csrf_protection_key" value="#{h masterkey}">]
			else
				@csrf_protection="<!-- no CSRF protection key used -->"
			end

			referer = cgi.referer || ''
			referer = referer.sub(/\?.*$/, '')
			base_uri = URI.parse(conf.base_url)
			config_uri = URI.parse(conf.base_url) + conf.update

			referer_is_empty = referer == ''
			referer_uri = URI.parse(referer) if !referer_is_empty
			referer_is_config = !referer_is_empty && config_uri == referer_uri
			referer_is_config ||= Regexp.new(updaterb_regexp) =~ referer if !referer_is_empty && updaterb_regexp != ''
			is_post = cgi.request_method == 'POST'

			given_key = nil
			if cgi.valid?('csrf_protection_key')
				given_key = cgi.params['csrf_protection_key'][0]
				case given_key
				when String
				else
					given_key = given_key.read
				end
			end

			is_key_ok = masterkey != '' && given_key == masterkey

			keycheck_ok = !check_key || is_key_ok
			referercheck_ok = referer_is_config || (!check_referer && referer_is_empty)

			if csrf_protection_get_is_okay then
				return if is_post || given_key == nil
			else
				return if keycheck_ok && referercheck_ok
			end

			raise Exception.new(<<"EOS")
Security Error: Possible Cross-site Request Forgery (CSRF)

        Diagnostics:
                - Protection Method is #{ protection_method }
                - Mode is #{ self.mode || 'unknown' }
                    - GET is #{ csrf_protection_get_is_okay ? '' : 'not '}allowed
                - Request Method is #{ is_post ? 'POST' : 'not POST' }
                - Referer is #{ referer_is_empty ? 'empty' : referer_is_config ? 'config' : 'another page' }
                    - Given referer:       #{h referer_uri.to_s}
                    - Expected base URI:   #{h base_uri.to_s}
                    - Expected update URI: #{h config_uri.to_s}
                - CSRF key is #{ is_key_ok ? 'OK' : given_key ? 'NG (' + (given_key || '') + ')' : 'nothing' }
EOS
		end

		def load_plugins
			super
			@plugin.instance_eval("def csrf_protection\n#{(@csrf_protection.untaint || '').dump}\nend;")
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
	# class TDiaryFormPlugin
	#  show edit diary form after calling form plugin.
	#
	class TDiaryFormPlugin < TDiaryAuthorOnlyBase
		def initialize( cgi, rhtm, conf )
			super

			if @cgi.valid?( 'date' ) then
				if @cgi.params['date'][0].kind_of?( String ) then
					date = @cgi.params['date'][0]
				else
					date = @cgi.params['date'][0].read
				end
				@date = Time::local( *date.scan( /(\d{4})(\d\d)(\d\d)/ )[0] )
			else
				@date = Time::now + (@conf.hour_offset * 3600).to_i
				@diary = @io.diary_factory( @date, '', '', @conf.style )
			end

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
	# class TDiaryConf
	#  show configuration form
	#
	class TDiaryConf < TDiaryAuthorOnlyBase
		def csrf_protection_get_is_okay; true; end

		def initialize( cgi, rhtml, conf )
			super
			@key = @cgi.params['conf'][0] || ''
		end
	end

	#
	# class TDiarySaveConf
	#  save configuration
	#
	class TDiarySaveConf < TDiaryConf
		def csrf_protection_get_is_okay; false; end

		def initialize( cgi, rhtml, conf )
			super
		end

		def eval_rhtml( prefix = '' )
			r = super

			begin
				@conf.save
				@io.clear_cache
			rescue
				@error = [$!.dup, $@.dup]
			end

			r
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

	#
	# class TDiaryCategoryView
	#  base of category view mode classes
	#
	class TDiaryCategoryView < TDiaryBase
		attr_reader :last_modified
		def initialize(cgi, rhtml, conf)
			super
			@last_modified = Time.now
		end
	end

	#
	# class TDiarySearch
	#  base of search view mode classes
	#
	class TDiarySearch < TDiaryBase
		attr_reader :last_modified
		def initialize(cgi, rhtml, conf)
			super
			@last_modified = Time.now
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
