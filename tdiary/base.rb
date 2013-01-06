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

		attr_reader :cookies, :date, :diaries
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
				r = ERB.new(File.read("#{PATH}/skel/plugin_error.rhtml").untaint).result(binding)
			rescue Exception
				raise
			end
			r
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
			load_plugins

			r = @io.restore_cache( prefix )

			if r.nil?
				r = erb_src(prefix)
				@io.store_cache( r, prefix ) unless @diaries.empty?
			end

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

		def load_logger
			return if @logger

			log_path = (@conf.log_path || "#{@conf.data_path}log").untaint
			FileUtils.mkdir_p(log_path) unless FileTest.directory?(log_path)

			@logger = Logger.new(File.join(log_path, "debug.log"), 'daily')
			@logger.level = Logger.const_get(@conf.log_level || 'DEBUG')
			@logger
		end

	private

		def erb_src(prefix)
			rhtml = ["header.rhtml", @rhtml, "footer.rhtml"].map do |file|
				path = "#{PATH}/skel/#{prefix}#{file}"
				begin
					File.read("#{path}.#{@conf.lang}")
				rescue
					File.read(path)
				end
			end.join

			begin
				r = ERB.new(rhtml.untaint).result(binding)
			rescue => e
				# migration error on ruby 1.9 only 1st time, reload.
				if defined?(::Encoding) && e.class == ::Encoding::CompatibilityError
					raise ForceRedirect.new(@conf.base_url)
				end
			end
			ERB.new(r).src
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
