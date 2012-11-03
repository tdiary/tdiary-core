# Test cases for test_plugin_helper.rb
require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../test_plugin_helper', __FILE__)

class TestPluginHelper < TDiary::PluginTestCase
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

	def test_load_plugin_en
		assert_nothing_raised{load_plugin('plugin/00default.rb', 'en', binding)}
	end

	def test_load_plugin_ja
		assert_nothing_raised{load_plugin('plugin/00default.rb', 'ja', binding)}
	end
end
