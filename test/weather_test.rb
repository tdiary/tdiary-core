require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../test_plugin_helper', __FILE__)

module EmptyRenderingTests
	def setup
		load_plugin('misc/plugin/weather.rb', language, binding)
		@weather = Weather.new
	end

	def test_empty_rendering_to_html
		assert_equal('', @weather.to_html)
	end

	def test_empty_rendering_to_i_html
		assert_equal('', @weather.to_i_html)
	end
end

class TestEmptyRenderingEn < TDiary::PluginTestCase
	include EmptyRenderingTests

	def language
		"en"
	end
end

class TestEmptyRenderingJa < TDiary::PluginTestCase
	include EmptyRenderingTests

	def language
		"ja"
	end
end
