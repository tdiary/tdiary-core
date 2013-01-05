module TDiary
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

