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

		def initialize
			@conf = Hash.new
		end

		def []=(k,v)
			@conf[k] = v
		end

		def [](k)
			return @conf[k]
		end
	end

	class StubPlugin
		def self.inherited(child)
			super
			child.module_eval(<<-EOS)
				def context
					binding
				end
			EOS
		end

		include TDiary::PluginTestStub

		def StubPlugin::_load_plugin(plugin_relative_path, lang = 'en')
			plugin_class = Class.new(StubPlugin)
			plugin = plugin_class.new(lang)
			plugin.load(plugin_relative_path)
			return plugin_class, plugin
		end

		def StubPlugin::load_plugin(plugin_relative_path, lang = 'en')
			return StubPlugin::_load_plugin(plugin_relative_path, lang)[1]
		end

		def StubPlugin::new_plugin(plugin_relative_path, lang = 'en')
			return StubPlugin::_load_plugin(plugin_relative_path, lang)[0]
		end

		attr_accessor :conf
		attr_accessor :options

		def initialize(lang = 'en')
			@lang = lang
			reset
		end

		def load(plugin_relative_path)
			reset
			ppath = TDiary::PluginTestHelper.absolute_path_of(plugin_relative_path)
			pl10n = TDiary::PluginTestHelper.resource_absolute_path_of(plugin_relative_path, @lang)
			File.open(pl10n){|f| eval(f.read, context, TDiary::PluginTestHelper.resource_relative_path_of(plugin_relative_path, @lang))}
			File.open(ppath){|f| eval(f.read, context, plugin_relative_path)}
		end

		def reset
			@options = {}
			@conf_genre_label = {}
			@conf = TDiary::ConfStub.new
		end
	end

	class StubPlugin
		def self.inherited(child)
			super
			child.module_eval(<<-EOS)
				def context
					binding
				end
			EOS
		end

		include TDiary::PluginTestStub

		def StubPlugin::_load_plugin(plugin_relative_path, lang = 'en')
			plugin_class = Class.new(StubPlugin)
			plugin = plugin_class.new(lang)
			plugin.load(plugin_relative_path)
			return plugin_class, plugin
		end

		def StubPlugin::load_plugin(plugin_relative_path, lang = 'en')
			return StubPlugin::_load_plugin(plugin_relative_path, lang)[1]
		end

		def StubPlugin::new_plugin(plugin_relative_path, lang = 'en')
			return StubPlugin::_load_plugin(plugin_relative_path, lang)[0]
		end

		def initialize(lang = 'en')
			@lang = lang
			reset
		end

		def load(plugin_relative_path)
			reset
			ppath = TDiary::PluginTestHelper.absolute_path_of(plugin_relative_path)
			pl10n = TDiary::PluginTestHelper.resource_absolute_path_of(plugin_relative_path, @lang)
			File.open(pl10n){|f| eval(f.read, context, TDiary::PluginTestHelper.resource_relative_path_of(plugin_relative_path, @lang))}
			File.open(ppath){|f| eval(f.read, context, plugin_relative_path)}
		end

		def reset
			@options = {}
			@conf_genre_label = {}
			@conf = TDiary::ConfStub.new
		end
	end
end
