=begin
== NAME
tDiary: the "tsukkomi-able" web diary system.
tdiary.rb $Revision: 1.121 $

Copyright (C) 2001-2003, TADA Tadashi <sho@spc.gr.jp>
You can redistribute it and/or modify it under GPL2.
=end

TDIARY_VERSION = '1.5.4.20030614'

require 'cgi'
require 'nkf'
require 'erb/erbl'

=begin
== String class
enhanced String class
=end
class String
	def to_euc
		NKF::nkf( '-m0 -e', self )
	end

	def to_sjis
		NKF::nkf( '-m0 -s', self )
	end

	def to_jis
		NKF::nkf( '-m0 -j', self )
	end

	def make_link
		r = %r<(((http[s]{0,1}|ftp)://[\(\)%#!/0-9a-zA-Z_$@.&+-,'"*=;?:~-]+)|([0-9a-zA-Z_.-]+@[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+\.[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+))>
		return self.
			gsub( / /, "\001" ).
			gsub( /</, "\002" ).
			gsub( />/, "\003" ).
			gsub( /&/, '&amp;' ).
			gsub( r ){ $1 == $2 ? "<a href=\"#$2\">#$2</a>" : "<a href=\"mailto:#$4\">#$4</a>" }.
			gsub( /\003/, '&gt;' ).
			gsub( /\002/, '&lt;' ).
			gsub( /\001/, '&nbsp;' ).
			gsub( /\t/, '&nbsp;' * 8 )
	end

	def shorten( len = 120 )
		lines = NKF::nkf( "-e -m0 -f#{len}", self.gsub( /\n/, ' ' ) ).split( /\n/ )
		lines[0].concat( '...' ) if lines[0] and lines[1]
		lines[0]
	end
end

=begin
== CGI class
enhanced CGI class
=end
class CGI
	def valid?( param, idx = 0 )
		begin
			self.params[param] and self.params[param][idx] and self.params[param][idx].length > 0
		rescue NameError # for Tempfile class of ruby 1.6
			self.params[param][idx].stat.size > 0
		end
	end

	def mobile_agent?
		self.user_agent =~ %r[(DoCoMo|J-PHONE|UP\.Browser|DDIPOCKET|ASTEL|PDXGW|Palmscape|Xiino|sharp pda browser|Windows CE|L-mode)]i
	end
end

=begin
== Safe module
=end
require 'thread'
module Safe
	def safe( level = 4 )
		result = nil
		Thread.start {
			$SAFE = level
			result = yield
		}.join
		result
  end
  module_function :safe
end

#
# module TDiary
#
module TDiary
	PATH = File::dirname( __FILE__ )

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
	
		def shorten( len = 120 )
			@body.shorten( len )
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
			if @comments[-1] != com then
				@comments << com
				if not @last_modified or @last_modified < com.date
					@last_modified = com.date
				end
				com
			else
				nil
			end
		end
	
		def count_comments( all = false )
			i = 0
			@comments.each do |comment|
				i += 1 if all or comment.visible?
			end
			i
		end
	
		def each_comment( limit = 3 )
			@comments.each_with_index do |com,idx|
				break if idx >= limit
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
				yield comments[idx] # idx is start with 1.
			end
		end
	
		def each_visible_comment( limit = 3 )
			@comments.each_with_index do |com,idx|
				break if idx >= limit
				next unless com.visible?
				yield com,idx+1 # idx is start with 1.
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
			uref = CGI::unescape( ref )
			if pair = @referers[uref] then
				pair = [pair, ref] if pair.class != Array # for compatibility
				@referers[uref] = [pair[0] + count, pair[1]]
			else
				@referers[uref] = [count, ref]
			end
		end
	
		def count_referers
			@referers.size
		end
	
		def each_referer( limit = 10 )
			newer_referer
			@referers.values.sort.reverse.each_with_index do |ary,idx|
				break if idx >= limit
				yield ary
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
	# module DiaryBase
	#  Base module of Diary.
	#
	module DiaryBase
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
			ERbLight::new( File::open( "#{path}/skel/#{opt['prefix']}diary.rhtml" ){|f| f.read }.untaint ).result( binding )
		end
	
		def disp_referer( table, ref )
			ref = CGI::unescape( ref )
			str = nil
			table.each do |url, name|
				if /#{url}/i =~ ref then
					str = ref.gsub( /#{url}/in, name )
					break
				end
			end
			str ? str.to_euc : ref.to_euc
		end
	end

	#
	# exception classes
	#
	class TDiaryError < StandardError; end
	class PermissionError < TDiaryError; end
	class PluginError < TDiaryError; end

	#
	# class IOBase
	#  base of IO class
	#
	class IOBase
		def calendar
			raise StandardError, 'not implemented'
		end
		
		def transaction( date )
			raise StandardError, 'not implemented'
		end

		def diary_factory( date, title, body, style = nil )
			raise StandardError, 'not implemented'
		end

		def styled_diary_factory( date, title, body, style = 'tDiary' )
			begin
				eval( "#{style( style.downcase )}::new( date, title, body )" )
			rescue
				raise StandardError, "bad style"
			end
		end

		def load_styles
			@styles = {}
			Dir::glob( "#{TDiary::PATH}/tdiary/*_style.rb" ) do |style_file|
				require style_file.untaint
				style = File::basename( style_file ).sub( /_style\.rb$/, '' )
				eval( "@styles[style] = TDiary::#{style.capitalize}Diary" )
			end
		end

		def style( s )
			@styles ? @styles[s.downcase] : nil
		end
	end

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
	# class Config
	#  configuration class
	#
	class Config
		def initialize
			load

			instance_variables.each do |v|
				v.sub!( /@/, '' )
				instance_eval( <<-SRC
					def #{v}
						@#{v}
					end
					def #{v}=(p)
						@#{v} = p
					end
					SRC
				)
			end
		end

		# saving to tdiary.conf in @data_path
		def save
			result = ERbLight::new( File::open( "#{PATH}/skel/tdiary.rconf" ){|f| f.read }.untaint ).result( binding )
			result.untaint unless @secure
			Safe::safe( @secure ? 4 : 1 ) do
				eval( result )
			end
			File::open( "#{@data_path}tdiary.conf", 'w' ) do |o|
				o.print result
			end
		end

		def charset( mobile = false )
			case @lang
			when 'en'
				'ISO-8859-1'
			else
				if mobile then
					'Shift_JIS'
				else
					'EUC-JP'
				end
			end
		end

		def mobile_agent?
			%r[(DoCoMo|J-PHONE|UP\.Browser|DDIPOCKET|ASTEL|PDXGW|Palmscape|Xiino|sharp pda browser|Windows CE|L-mode)]i =~ ENV['HTTP_USER_AGENT']
		end

		#
		# get/set plugin options
		#
		def []( key )
			@options[key]
		end

		def []=( key, val )
			@options2[key] = @options[key] = val
		end
	
	private
		# loading tdiary.conf in current directory
		def load
			@secure = true unless @secure
			@options = {}
			eval( File::open( "tdiary.conf" ){|f| f.read }.untaint )
	
			@data_path += '/' if /\/$/ !~ @data_path
			@style = 'tDiary' unless @style
			@index = './' unless @index
			@update = 'update.rb' unless @update
			@hide_comment_form = false unless defined?( @hide_comment_form )
			@lang = nil if @lang == 'ja'

			@author_name = '' unless @author_name
			@index_page = '' unless @index_page
			@hour_offset = 0 unless @hour_offset

			@html_title = '' unless @html_title
			@header = '' unless @header
			@footer = '' unless @footer
	
			@section_anchor = '<span class="sanchor">_</span>' unless @section_anchor
			@comment_anchor = '<span class="canchor">_</span>' unless @comment_anchor
			@date_format = '%Y-%m-%d' unless @date_format
			@latest_limit = 10 unless @latest_limit
			@show_nyear = false unless @show_nyear

			@theme = 'default' if not @theme and not @css

			@show_comment = true unless defined?( @show_comment )
			@comment_limit = 3 unless @comment_limit

			@show_referer = true unless defined?( @show_referer )
			@referer_limit = 10 unless @referer_limit
			@no_referer = [] unless @no_referer
			@no_referer2 = [] unless @no_referer2
			@no_referer = @no_referer2 + @no_referer
			@referer_table = [] unless @referer_table
			@referer_table2 = [] unless @referer_table2
			@referer_table = @referer_table2 + @referer_table

			@options = {} unless @options.class == Hash
			if @options2 then
				@options.update( @options2 )
			else
				@options2 = {}
			end

			# for 1.4 compatibility
			@section_anchor = @paragraph_anchor unless @section_anchor
		end

		# loading tdiary.conf in @data_path.
		def load_cgi_conf
			raise TDiaryError, 'No @data_path variable.' unless @data_path
	
			@data_path += '/' if /\/$/ !~ @data_path
			raise TDiaryError, 'Do not set @data_path as same as tDiary system directory.' if @data_path == "#{PATH}/"
	
			variables = [
				:author_name, :author_mail, :index_page, :hour_offset,
				:html_title, :header, :footer,
				:section_anchor, :comment_anchor, :date_format, :latest_limit, :show_nyear,
				:theme, :css,
				:show_comment, :comment_limit, :mail_on_comment, :mail_header,
				:show_referer, :referer_limit, :no_referer2, :referer_table2,
				:options2,
			]
			begin
				cgi_conf = File::open( "#{@data_path}tdiary.conf" ){|f| f.read }
				cgi_conf.untaint unless @secure
				def_vars = ""
				variables.each do |var| def_vars << "#{var} = nil\n" end
				eval( def_vars )
				Safe::safe( @secure ? 4 : 1 ) do
					eval( cgi_conf )
				end
				variables.each do |var| eval "@#{var} = #{var} if #{var} != nil" end
			rescue IOError, Errno::ENOENT
			end
		end

		def method_missing( *m )
			if m.length == 1 then
				instance_eval( <<-SRC
					def #{m[0]}
						@#{m[0]}
					end
					def #{m[0]}=( p )
						@#{m[0]} = p
					end
					SRC
				)
			end
			nil
		end
	end

	#
	# class Plugin
	#  plugin management class
	#
	class Plugin
		attr_reader :cookies

		def initialize( params )
			@header_procs = []
			@footer_procs = []
			@update_procs = []
			@body_enter_procs = []
			@body_leave_procs = []
			@edit_procs = []
			@form_procs = []
			@conf_keys = []
			@conf_procs = {}
			@cookies = []

			params.each_key do |key|
				eval( "@#{key} = params['#{key}']" )
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
					open( plugin_file.untaint ) do |src|
						instance_eval( src.read.untaint )
					end
					@plugin_files << plugin_file
				end
			rescue Exception
				raise PluginError::new( "Plugin error in '#{File::basename( plugin_file )}'.\n#{$!}" )
			end
		end

		def eval_src( src, secure )
			self.taint
			@body_enter_procs.taint
			@body_leave_procs.taint
			return Safe::safe( secure ? 4 : 1 ) do
				eval( src )
			end
		end

	private
		def add_header_proc( block = proc )
			@header_procs << block
		end

		def header_proc
			r = []
			@header_procs.each do |proc|
				r << proc.call
			end
			r.join.chomp
		end

		def add_footer_proc( block = proc )
			@footer_procs << block
		end

		def footer_proc
			r = []
			@footer_procs.each do |proc|
				r << proc.call
			end
			r.join.chomp
		end

		def add_update_proc( block = proc )
			@update_procs << block
		end

		def update_proc
			@update_procs.each do |proc|
				proc.call
			end
			''
		end

		def add_body_enter_proc( block = proc )
			@body_enter_procs << block
		end

		def body_enter_proc( date )
			r = []
			@body_enter_procs.each do |proc|
				r << proc.call( date )
			end
			r.join
		end

		def add_body_leave_proc( block = proc )
			@body_leave_procs << block
		end

		def body_leave_proc( date )
			r = []
			@body_leave_procs.each do |proc|
				r << proc.call( date )
			end
			r.join
		end

		def add_edit_proc( block = proc )
			@edit_procs << block
		end

		def edit_proc( date )
			r = []
			@edit_procs.each do |proc|
				r << proc.call( date )
			end
			r.join
		end

		def add_form_proc( block = proc )
			@form_procs << block
		end

		def form_proc( date )
			r = []
			@form_procs.each do |proc|
				r << proc.call( date )
			end
			r.join
		end

		def add_conf_proc( key, label, block = proc )
			return unless @mode =~ /^(conf|saveconf)$/
			@conf_keys << key
			@conf_procs[key] = [label, block]
		end

		def each_conf_key
			@conf_keys.each do |key|
				yield key
			end
		end

		def conf_proc( key )
			r = ''
			label, block = @conf_procs[key]
			r = block.call if block
			r
		end

		def conf_label( key )
			label, block = @conf_procs[key]
			label
		end

		def add_cookie( cookie )
			@cookies << cookie
		end

		def apply_plugin( str, remove_tag = false )
			r = str
			if @options['apply_plugin'] and str.index( '<%' ) then
				r = str.untaint if $SAFE < 3
				r = ERbLight.new( r ).result( binding )
			end
			r.gsub!( /<.*?>/, '' ) if remove_tag
			r
		end

		def shorten( str, len = 120 )
			str.shorten( len )
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
		DIRTY_NONE = 0
		DIRTY_DIARY = 1
		DIRTY_COMMENT = 2
		DIRTY_REFERER = 4
	
		attr_reader :cookies
		attr_reader :conf
	
		def initialize( cgi, rhtml, conf )
			@cgi, @rhtml, @conf = cgi, rhtml, conf
			@diaries = {}
			@cookies = []
	
			unless @conf.io_class then
				require 'tdiary/defaultio'
				@conf.io_class = DefaultIO
			end
			@io = @conf.io_class.new( self )
		end
	
		def eval_rhtml( prefix = '' )
			begin
				r = do_eval_rhtml( prefix )
			rescue PluginError, SyntaxError, ArgumentError
				r = ERbLight::new( File::open( "#{PATH}/skel/plugin_error.rhtml" ) {|f| f.read }.untaint ).result( binding )
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
	
	protected
		def do_eval_rhtml( prefix )
			# load plugin files
			load_plugins

			# load and apply rhtmls
			if cache_enable?( prefix ) then
				r = File::open( "#{cache_path}/#{cache_file( prefix )}" ) {|f| f.read }
			else
				files = ["header.rhtml", @rhtml, "footer.rhtml"]
				rhtml = files.collect {|file|
					path = "#{PATH}/skel/#{prefix}#{file}"
					begin
						if @conf.lang then
							File::open( "#{path}.#{@conf.lang}" ) {|f| f.read }
						else
							File::open( path ) {|f| f.read }
						end
					rescue
						File::open( path ) {|f| f.read }
					end
				}.join
				r = ERbLight::new( rhtml.untaint ).result( binding )
				r = ERbLight::new( r ).src
				store_cache( r, prefix )
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
				'comment' => @comment
			)
		end
	
		def []( date )
			@diaries[date.strftime( '%Y%m%d' )]
		end
	
		def <<( diary )
			@diaries[diary.date.strftime( '%Y%m%d' )] = diary
		end
	
		def delete( date )
			@diaries.delete( date.strftime( '%Y%m%d' ) )
		end
	
		def cache_path
			@cache_path || "#{@conf.data_path}cache"
		end
	
		def cache_file( prefix )
			nil
		end
	
		def cache_enable?( prefix )
			cache_file( prefix ) and FileTest::file?( "#{cache_path}/#{cache_file( prefix )}" )
		end
	
		def store_cache( cache, prefix )
			unless FileTest::directory?( cache_path ) then
				Dir::mkdir( cache_path )
			end
			if cache_file( prefix ) then
				File::open( "#{cache_path}/#{cache_file( prefix )}", 'w' ) do |f|
					f.write( cache )
				end
			end
		end
	
		def clear_cache
			Dir::glob( "#{cache_path}/*.r[bh]*" ).each do |c|
				File::delete( c.untaint )
			end
		end
	
		def parser_cache( date, key = nil, obj = nil )
			return nil if @ignore_parser_cache
	
			require 'pstore'
			unless FileTest::directory?( cache_path ) then
				Dir::mkdir( cache_path )
			end
			file = date.strftime( "#{cache_path}/%Y%m.parser" )
	
			unless key then
				File::delete( file )
				File::delete( file + '~' )
				return nil
			end
	
			begin
				PStore::new( file ).transaction do |cache|
					begin
						unless obj then # restore
							obj = cache[key]
							cache.abort
						else # store
							cache[key] = obj
						end
					rescue PStore::Error
					end
				end
			rescue ArgumentError
				File::delete( file )
				File::delete( file + '~' )
				return nil
			end
			obj
		end
	
		def calendar
			@years = @io.calendar unless @years
		end
	end

	#
	# class TDiaryAdmin
	#  base class of administration
	#
	class TDiaryAdmin < TDiaryBase
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
		def initialize( cgi, rhtml, conf )
			begin
				super
			rescue TDiaryError
			end
			@date = Time::now + (@conf.hour_offset * 3600).to_i
			@diary = @io.diary_factory( @date, '', '', @conf.style )
		end
	end

	#
	# class TDiaryEdit
	#  show edit diary form
	#
	class TDiaryEdit < TDiaryAdmin
		def initialize( cgi, rhtm, confl )
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
		def initialize( cgi, rhtm, confl )
			super
	
			@title = @cgi.params['title'][0].to_euc
			@body = @cgi.params['body'][0].to_euc
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
			super
			@title = @cgi.params['title'][0].to_euc
			@body = @cgi.params['body'][0].to_euc
			@hide = @cgi.params['hide'][0] == 'true' ? true : false
		end
	
	protected
		def do_eval_rhtml( prefix )
			super
			anchor = @plugin.instance_eval( %Q[anchor "#{@diary.date.strftime('%Y%m%d')}"].untaint )
			raise ForceRedirect::new( "#{@conf.index}#{anchor}" )
		end
	end

	#
	# class TDiaryAppend
	#  append diary
	#
	class TDiaryAppend < TDiaryUpdate
		def initialize( cgi, rhtml, conf )
			super
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
	end

	#
	# class TDiaryReplace
	#  replace diary
	#
	class TDiaryReplace < TDiaryUpdate
		def initialize( cgi, rhtm, confl )
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
					@diary.each_comment( 100 ) do |com|
						com.show = @cgi.params[(idx += 1).to_s][0] == 'true' ? true : false;
					end
					self << @diary
					clear_cache
					dirty = DIRTY_COMMENT
				end
				dirty
			end
		end
	end

	#
	# class TDiaryFormPlugin
	#  show edit diary form after calling form plugin.
	#
	class TDiaryFormPlugin < TDiaryBase
		def initialize( cgi, rhtm, confl )
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
	class TDiaryConf < TDiaryBase
		def initialize( cgi, rhtml, conf )
			super
			@key = @cgi.params['conf'][0]
	
#			@themes = []
#			Dir::glob( "#{PATH}/theme/*" ).sort.each do |dir|
#				theme = dir.sub( %r[.*/theme/], '')
#				next unless FileTest::file?( "#{dir}/#{theme}.css".untaint )
#				name = theme.split( /_/ ).collect{|s| s.capitalize}.join( ' ' )
#				@themes << [theme,name]
#			end
		end
	end

	#
	# class TDiarySaveConf
	#  save configuration
	#
	class TDiarySaveConf < TDiaryConf
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
	
			# save referer to latest
			if referer?
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
			end
		end
	
		def last_modified
			lm = Time::at( 0 )
			@diaries.each_value do |diary|
				lmd = diary.last_modified
				lm = lmd if lm < lmd
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
	
		def referer?
			valid = true
			if @cgi.referer and %r|^https?://|i =~ @cgi.referer then
				ref = CGI::unescape( @cgi.referer.sub( /#.*$/, '' ).sub( /\?\d{8}$/, '' ) )
				@conf.no_referer.each do |noref|
					valid = false if /#{noref}/i =~ ref
				end
			else
				valid = false
			end
			valid
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
		def initialize( cgi, rhtm, confl )
			super
			begin
				# time is noon for easy to calc leap second.
				load( Time::local( *@cgi.params['date'][0].scan( /^(\d{4})(\d\d)(\d\d)$/ )[0] ) + 12*60*60 )
			rescue ArgumentError, NameError
				raise TDiaryError, 'bad date'
			end
			@diary = nil if @diary and not @diary.visible?
		end
	
		def load( date )
			if not @diary or (@diary.date.dup + 12*60*60).gmtime.strftime( '%Y%m%d' ) != date.dup.gmtime.strftime( '%Y%m%d' ) then
				@date = date
				@io.transaction( @date ) do |diaries|
					@diaries = diaries
					dirty = DIRTY_NONE
					@diary = self[@date]
					if @diary and referer? then
						@diary.add_referer( @cgi.referer )
						dirty = DIRTY_REFERER
					end
					dirty
				end
			else
				@date = date
				@diary = self[@date]
			end
		end
	
		def last_modified
			@diary ? @diary.last_modified : Time::at( 0 )
		end
	
	protected
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
	
		def load( date )
			@date = date
			@name = @cgi.params['name'][0].to_euc
			@mail = @cgi.params['mail'][0]
			@body = @cgi.params['body'][0].to_euc
			dirty = DIRTY_NONE
			@io.transaction( @date ) do |diaries|
				@diaries = diaries
				@diary = self[@date]
				if @diary and not (@name.strip.empty? or @body.strip.empty?) then
					@comment = Comment::new( @name, @mail, @body )
					if @diary.add_comment( @comment ) then
						dirty = DIRTY_COMMENT
						cookie_path = File::dirname( @cgi.script_name )
						cookie_path += '/' if cookie_path !~ /\/$/
						@cookies << CGI::Cookie::new( {
							'name' => 'tdiary',
							'value' => [@name,@mail],
							'path' => cookie_path,
							'expires' => Time::now.gmtime + 90*24*60*60 # 90days
						} )
					end
				end
				dirty
			end
		end
	
	protected
		def do_eval_rhtml( prefix )
			load_plugins
			@plugin.instance_eval { update_proc }
			anchor = @plugin.instance_eval( %Q[anchor "#{@diary.date.strftime('%Y%m%d')}"].untaint )
			raise ForceRedirect::new( "#{@conf.index}#{anchor}#c#{'%02d' % @diary.count_comments( true )}" )
		end
	end

	#
	# class TDiaryMonth
	#  show month mode view
	#
	class TDiaryMonth < TDiaryView
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
						dirty = DIRTY_NONE
						@diary = @diaries[@diaries.keys.sort.reverse[0]]
						if referer? and @diary then
							@diary.add_referer( @cgi.referer )
							dirty = DIRTY_REFERER
						end
						dirty
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
	class TDiaryNYear < TDiaryView
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
	# class TDiaryLatest
	#  show latest mode view
	#
	class TDiaryLatest < TDiaryView
		def initialize( cgi, rhtml, conf )
			super
			ym = latest_month
			unless @date then
				@date = ym ? Time::local( ym[0], ym[1] ) : Time::now
				@io.transaction( @date ) do |diaries|
					@diaries = diaries
					@diary = @diaries[@diaries.keys.sort.reverse[0]]
					DIRTY_NONE
				end
			end
	
			if ym then
				y = ym[0].to_i
				m = ym[1].to_i
				oldest = oldest_month
				calc_diaries_size
				while ( oldest and @diaries_size < @conf.latest_limit )
					date = if m == 1 then
						Time::local( y -= 1, m = 12 )
					else
						Time::local( y, m -= 1 )
					end
					break if date < Time::local( *oldest )
					@io.transaction( date ) do |diaries|
						@diaries.update( diaries )
						calc_diaries_size
						DIRTY_NONE
					end
				end
			end
		end
	
	protected
		def calc_diaries_size
			@diaries_size = 0
			@diaries.each_value do |diary|
				@diaries_size += 1 if diary.visible?
			end
		end
	
		def latest( limit = 5 )
			idx = 0
			@diaries.keys.sort.reverse_each do |date|
				break if idx >= limit
				diary = @diaries[date]
				next unless diary.visible?
				yield diary
				idx += 1
			end
		end
	
		def cache_file( prefix )
			"#{prefix}#{@rhtml.sub( /\.rhtml$/, '.rb' )}"
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
			@specified = @cgi.params['category']
			@specified.delete("ALL")
			@categorized = {}
			@last_modified = Time.at(0)
			@year, @months, @quarter = parse_cgi_param
		end

		def each_day
			@diaries.keys.sort.each do |date|
				diary = @diaries[date]
				next unless diary.visible?
				yield diary
			end
		end

		def categorize
			each_day do |d|
				next unless d.categorizable?
				idx = 1
				d.each_section do |s|
					s.categories.each do |c|
						if @specified.size == 0 or @specified.include?(c)
							@categorized[c] ||= []
							@categorized[c] << [d.date, idx, s]
							if @last_modified < d.last_modified
								@last_modified = d.last_modified
							end
						end
					end
					idx += 1
				end
			end
		end

		def parse_cgi_param
			if @cgi.valid?('year')
				year = @cgi.params['year'][0].to_i
			end
			if @cgi.valid?('month')
				case @cgi.params['month'][0]
				when /(\d)Q/
					q = $1.to_i
					months = (((q - 1) * 3 + 1)..((q - 1) * 3 + 3)).to_a
				when /\d{1,2}/
					month = @cgi.params['month'][0].to_i
					if (1..12).include?(month)
						months = [month]
					end
				end
			end
			year ||= Time.now.year
			months ||= [Time.now.month]
			[year, months, q]
		end
	end

	#
	# class TDiaryCategoryMonth
	#  show category by month
	#
	class TDiaryCategoryMonth < TDiaryCategoryView
		def initialize(cgi, rhtml, conf)
			super
			@months.each do |m|
				@date = Time::local(@year, m, 1)
				@io.transaction(@date) do |diaries|
					@diaries = diaries
					DIRTY_NONE
				end
				categorize
			end
		end
	end

	#
	# class TDiaryCategoryYear
	#  show category by year
	#
	class TDiaryCategoryYear < TDiaryCategoryView
		def initialize(cgi, rhtml, conf)
			super
			calendar
			@date = Time::local(@year, 1, 1)
			@years[@year.to_s].each do |m|
				@date = Time::local(@year, m, 1)
				@io.transaction(@date) do |diaries|
					@diaries = diaries
					DIRTY_NONE
				end
				categorize
			end
		end
	end

	#
	# class TDiaryCategoryLatest
	#  show category in latest month
	#
	class TDiaryCategoryLatest < TDiaryCategoryView
		def initialize(cgi, rhtml, conf)
			super
			@date = Time.now
			@io.transaction(@date) do |diaries|
				@diaries = diaries
				DIRTY_NONE
			end
			categorize
		end
	end

	#
	# exception class for TrackBack
	#
	class TDiaryTrackBackError < StandardError
	end

	#
	# class TDiaryTrackBackBase
	#
	class TDiaryTrackBackBase < TDiaryBase
		public :mode
		def initialize( cgi, rhtml, conf )
			super
			date = ENV['REQUEST_URI'].scan(%r!/(\d{4})(\d\d)(\d\d)!)[0]
			@date = Time::local(*date)
		end

		def referer?
			nil
		end

		def trackback_url
			'http://' + ENV['HTTP_HOST'] +
				(ENV['SERVER_PORT'] == '80' ? '' : ":#{ENV['SERVER_PORT']}") +
				ENV['REQUEST_URI']
		end

		def diary_url
			trackback_url.sub(/#{File::basename(ENV['SCRIPT_NAME'])}.*$/, '') +
				@conf.index.sub(%r|^\./|, '') +
				@plugin.instance_eval(%Q|anchor "#{@date.strftime('%Y%m%d')}"|)
		end

		def self.success_response
			<<HERE
<?xml version="1.0" encoding="iso-8859-1"?>
<response>
<error>0</error>
</response>
HERE
		end

		def self.fail_response(reason)
			<<HERE
<?xml version="1.0" encoding="iso-8859-1"?>
<response>
<error>1</error>
<message>#{reason}</message>
</response>
HERE
		end
	end

	#
	# class TDiaryTrackBackRSS
	#  generate RSS
	#
	class TDiaryTrackBackRSS < TDiaryTrackBackBase
		def initialize( cgi, rhtml, conf )
			super
			@io.transaction( @date ) do |diaries|
				@diaries = diaries
				@diary = @diaries[@date.strftime('%Y%m%d')]
				DIRTY_NONE
			end
		end

		def eval_rhtml( prefix = '' )
			raise TDiaryTrackBackError.new("invalid date: #{@date.strftime('%Y%m%d')}") unless @diary
			load_plugins
			r = <<RSSHEAD
<?xml version="1.0" encoding="EUC-JP"?>
<response>
<error>0</error>
<rss version="0.91">
<channel>
<title>#{@diary.title}</title>
<link>#{diary_url}</link>
<description></description>
<language>ja-jp</language>
RSSHEAD
			@diary.each_comment(100) do |com, idx|
				begin
					next unless com.visible_true?
				rescue NameError, NoMethodError
					next unless com.visible?
				end
				next unless /^(Track|Ping)Back$/ =~ com.name
				url, blog_name, title, excerpt = com.body.split(/\n/, 4)
				r << <<RSSITEM
<item>
<title>#{CGI::escapeHTML( title )}</title>
<link>#{CGI::escapeHTML( url )}</link>
<description>#{CGI::escapeHTML( excerpt )}</description>
</item>
RSSITEM
			end
			r << <<RSSFOOT
</channel>
</rss>
</response>
RSSFOOT
		end
	end

	#
	# class TDiaryTrackBackReceive
	#  receive TrackBack ping and store as comment
	#
	class TDiaryTrackBackReceive < TDiaryTrackBackBase
		def initialize( cgi, rhtml, conf )
			super
			@error = nil

			begin
				require 'uconv'
				@have_uconv = true
			rescue LoadError
				@have_uconv = false
			end

			url = @cgi.params['url'][0]
			blog_name = to_euc(@cgi.params['blog_name'][0] || '')
			title = to_euc(@cgi.params['title'][0] || '')
			excerpt = to_euc(@cgi.params['excerpt'][0] || '')

			body = [url, blog_name, title, excerpt].join("\n")
			@cgi.params['name'] = ['TrackBack']
			@cgi.params['body'] = [body]

			@comment = Comment::new('TrackBack', '', body)
			begin
				@io.transaction( @date ) do |diaries|
					@diaries = diaries
					if @diaries[@date.strftime('%Y%m%d')].add_comment(@comment)
						DIRTY_COMMENT
					else
						@error = "repeated TrackBack Ping"
						DIRTY_NONE
					end
				end
			rescue
				@error = $!.message
			end
		end

		def eval_rhtml( prefix = '' )
			raise TDiaryTrackBackError.new(@error) if @error
			super
			TDiaryTrackBackBase::success_response
		end
	private
		def to_euc(str)
			if @have_uconv
				begin
					ret = Uconv.u8toeuc(str)
				rescue Uconv::Error
					ret = str.to_euc
				end
			else
				ret = str.to_euc
			end
		end
	end

	#
	# class TDiaryTrackBackShow
	#  show TrackBacks
	#
	class TDiaryTrackBackShow < TDiaryTrackBackBase
		def eval_rhtml( prefix = '' )
			load_plugins
			anchor = @plugin.instance_eval(%Q|anchor "#{@date.strftime('%Y%m%d')}"|)
			raise ForceRedirect::new("../#{@conf.index}#{anchor}#t")
		end
	end
end
