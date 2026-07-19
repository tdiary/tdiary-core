module TDiary
	#
	# class TDiaryBase
	#  tDiary CGI
	#
	class TDiaryBase
		include ERB::Util
		include ViewHelper

		DIRTY_NONE = 0
		DIRTY_DIARY = 1
		DIRTY_COMMENT = 2
		DIRTY_REFERER = 4

		attr_reader :cookies, :date, :diaries
		attr_reader :request, :cgi, :rhtml, :conf
		attr_reader :ignore_parser_cache

		def initialize( request, rhtml, conf )
			if request.respond_to?( :cgi_compat )
				@request = request
				@cgi = request.cgi_compat
			else
				# transitional: 00default.rb's month navigation hands a cloned
				# @cgi facade with rewritten params, which must stay @cgi as-is
				@cgi = request
				@request = request.respond_to?( :request ) ? request.request : nil
			end
			@rhtml, @conf = rhtml, conf
			@diaries = {}
			@cookies = []
			@io = @conf.io_class.new( self )
			@ignore_parser_cache = false
		end

		def eval_rhtml( prefix = '' )
			begin
				r = do_eval_rhtml( prefix )
			rescue PluginError, SyntaxError, ArgumentError, Exception => e
				if e.class == ForceRedirect
					raise
				else
					body = File.read("#{File.dirname(__FILE__)}/../../views/plugin_error.rhtml")
					r = ERB.new(body).result(binding)
				end
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
				r = @rhtml ? erb_src(prefix) : ""
				@io.store_cache( r, prefix ) unless @diaries.empty?
			end

			r = @plugin.eval_src( r ) if @plugin

			@cookies += @plugin.cookies

			r
		end

		def mode
			self.class.to_s.sub( /^TDiary::TDiary/, '' ).downcase
		end

		def load_plugins
			calendar
			#
			# caching plugin
			# NOTE: currently, plugin cache doesn't work with blog-category plugin
			#       see also https://github.com/tdiary/tdiary-core/issues/203
			#
			if @plugin and not @plugin.respond_to?( 'blog_category' )
				@plugin.diaries = @diaries
				@plugin.date = @date
				@plugin.last_modified = last_modified
				@plugin.comment = @comment
				@plugin
			elsif (cached = reusable_cached_plugin)
				# reuse a plugin instance loaded by a previous request, skipping
				# the file read + instance_eval of every plugin file.
				@plugin = cached.prepare_for_reuse( plugin_params )
			else
				@plugin = Plugin::new( plugin_params )
				if plugin_cache_enabled? and not @plugin.respond_to?( 'blog_category' )
					Plugin.cache_store( plugin_cache_key, @plugin )
				end
				@plugin
			end
		end

		# read-only views whose plugins do no request-specific work at load time,
		# so a loaded instance is safe to reuse across requests.
		PLUGIN_CACHEABLE_MODES = %w[latest day month nyear].freeze

		def plugin_cache_enabled?
			@conf.options['plugin.cache'] && PLUGIN_CACHEABLE_MODES.include?( mode )
		end

		def plugin_cache_key
			[mode, @conf.data_path]
		end

		def reusable_cached_plugin
			return nil unless plugin_cache_enabled?
			cached = Plugin.cache_fetch( plugin_cache_key )
			return nil unless cached
			return nil if cached.respond_to?( 'blog_category' )
			cached
		end

		def plugin_params
			{
				'conf' => @conf,
				'mode' => mode,
				'diaries' => @diaries,
				'cgi' => @cgi,
				'request' => @request,
				'years' => @years,
				'cache_path' => @io.cache_path,
				'date' => @date,
				'comment' => @comment,
				'last_modified' => last_modified,
				'logger' => TDiary.logger
			}
		end

		def <<( diary )
			@diaries[diary.date.strftime( '%Y%m%d' )] = diary
		end

		def delete( date )
			@diaries.delete( date.strftime( '%Y%m%d' ) )
		end

	private

		def erb_src(prefix)
			rhtml = ["header.rhtml", @rhtml, "footer.rhtml"].map do |file|
				path = "#{File.dirname(__FILE__)}/../../views/#{prefix}#{file}"
				begin
					File.read("#{path}.#{@conf.lang}")
				rescue
					File.read(path)
				end
			end.join

			begin
				r = ERB.new(rhtml).result(binding)
			rescue ::Encoding::CompatibilityError
				# migration error on ruby 1.9 only 1st time, reload.
				raise ForceRedirect.new(base_url)
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

	# class TDiaryPluginView
	#  base of plugin view mode classes
	#
	class TDiaryPluginView < TDiaryBase
		attr_reader :last_modified

		def initialize(cgi, rhtml, conf)
			super

			tdiary = tdiary_class(@cgi.params['date'][0] || '').new(@request, '', conf)
			@date = tdiary.date
			@diaries = tdiary.diaries
			@last_modified = Time.now
		end

		def eval_rhtml( prefix = '' )
			load_plugins
			# TODO: prefixでモバイルモードかどうかを判定
			# TODO: rhtml rendering
			@rhtml = "#{plugin_name}.rhtml"
			@plugin.__send__(:content_proc, plugin_name, @date.strftime('%Y%m%d'))
		end

		protected

		def plugin_name
			# plugin name MUST contain only words ([a-zA-Z0-9_])
			@plugin_name ||= (@cgi.params['plugin'][0] || '').match(/^(\w+)$/).to_a[1]
			raise TDiary::PermissionError.new('invalid plugin name') unless @plugin_name
			@plugin_name
		end

		def tdiary_class(date)
			# YYYYMMDD-N, YYYYMMDD, YYYYMM, MMDD, or nil
			case date
			when /^\d{8}-\d+$/
				TDiaryLatest
			when /^\d{8}$/
				TDiaryDay
			when /^\d{6}$/
				TDiaryMonth
			when /^\d{4}$/
				TDiaryNYear
			else
				TDiaryLatest
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
