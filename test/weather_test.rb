# by @kou
# https://github.com/tdiary/tdiary-core/pull/218#issuecomment-10048898

require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../test_plugin_helper', __FILE__)

module EmptyRenderingTests
    def setup
        @plugin_class = TDiary::StubPlugin::new_plugin('misc/plugin/weather.rb', language)
        @weather = @plugin_class::Weather.new
    end

    def test_empty_rendering_to_html
        assert_equal('', @weather.to_html)
    end

    def test_empty_rendering_to_i_html
        assert_equal('', @weather.to_i_html)
    end
end

class TestEmptyRenderingEn < Test::Unit::TestCase
    include EmptyRenderingTests

    def language
        "en"
    end
end

class TestEmptyRenderingJa < Test::Unit::TestCase
    include EmptyRenderingTests

    def language
        "ja"
    end
end

