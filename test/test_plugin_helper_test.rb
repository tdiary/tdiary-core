# Test cases for test_plugin_helper.rb
require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../test_plugin_helper', __FILE__)

class TestPluginTestHelper < Test::Unit::TestCase
	include TDiary::PluginTestHelper

	def test_absolute_path_of
		abspath = File.expand_path(File.join(File.dirname(__FILE__), '..', 'plugin', '00default.rb'))
		assert_equal(abspath, TDiary::PluginTestHelper.absolute_path_of('plugin/00default.rb'))
	end

	def test_resource_absolute_path_of
		abspath = File.expand_path(File.join(File.dirname(__FILE__), '..', 'plugin', 'en', '00default.rb'))
		assert_equal(abspath, TDiary::PluginTestHelper.resource_absolute_path_of('plugin/00default.rb', 'en'))
	end

	def test_resource_relative_path_of
		abspath = File.join('plugin', 'en', '00default.rb')
		assert_equal(abspath, TDiary::PluginTestHelper.resource_relative_path_of('plugin/00default.rb', 'en'))
	end

	def test_new_plugin
		assert_nothing_raised do
			TDiary::StubPlugin::new_plugin('plugin/00default.rb', 'en')
		end
	end

	def test_load_plugin
		assert_nothing_raised do
			TDiary::StubPlugin::load_plugin('plugin/00default.rb', 'en')
		end
	end

	def test_plugin_conf
		plugin = TDiary::StubPlugin::load_plugin('plugin/00default.rb', 'en')
		assert_nothing_raised do
			plugin.conf['key'] = 'value'
		end
		assert_equal('value', plugin.conf['key'])
	end

	def test_plugin_options
		plugin = TDiary::StubPlugin::load_plugin('plugin/00default.rb', 'en')
		assert_nothing_raised do
			plugin.options['key'] = 'value'
		end
		assert_equal('value', plugin.options['key'])
	end
end
