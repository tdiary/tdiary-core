module TDiary
	module PluginTestStub
		def add_header_proc(*args); end
		def add_body_enter_proc(*args); end
		def add_update_proc(*args); end
		def add_conf_proc(*args); end
		def add_title_proc(*args); end
		def add_subtitle_proc(*args); end
		def add_footer_proc(*args); end
		def feed?; false; end
		def enable_js(*args); end
		def add_js_setting(*args); end
		def to_native( str, charset = nil )
			from = case charset
				when /^utf-8$/i
					'W'
				when /^shift_jis/i
					'S'
				when /^EUC-JP/i
					'E'
				else
					''
			end
			NKF::nkf( "-m0 -#{from}w", str )
		end
	end

	module PluginTestHelper
		def PluginTestHelper.absolute_path_of(plugin_relative_path)
			File.expand_path(File.join(File.dirname(__FILE__), '..', plugin_relative_path))
		end

		def PluginTestHelper.resource_relative_path_of(plugin_relative_path, lang)
			File.join(File.dirname(plugin_relative_path), lang, File.basename(plugin_relative_path))
		end

		def PluginTestHelper.resource_absolute_path_of(plugin_relative_path, lang)
			ppath = PluginTestHelper.absolute_path_of(plugin_relative_path)
			File.join(File.dirname(ppath), lang, File.basename(ppath))
		end
	end

	class ConfStub
		def style; 'tDiary'; end
	end

	class PluginTestCase < Test::Unit::TestCase
		include TDiary::PluginTestStub

		def add_stub_ivars
			@options = {}
			@conf_genre_label = {}
			@conf = TDiary::ConfStub.new
		end

		def load_plugin(plugin_relative_path, lang = 'en', context = binding)
			add_stub_ivars
			ppath = PluginTestHelper.absolute_path_of(plugin_relative_path)
			pl10n = PluginTestHelper.resource_absolute_path_of(plugin_relative_path, lang)
			File.open(pl10n){|f| eval(f.read, context, PluginTestHelper.resource_relative_path_of(plugin_relative_path, lang))}
			File.open(ppath){|f| eval(f.read, context, plugin_relative_path)}
		end
	end
end
