# -*- coding: utf-8 -*-
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
		attr_reader :cgi, :rhtml, :conf
		attr_reader :ignore_parser_cache

		def initialize( cgi, rhtml, conf )
			@cgi, @rhtml, @conf = cgi, rhtml, conf
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
					body = File.read("#{File.dirname(__FILE__)}/../../views/plugin_error.rhtml").untaint
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

			r = @plugin.eval_src( r.untaint ) if @plugin

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
			else
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
					'logger' => TDiary.logger
				)
			end
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
				r = ERB.new(rhtml.untaint).result(binding)
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

			tdiary = tdiary_class(cgi.params['date'][0] || '').new(cgi, '', conf)
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
