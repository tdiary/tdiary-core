# -*- coding: utf-8; -*-
=begin
== NAME
tDiary: the "tsukkomi-able" web diary system.

Copyright (C) 2001-2011, TADA Tadashi <t@tdtds.jp>
You can redistribute it and/or modify it under GPL2.
=end

TDIARY_VERSION = '3.0.2'

$:.unshift File.join(File::dirname(__FILE__), '/misc/lib').untaint
Dir["#{File::dirname(__FILE__) + '/vendor/*/lib'}"].each {|dir| $:.unshift dir.untaint }

require 'cgi'
require 'uri'
require 'logger'
require 'pstore'
begin
	require 'erb_fast'
rescue LoadError
	require 'erb'
end
require 'tdiary/compatible'
require 'tdiary/core_ext'

#
# module TDiary
#
module TDiary
	PATH = File::dirname( __FILE__ ).untaint

	autoload :Config, 'tdiary/config'

	#
	# class Comment
	#  Management a comment.
	#
	class Comment
		attr_reader :name, :mail, :body, :date

		def initialize( name, mail, body, date = Time::now )
			@name, @mail, @body, @date = name, mail, body, date
			@show = true
		end

		def shorten( length = 120 )
			matched = body.gsub( /\n/, ' ' ).scan( /^.{0,#{length - 2}}/u )[0]
			unless $'.empty? then
				matched + '..'
			else
				matched
			end
		end

		def visible?; @show; end
		def show=( s ); @show = s; end

		def ==( c )
			(@name == c.name) and (@mail == c.mail) and (@body == c.body)
		end
	end

	#
	# module CommentManager
	#  Management comments in a day. Include in Diary class.
	#
	module CommentManager
	private
		#
		# call this method when initialize
		#
		def init_comments
			@comments = []
		end

	public
		def add_comment( com )
			@comments << com
			if not @last_modified or @last_modified < com.date
				@last_modified = com.date
			end
			com
		end

		def count_comments( all = false )
			i = 0
			@comments.each do |comment|
				i += 1 if all or comment.visible?
			end
			i
		end

		def each_comment( limit = -1 )
			@comments.each_with_index do |com,idx|
				break if idx >= limit and limit >= 0
				yield com
			end
		end

		def each_comment_tail( limit = 3 )
			idx = 0
			comments = @comments.collect {|c|
				idx += 1
				if c.visible? then
					[c, idx]
				else
					nil
				end
			}.compact
			s = comments.size - limit
			s = 0 if s < 0
			for idx in s...comments.size
				yield comments[idx][0], comments[idx][1] # idx is start with 1.
			end
		end

		def each_visible_comment( limit = -1 )
			@comments.each_with_index do |com,idx|
				break if idx >= limit and limit >= 0
				next unless com.visible?
				yield com,idx+1 # idx is start with 1.
			end
		end

		def each_visible_trackback( limit = -1 )
			i = 0
			@comments.each do |com|
				break if i >= limit and limit >= 0
				next unless /^TrackBack$/ =~ com.name
				next unless com.visible_true?
				i += 1
				yield com, i
			end
		end

		def each_visible_trackback_tail( limit = 3 )
			i = 0
			@comments.find_all {|com|
				com.visible_true? and /^TrackBack$/ =~ com.name
			}.reverse[0,limit].reverse.each do |com|
				i += 1 # i starts with 1.
				yield com,i
			end
		end
	end

	#
	# module RefererManager
	#  Management referers in a day. Include in Diary class.
	#
	module RefererManager
	private
		#
		# call this method when initialize
		#
		def init_referers
			@referers = {}
			@new_referer = true # for compatibility
		end

	public
		def add_referer( ref, count = 1 )
			newer_referer
			ref = ref.sub( /#.*$/, '' ).sub( /\?\d{8}$/, '' )
			if /^([^:]+:\/\/)([^\/]+)/ =~ ref
				ref = $1 + $2.downcase + $'
			end
			begin
				uref = CGI::unescape( ref )
			rescue Encoding::CompatibilityError
				return
			end
			if pair = @referers[uref] then
				pair = [pair, ref] if pair.class != Array # for compatibility
				@referers[uref] = [pair[0] + count, pair[1]]
			else
				@referers[uref] = [count, ref]
			end
		end

		def clear_referers
			@referers = {}
		end

		def count_referers
			@referers.size
		end

		def each_referer( limit = 10 )
			newer_referer
			# dirty workaround to avoid recursive sort that
			# causes SecurityError in @secure=true
			# environment since
			# http://svn.ruby-lang.org/cgi-bin/viewvc.cgi?view=rev&revision=16081
			@referers.values.sort_by{|e| "%08d_%s" % e}.reverse.each_with_index do |ary,idx|
				break if idx >= limit
				yield ary[0], ary[1]
			end
		end

	private
		def newer_referer
			unless @new_referer then # for compatibility
				@referers.keys.each do |ref|
					count = @referers[ref]
					if count.class != Array then
						@referers.delete( ref )
						@referers[CGI::unescape( ref )] = [count, ref]
					end
				end
				@new_referer = true
			end
		end
	end

	#
	# module/class Filter
	#
	module Filter
		class Filter
			DEBUG_NONE = 0
			DEBUG_SPAM = 1
			DEBUG_FULL = 2

			def initialize( cgi, conf, logger )
				@cgi, @conf, @logger = cgi, conf, logger

				if @conf.options.include?('filter.debug_mode')
					@debug_mode = @conf.options['filter.debug_mode']
				else
					@debug_mode = DEBUG_NONE
				end
			end

			def comment_filter( diary, comment )
				true
			end

			def referer_filter( referer )
				true
			end

			def debug( msg, level = DEBUG_SPAM )
				return if @debug_mode == DEBUG_NONE
				return if @debug_mode == DEBUG_SPAM and level == DEBUG_FULL

				@logger.info("#{@cgi.remote_addr}->#{(@cgi.params['date'][0] || 'no date').dump}: #{msg}")
			end
		end
	end

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
	# class Plugin
	#  plugin management class
	#
	class Plugin
		include ERB::Util
		attr_reader :cookies
		attr_writer :comment, :date, :diaries, :last_modified

		def initialize( params )
			@header_procs = []
			@footer_procs = []
			@update_procs = []
			@title_procs = []
			@body_enter_procs = []
			@body_leave_procs = []
			@section_index = {}
			@section_enter_procs = []
			@comment_leave_procs = []
			@subtitle_procs = []
			@section_leave_procs = []
			@edit_procs = []
			@form_procs = []
			@conf_keys = []
			@conf_procs = {}
			@conf_genre_label = {}
			@cookies = []

			params.each do |key, value|
				instance_variable_set( "@#{key}", value )
			end

			# for 1.4 compatibility
			@index = @conf.index
			@update = @conf.update
			@author_name = @conf.author_name || ''
			@author_mail = @conf.author_mail || ''
			@index_page = @conf.index_page || ''
			@html_title = @conf.html_title || ''
			@theme = @conf.theme
			@css = @conf.css
			@date_format = @conf.date_format
			@referer_table = @conf.referer_table
			@options = @conf.options

			# loading plugins
			@plugin_files = []
			plugin_path = @conf.plugin_path || "#{PATH}/plugin"
			plugin_file = ''
			begin
				Dir::glob( "#{plugin_path}/*.rb" ).sort.each do |file|
					plugin_file = file
					load_plugin( file )
					@plugin_files << plugin_file
				end
			rescue ::TDiary::ForceRedirect
				raise
			rescue Exception
				raise PluginError::new( "Plugin error in '#{File::basename( plugin_file )}'.\n#{$!}\n#{$!.backtrace[0]}" )
			end
		end

		def load_plugin( file )
			@resource_loaded = false
			begin
				res_file = File::dirname( file ) + "/#{@conf.lang}/" + File::basename( file )
				open( res_file.untaint ) do |src|
					instance_eval( src.read.untaint, "(plugin/#{@conf.lang}/#{File::basename( res_file )})", 1 )
				end
				@resource_loaded = true
			rescue IOError, Errno::ENOENT
			end
			File::open( file.untaint ) do |src|
				instance_eval( src.read.untaint, "(plugin/#{File::basename( file )})", 1 )
			end
		end

		def eval_src( src, secure )
			self.taint
			@conf.taint
			@title_procs.taint
			@body_enter_procs.taint
			@body_leave_procs.taint
			@section_index.taint
			@section_enter_procs.taint
			@comment_leave_procs.taint
			@subtitle_procs.taint
			@section_leave_procs.taint
			return Safe::safe( secure ? 4 : 1 ) do
				eval( src, binding, "(TDiary::Plugin#eval_src)", 1 )
			end
		end

	private
		def add_header_proc( block = Proc::new )
			@header_procs << block
		end

		def header_proc
			r = []
			@header_procs.each do |proc|
				r << proc.call
			end
			r.join.chomp
		end

		def add_footer_proc( block = Proc::new )
			@footer_procs << block
		end

		def footer_proc
			r = []
			@footer_procs.each do |proc|
				r << proc.call
			end
			r.join.chomp
		end

		def add_update_proc( block = Proc::new )
			@update_procs << block
		end

		def update_proc
			@update_procs.each do |proc|
				proc.call
			end
			''
		end

		def add_title_proc( block = Proc::new )
			@title_procs << block
		end

		def title_proc( date, title )
			@title_procs.each do |proc|
				title = proc.call( date, title )
			end
			apply_plugin( title )
		end

		def add_body_enter_proc( block = Proc::new )
			@body_enter_procs << block
		end

		def body_enter_proc( date )
			r = []
			@body_enter_procs.each do |proc|
				r << proc.call( date )
			end
			r.join
		end

		def add_body_leave_proc( block = Proc::new )
			@body_leave_procs << block
		end

		def body_leave_proc( date )
			r = []
			@body_leave_procs.each do |proc|
				r << proc.call( date )
			end
			r.join
		end

		def add_section_enter_proc( block = Proc::new )
			@section_enter_procs << block
		end

		def section_enter_proc( date )
			@section_index[date] = (@section_index[date] || 0) + 1
			r = []
			@section_enter_procs.each do |proc|
				r << proc.call( date, @section_index[date] )
			end
			r.join
		end

		def add_subtitle_proc( block = Proc::new )
			@subtitle_procs << block
		end

		def subtitle_proc( date, subtitle )
			@subtitle_procs.each do |proc|
				subtitle = proc.call( date, @section_index[date], subtitle )
			end
			apply_plugin( subtitle )
		end

		def add_section_leave_proc( block = Proc::new )
			@section_leave_procs << block
		end

		def section_leave_proc( date )
			r = []
			@section_leave_procs.each do |proc|
				r << proc.call( date, @section_index[date] )
			end
			r.join
		end

		def add_comment_leave_proc( block = Proc::new )
			@comment_leave_procs << block
		end

		def comment_leave_proc( date )
			r = []
			@comment_leave_procs.each do |proc|
				r << proc.call( date )
			end
			r.join
		end

		def add_edit_proc( block = Proc::new )
			@edit_procs << block
		end

		def edit_proc( date )
			r = []
			@edit_procs.each do |proc|
				r << proc.call( date )
			end
			r.join
		end

		def add_form_proc( block = Proc::new )
			@form_procs << block
		end

		def form_proc( date )
			r = []
			@form_procs.each do |proc|
				r << proc.call( date )
			end
			r.join
		end

		def add_conf_proc( key, label, genre = 'etc', block = Proc::new )
			return unless @mode =~ /^(conf|saveconf)$/
			genre_and_key = "#{genre}:#{key}"
			@conf_keys << genre_and_key unless @conf_keys.index( genre_and_key )
			@conf_procs[key] = [label, block]
		end

		def each_conf_genre
			genres = {}
			@conf_keys.each do |genre_and_key|
				genre, key = genre_and_key.split( /:/, 2 )
				next if genres[genre]
				yield genre
				genres[genre] = key
			end
		end

		def each_conf_key( genre )
			re = /^#{genre}:/
			@conf_keys.each do |genre_and_key|
				if re =~ genre_and_key then
					genre, key = genre_and_key.split( /:/, 2 )
					yield key
				end
			end
		end

		def conf_proc( key )
			r = ''
			label, block = @conf_procs[key]
			r = block.call if block
			r
		end

		def conf_genre_label( genre )
			label = @conf_genre_label[genre]
			label ? label : genre
		end

		def conf_label( key )
			label, = @conf_procs[key]
			label
		end

		def conf_current_style( key )
			if key == @cgi.params['conf'][0] then
				'selected'
			else
				'other'
			end
		end

		def add_cookie( cookie )
			begin
				@cookies << cookie
			rescue SecurityError
				raise SecurityError, "can't use cookies in plugin when secure mode"
			end
		end

		def remove_tag( str )
			str.gsub( /<[^"'<>]*(?:"[^"]*"[^"'<>]*|'[^']*'[^"'<>]*)*(?:>|(?=<)|$)/, '' )
		end

		def apply_plugin( str, remove_tag = false )
			return '' unless str
			r = str.dup
			if @options['apply_plugin'] and str.index( '<%' ) then
				r = str.untaint if $SAFE < 3
				Safe::safe( @conf.secure ? 4 : 1 ) do
					begin
						r = ERB::new( r ).result( binding )
					rescue Exception
						r = %Q|<p class="message">Invalid Text</p>#{r}|
					end
				end
			end
			r = remove_tag( r ) if remove_tag
			r
		end

		def disp_referer( table, ref )
			ref = @conf.to_native( CGI::unescape( ref ) )
			str = nil
			table.each do |url, name|
				if /#{url}/iu =~ ref then
					str = ref.gsub( /#{url}/iu, name )
					break
				end
			end
			str ? str : ref
		end

		def bot?
			@conf.bot?
		end

		def help( name )
			%Q[<div class="help-icon"><a href="http://docs.tdiary.org/#{h @conf.lang}/?#{h name}" target="_blank"><img src="#{theme_url}/help.png" width="19" height="19" alt="Help"></a></div>]
		end

		def method_missing( *m )
			super if @debug
			# ignore when no plugin
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
		attr_reader :conf
		attr_reader :date
		attr_reader :diaries

		def initialize( cgi, rhtml, conf )
			@cgi, @rhtml, @conf = cgi, rhtml, conf
			@diaries = {}
			@cookies = []

			unless @conf.io_class then
				require 'tdiary/io/default'
				@conf.io_class = DefaultIO
			end
			@io = @conf.io_class.new( self )

			# load logger
			load_logger
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

		def restore_parser_cache( date, key )
			parser_cache( date, key )
		end

		def store_parser_cache( date, key, obj )
			parser_cache( date, key, obj )
		end

		def clear_parser_cache( date )
			parser_cache( date )
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
			if cache_enable?( prefix ) then
				r = File::open( "#{cache_path}/#{cache_file( prefix )}" ) {|f| f.read } rescue nil
			end
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
				rescue Encoding::CompatibilityError
					# migration error on ruby 1.9 only 1st time, reload.
					raise ForceRedirect::new( @conf.base_url )
				end
				r = ERB::new( r ).src
				store_cache( r, prefix ) unless @diaries.empty?
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
				'cache_path' => cache_path,
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

		def cache_path
			(@conf.cache_path || "#{@conf.data_path}cache").untaint
		end

		def cache_file( prefix )
			nil
		end

		def cache_enable?( prefix )
			cache_file( prefix ) and FileTest::file?( "#{cache_path}/#{cache_file( prefix )}" )
		end

		def store_cache( cache, prefix )
			unless FileTest::directory?( cache_path ) then
				begin
					Dir::mkdir( cache_path )
				rescue Errno::EEXIST
				end
			end
			if cache_file( prefix ) then
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

		def parser_cache( date, key = nil, obj = nil )
			return nil if @ignore_parser_cache

			unless FileTest::directory?( cache_path ) then
				begin
					Dir::mkdir( cache_path )
				rescue Errno::EEXIST
				end
			end
			file = date.strftime( "#{cache_path}/%Y%m.parser" )

			unless key then
				begin
					File::delete( file )
					File::delete( file + '~' )
				rescue
				end
				return nil
			end

			begin
				PStore::new( file ).transaction do |cache|
					begin
						unless obj then # restore
							ver = cache.root?('version') ? cache['version'] : nil
							if ver == TDIARY_VERSION and cache.root?(key)
								obj = cache[key]
							else
								clear_cache
							end
							cache.abort
						else # store
							cache[key] = obj
							cache['version'] = TDIARY_VERSION
						end
					rescue PStore::Error
					end
				end
			rescue
				begin
					File::delete( file )
					File::delete( file + '~' )
				rescue
				end
				return nil
			end
			obj
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
			Dir::mkdir( log_path ) unless FileTest::directory?( log_path )

			@logger = Logger::new( File.join(log_path, "debug.log"), 'daily' )
			@logger.level = Logger.const_get( @conf.log_level || 'DEBUG' )
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

			@title = @conf.to_native( @cgi.params['title'][0] )
			@body = @conf.to_native( @cgi.params['body'][0] )
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
			@title = conf.to_native( cgi.params['title'][0] )
			@body = conf.to_native( cgi.params['body'][0] )
			@hide = cgi.params['hide'][0] == 'true' ? true : false
			super
		end

	protected
		def do_eval_rhtml( prefix )
			super
			@plugin.instance_eval { update_proc }
			anchor_str = @plugin.instance_eval( %Q[anchor "#{@diary.date.strftime('%Y%m%d')}"].untaint )
			clear_cache( /(latest|#{@date.strftime( '%Y%m' )})/ )
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
					clear_cache( /(latest|#{@date.strftime( '%Y%m' )})/ )
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
				clear_cache
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

		def cache_enable?( prefix )
			super and (File::mtime( "#{cache_path}/#{cache_file( prefix )}" ) > last_modified )
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
			@name = @conf.to_native( @cgi.params['name'][0] )
			@mail = @cgi.params['mail'][0]
			@body = @conf.to_native( @cgi.params['body'][0] )
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

	protected
		def cache_file( prefix )
			"#{prefix}#{@rhtml.sub( /month/, @date.strftime( '%Y%m' ) ).sub( /\.rhtml$/, '.rb' )}"
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

		def cache_file( prefix )
			if @cgi.params['date'][0] then
				nil
			else
				"#{prefix}#{@rhtml.sub( /\.rhtml$/, '.rb' )}"
			end
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
