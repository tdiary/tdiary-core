=begin
== NAME
tDiary: the "tsukkomi-able" web diary system.
tdiary.rb $Revision: 1.50 $

Copyright (C) 2001-2002, TADA Tadashi <sho@spc.gr.jp>
=end

TDIARY_VERSION = '1.5.0.20020826'

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
			gsub( ' ', "\001" ).
			gsub( '<', "\002" ).
			gsub( '>', "\003" ).
			gsub( '&', '&amp;' ).
			gsub( r ){ $1 == $2 ? "<a href=\"#$2\">#$2</a>" : "<a href=\"mailto:#$4\">#$4</a>" }.
			gsub( "\003", '&gt;' ).
			gsub( "\002", '&lt;' ).
			gsub( "\001", '&nbsp;' ).
			gsub( "\t", '&nbsp;' * 8 )
	end

	def shorten( len = 120 )
		lines = NKF::nkf( "-e -m0 -f#{len}", self.gsub( "\n", ' ' ) ).split( "\n" )
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
		self[param] and self[param][idx] and self[param][idx].length > 0
	end

	def mobile_agent?
		self.user_agent =~ %r[(DoCoMo|J-PHONE|UP\.Browser|ASTEL|PDXGW|Palmscape|Xiino|sharp pda browser|Windows CE|L-mode)]i
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

=begin
== Comment class
Management a comment.
=end
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

=begin
== CommentManager module
Management comments in a day. Include in Diary class.
=end
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
			@last_modified = Time::now
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

=begin
== RefererManager module
Management referers in a day. Include in Diary class.
=end
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
			pair = [pair, ref] if pair.type != Array # for compatibility
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
				if count.type != Array then
					@referers.delete( ref )
					@referers[CGI::unescape( ref )] = [count, ref]
				end
			end
			@new_referer = true
		end
	end
end

=begin
== DiaryBase module
Base module of Diary.
=end
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
		if date.type == String then
			y, m, d = date.scan( /(\d{4})(\d\d)(\d\d)/ )[0]
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

=begin
== TDiary class
tDiary CGI
=end
class TDiary
	class TDiaryError < StandardError; end
	class PermissionError < TDiaryError; end
	class PluginError < TDiaryError; end

	# base of IO class
	class IOBase
		def calendar
			raise StandardError, 'not implemented'
		end
		
		def transaction( date )
			raise StandardError, 'not implemented'
		end

		def diary_factory( date, title, body, format = nil )
			raise StandardError, 'not implemented'
		end
	end

	# force redirect to another page
	class ForceRedirect < StandardError
		attr_reader :path
		def initialize( path )
			@path = path
		end
	end

	class Plugin
		attr_reader :cookies

		def initialize( params )
			@header_procs = []
			@update_procs = []
			@body_enter_procs = []
			@body_leave_procs = []
			@cookies = []
			params.each_key do |key|
				eval( "@#{key} = params['#{key}']" )
			end
		end

		def eval_src( src, secure )
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

		def add_cookie( cookie )
			@cookies << cookie
		end

		def method_missing( *m )
			super if @debug
			# ignore when no plugin
		end
	end

	PATH = File::dirname( __FILE__ )

	DIRTY_NONE = 0
	DIRTY_DIARY = 1
	DIRTY_COMMENT = 2
	DIRTY_REFERER = 4

	attr_reader :cookies
	attr_reader :data_path

	def initialize( cgi, rhtml )
		@cgi = cgi
		@diaries = {}
		@cookies = []
		@rhtml = rhtml
		load_conf

		unless @io_class then
			#require 'tdiary/defaultio'
			#@io_class = DefaultIO::IO
			require 'tdiary/pstoreio'
			@io_class = TDiary::PStoreIO
		end
		@io = @io_class.new( self )
	end

	def eval_rhtml( prefix = '' )
		if cache_enable?( prefix ) then
			r = File::open( "#{cache_path}/#{cache_file( prefix )}" ) {|f| f.read }
		else
			files = ["header.rhtml", @rhtml, "footer.rhtml"]
			rhtml = files.collect {|file|
				File::open( "#{PATH}/skel/#{prefix}#{file}" ) {|f| f.read }
			}.join
			r = ERbLight::new( rhtml.untaint ).result( binding )
			r = ERbLight::new( r ).src
			store_cache( r, prefix )
		end

		# apply plugins
		begin
			@plugin = load_plugins
			r = @plugin.eval_src( r.untaint, @secure ) if @plugin
			@cookies += @plugin.cookies
		rescue PluginError
			raise
		rescue Exception
			r = ERbLight::new( File::open( "#{PATH}/skel/plugin_error.rhtml" ) {|f| f.read } ).result( binding )
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
	def load_conf
		@secure = true unless @secure
		@options = {}
		eval( File::open( "tdiary.conf" ){|f| f.read }.untaint )

		@data_path += '/' if /\/$/ !~ @data_path
		@smtp_port = 25 unless @smtp_port
		@index = './' unless @index
		@update = 'update.rb' unless @update
		@options = {} unless @options.type == Hash

		@index_page = '' unless @index_page
		@date_format = '%Y-%m-%d' unless @date_format
		@theme = 'default' if not @theme and not @css
		@no_referer = [] unless @no_referer
		@no_referer2 = [] unless @no_referer2
		@no_referer = @no_referer2 + @no_referer
		@referer_table = [] unless @referer_table
		@referer_table2 = [] unless @referer_table2
		@referer_table = @referer_table2 + @referer_table
		@mail_on_comment = false unless @mail_on_comment
		@mail_receivers = [@author_mail] if not @mail_receivers or @mail_receivers.size == 0
		@mail_header = '' unless @mail_header
		@hour_offset = 0 unless @hour_offset

		# for 1.4 compatibility
		@section_anchor = @paragraph_anchor unless @section_anchor
	end

	def load_cgi_conf
		raise TDiaryError, 'No @data_path variable.' unless @data_path

		@data_path += '/' if /\/$/ !~ @data_path
		raise TDiaryError, 'Do not set @data_path as same as tDiary system directory.' if @data_path == "#{PATH}/"

		variables = [
			:author_name,
			:author_mail,
			:index_page,
			:html_title,
			:header,
			:footer,
			:section_anchor,
			:comment_anchor,
			:date_format,
			:latest_limit,
			:theme,
			:css,
			:show_comment,
			:comment_limit,
			:show_referer,
			:referer_limit,
			:no_referer2,
			:referer_table2,
			:mail_on_comment,
			:mail_header,
			:hour_offset,
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
		rescue
			@error = $!.dup
			@error << "<br>#{$@.join '<br>'}" if $DEBUG
		end
	end

	def load_plugins
		calendar
		plugin = Plugin::new( {
			'mode' => self.type.to_s.sub( /^TDiary/, '' ).downcase,
			'diaries' => @diaries,
			'cgi' => @cgi,
			'years' => @years,
			'cache_path' => cache_path,
			'index' => @index,
			'update' => @update,
			'author_name' => @author_name || '',
			'author_mail' => @author_mail || '',
			'index_page' => @index_page || '',
			'html_title' => @html_title || '',
			'theme' => @theme,
			'css' => @css,
			'date' => @date,
			'date_format' => @date_format,
			'referer_table' => @referer_table,
			'options' => @options,
		} )
		plugin_file = ''
		begin
			Dir::glob( "#{PATH}/plugin/*.rb" ).sort.each do |file|
				plugin_file = file
				open( plugin_file.untaint ) do |src|
					plugin.instance_eval( src.read.untaint )
				end
			end
		rescue Exception
			raise PluginError::new( "Plugin error in '#{File::basename( plugin_file )}'.\n#{$!}" )
		end
		return plugin
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
		@cache_path || "#{@data_path}cache"
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
		obj
	end

	def calendar
		@years = @io.calendar unless @years
	end
end

class TDiaryAdmin < TDiary
	def initialize( cgi, rhtml )
		super
		begin
			@date = Time::local( @cgi['year'][0].to_i, @cgi['month'][0].to_i, @cgi['day'][0].to_i )
		rescue ArgumentError, NameError
			raise TDiaryError, 'bad date'
		end
	end
end

class TDiaryAppend < TDiaryAdmin
	def initialize( cgi, rhtml )
		super

		@title = @cgi['title'][0].to_euc
		@body = @cgi['body'][0].to_euc
		@author = @multi_user ? @cgi.remote_user : nil
		@hide = @cgi['hide'][0] ? true : false

		@io.transaction( @date ) do |diaries|
			@diaries = diaries
			@diary = self[@date] || @io.diary_factory( @date, @title, '' )
			self << @diary.append( @body, @author )
			@diary.title = @title unless @title.empty?
			@diary.show( ! @hide )
			DIRTY_DIARY
		end
	end
end

class TDiaryEdit < TDiaryAdmin
	def initialize( cgi, rhtml )
		super

		#raise TDiaryError, 'cannot edit in multi user mode' if @multi_user

		@io.transaction( @date ) do |diaries|
			@diaries = diaries
			@diary = self[@date] || @io.diary_factory( @date, '', '' )
			DIRTY_NONE
		end
	end
end

class TDiaryReplace < TDiaryAdmin
	def initialize( cgi, rhtml )
		super

		@title = @cgi['title'][0].to_euc
		@body = @cgi['body'][0].to_euc
		old_date = Time::local( *@cgi['old'][0].scan( /(\d{4})(\d\d)(\d\d)/ )[0] )
		old_date, = @cgi['old']
		@hide = @cgi['hide'][0] ? true : false

		@io.transaction( @date ) do |diaries|
			@diaries = diaries
			@diary = self[@date]
			if @diary then
				if @date.strftime( '%Y%m%d' ) != old_date then
					@diary.append( @body, @append )
					@diary.title = @title if @title.length > 0
				else
					@diary.replace( @date, @title, @body )
				end
			else
				@diary = @io.diary_factory( @date, @title, @body )
			end
			@diary.show( ! @hide )
			self << @diary
			DIRTY_DIARY
		end
	end
end

class TDiaryForm < TDiaryAdmin
	def initialize( cgi, rhtml )
		begin
			super
		rescue TDiaryError
		end
		@date = Time::now + (@hour_offset * 3600).to_i
		@diary = @io.diary_factory( @date, '', '' )
	end
end

class TDiaryShowComment < TDiaryAdmin
	def initialize( cgi, rhtml )
		super

		@io.transaction( @date ) do |diaries|
			@diaries = diaries
			dirty = DIRTY_NONE
			@diary = self[@date]
			if @diary then
				idx = 0
				@diary.each_comment( 100 ) do |com|
					com.show = @cgi[(idx += 1).to_s][0] == 'true' ? true : false;
				end
				self << @diary
				clear_cache
				dirty = DIRTY_COMMENT
			end
			dirty
		end
	end
end

class TDiaryConf < TDiary
	def initialize( cgi, rhtml )
		super

		@themes = []
		Dir::glob( "#{PATH}/theme/*" ).sort.each do |dir|
			theme = dir.sub( %r[.*/theme/], '')
			next unless FileTest::file?( "#{dir}/#{theme}.css" )
			name = theme.split( /_/ ).collect{|s| s.capitalize}.join( ' ' )
			@themes << [theme,name]
		end
	end
end

class TDiarySaveConf < TDiaryConf
	def initialize( cgi, rhtml )
		super

		@author_name = @cgi['author_name'][0].to_euc
		@author_mail, = @cgi['author_mail']
		@index_page, = @cgi['index_page']

		@html_title = @cgi['html_title'][0].to_euc
		@header = @cgi['header'][0].to_euc.gsub( "\r\n", "\n" ).gsub( "\r", '' ).sub( /\n+\z/, '' )
		@footer = @cgi['footer'][0].to_euc.gsub( "\r\n", "\n" ).gsub( "\r", '' ).sub( /\n+\z/, '' )

		@section_anchor = @cgi['section_anchor'][0].to_euc
		@comment_anchor = @cgi['comment_anchor'][0].to_euc
		@date_format = @cgi['date_format'][0].to_euc
		@latest_limit = @cgi['latest_limit'][0].to_i
		@latest_limit = 10 if @latest_limit < 1

		@theme, = @cgi['theme']
		@css, = @cgi['css']

		@show_comment = @cgi['show_comment'][0] == 'true' ? true : false
		@comment_limit = @cgi['comment_limit'][0].to_i
		@comment_limit = 3 if @comment_limit < 1

		@show_referer = @cgi['show_referer'][0] == 'true' ? true : false
		@referer_limit = @cgi['referer_limit'][0].to_i
		@referer_limit = 10 if @referer_limit < 1
		@no_referer2 = []
		@cgi['no_referer'][0].to_euc.each do |ref|
			ref.strip!
			@no_referer2 << ref if ref.length > 0
		end
		@referer_table2 = []
		@cgi['referer_table'][0].to_euc.each do |pair|
			u, n = pair.sub( /[\r\n]+/, '' ).split( /[ \t]+/, 2 )
			@referer_table2 << [u,n] if u and n
		end

		@mail_on_comment = @cgi['mail_on_comment'][0] == 'true' ? true : false
		@mail_header, = @cgi['mail_header']

		@hour_offset = @cgi['hour_offset'][0].to_f

		begin
			result = ERbLight::new( File::open( "#{PATH}/skel/tdiary.rconf" ){|f| f.read }.untaint ).result( binding )
			result.untaint unless @secure
			Safe::safe( @secure ? 4 : 1 ) do
				eval( result )
			end
			File::open( "#{@data_path}tdiary.conf", 'w' ) do |o|
				o.print result
			end

			clear_cache

		rescue
			@error = $!.dup
			@error << "<br>#{$@.join '<br>'}" if $DEBUG
		end
	end
end

class TDiaryView < TDiary
	def initialize( cgi, rhtml )
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
		return @last_modified if @last_modified
		@last_modified = Time::at( 0 )
		@diaries.each_value do |diary|
			@last_modified = diary.last_modified if @last_modified < diary.last_modified
		end
		@last_modified
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
			@no_referer.each do |noref|
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

class TDiaryDay < TDiaryView
	def initialize( cgi, rhtml )
		super
		begin
			# time is noon for easy to calc leap second.
			load( Time::local( *@cgi['date'][0].scan( /^(\d{4})(\d\d)(\d\d)$/ )[0] ) + 12*60*60 )
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

class TDiaryComment < TDiaryDay
	def initialize( cgi, rhtml )
		super
	end

	def load( date )
		@date = date
		@name = @cgi['name'][0].to_euc
		@mail, = @cgi['mail']
		@body = @cgi['body'][0].to_euc
		dirty = DIRTY_NONE
		@io.transaction( @date ) do |diaries|
			@diaries = diaries
			@diary = self[@date]
			if @diary and not (@name.strip.empty? or @body.strip.empty?) then
				if @diary.add_comment( Comment::new( @name, @mail, @body ) ) then
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

		# sending mail
		if dirty and @mail_on_comment then
			require 'socket'

			name = to_mime( @name.to_jis )[0]
			body = @body.to_jis
			mail = @mail
			mail = @author_mail unless mail =~ %r<[0-9a-zA-Z_.-]+@[\(\)%!0-9a-zA-Z_$@.&+-,'"*-]+>
			
			now = Time::now
			g = now.dup.gmtime
			l = Time::local( g.year, g.month, g.day, g.hour, g.min, g.sec )
			tz = (g.to_i - l.to_i) / 36
			date = now.strftime( "%a, %d %b %Y %X " ) + sprintf( "%+05d", tz )
	
			serial = @diary.count_comments( true )
			message_id = %Q|<tdiary.#{[@mail_header].pack('m').gsub("\n",'')}.#{now.strftime('%Y%m%d%H%M%S')}.#{serial}@#{Socket::gethostname.sub(/^.+?\./,'')}>|

			mail_header = @mail_header.dup
			mail_header << ":#{@date_format}" unless /%[a-zA-Z%]/ =~ mail_header
			mail_header = @date.strftime( mail_header )
			mail_header = to_mime( mail_header.to_jis ).join( "\n " ) if /[\x80-\xff]/ =~ mail_header

			text = ERbLight::new( File::open( "#{PATH}/skel/mail.rtxt" ){|f| f.read }.untaint ).result( binding )
			sendmail( text )
		end
	end

	def eval_rhtml( prefix = '' )
		super
		anchor = @plugin.instance_eval( %Q[anchor "#{@diary.date.strftime('%Y%m%d')}"].untaint )
		raise ForceRedirect::new( "#{@index}#{anchor}#c#{'%02d' % @diary.count_comments( true )}" )
	end

protected
	def sendmail( text )
		return unless @smtp_host
		begin
			require 'net/smtp'
			Net::SMTP.start( @smtp_host, @smtp_port ) do |smtp|
				smtp.ready( @author_mail, @mail_receivers ) do |adapter| adapter.write( text ) end
			end
		rescue
		end
	end

	def to_mime( str )
		NKF::nkf( "-j -m0 -f50", str ).collect do |s|
			%Q|=?ISO-2022-JP?B?#{[s.chomp].pack( 'm' ).gsub( "\n", '' )}?=|
		end
	end
end

class TDiaryMonth < TDiaryView
	def initialize( cgi, rhtml )
		super

		begin
			date = Time::local( *@cgi['date'][0].scan( /^(\d{4})(\d\d)$/ )[0] )
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

class TDiaryLatest < TDiaryView
	def initialize( cgi, rhtml )
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
			while ( oldest and @diaries_size < @latest_limit )
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

