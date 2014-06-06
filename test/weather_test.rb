# encoding: utf-8
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

class TestUpdateWeatherUrl < Test::Unit::TestCase
	def setup
		@plugin = TDiary::StubPlugin::load_plugin('misc/plugin/weather.rb', 'en')
		@old_url = 'http://weather.noaa.gov/weather/current/PHTO.html'
		@new_url = 'http://www.aviationweather.gov/adds/metars/?station_ids=PHTO&std_trans=translated&chk_metars=on&hoursStr=most+recent+only'
		@url_key = 'weather.url'
	end

	def test_update_weather_urL_from_old
		hash = {@url_key =>  @old_url}
		@plugin::update_weather_url( hash )
		assert_equal(@new_url, hash[@url_key])
	end

	def test_update_weather_urL_with_new
		hash = {@url_key =>  @new_url}
		@plugin::update_weather_url( hash )
		assert_equal(@new_url, hash[@url_key])
	end
end

class TestParseHtml < Test::Unit::TestCase
	def setup
		@plugin_class = TDiary::StubPlugin::new_plugin('misc/plugin/weather.rb', language)
		@weather = @plugin_class::Weather.new
	end

	def language
		"en"
	end

	def test_parse_sample
		html = open(File.join(File.dirname(__FILE__), 'weather-ADDS-METARS-RJAA-130131.html')).read.force_encoding('ISO-8859-1')
		@weather.parse_html(html, @plugin_class::Weather_default_items)
		assert_equal(Time.utc(2013, 1, 31, 12, 30, 0), Time.at(@weather.data['timestamp'].to_i))
		assert_equal("-2.0", @weather.data['temperature(C)'])
		assert_equal("-4.0", @weather.data['dewpoint(C)'])
		assert_equal("1034.0", @weather.data['pressure(hPa)'])
		assert_equal("1.0", @weather.data['wind(m/s)'])
		assert_equal("240", @weather.data['wind(deg)'])
		assert_equal("10+", @weather.data['visibility(km)'])
	end

	def test_parse_sample_F
		html = open(File.join(File.dirname(__FILE__), 'weather-ADDS-METARS-RJAA-130131.html')).read.force_encoding('ISO-8859-1')
		@weather.parse_html(html, {'temperature(F)' => 'temperature(F)'})
		assert_equal("28", @weather.data['temperature(F)'])
	end

	def test_parse_sample_mile
		html = open(File.join(File.dirname(__FILE__), 'weather-ADDS-METARS-RJAA-130131.html')).read.force_encoding('ISO-8859-1')
		@weather.parse_html(html, {'visibility(mile)' => 'visibility(mile)'})
		assert_equal("6 or more", @weather.data['visibility(mile)'])
	end

	def test_parse_sample_no_significant_weather
		html = open(File.join(File.dirname(__FILE__), 'weather-ADDS-METARS-RJAA-130131.html')).read.force_encoding('ISO-8859-1')
		@weather.parse_html(html, {'weather' => 'weather'})
		assert_equal("Few clouds", @weather.data['weather'])
	end

	def test_parse_sample_FG_RA
		html = open(File.join(File.dirname(__FILE__), 'weather-ADDS-METARS-RJAA-130227.html')).read.force_encoding('ISO-8859-1')
		@weather.parse_html(html, {'weather' => 'weather'})
		assert_equal("Fog/Light rain", @weather.data['weather'])
	end

	def test_parse_sample_with_160
		html = open(File.join(File.dirname(__FILE__), 'weather-ADDS-METARS-PHTO-140131.html')).read.force_encoding('ISO-8859-1')
		@weather.parse_html(html, @plugin_class::Weather_default_items)
		assert_equal(Time.utc(2014, 1, 31, 14, 53, 0), Time.at(@weather.data['timestamp'].to_i))
		assert_equal("18.3", @weather.data['temperature(C)'])
		assert_equal("16.7", @weather.data['dewpoint(C)'])
		assert_equal("1012.3", @weather.data['pressure(hPa)'])
		assert_equal("16+", @weather.data['visibility(km)'])
	end
end

class TestStationRegexp < Test::Unit::TestCase
	def setup
		@plugin_class = TDiary::StubPlugin::new_plugin('misc/plugin/weather.rb', 'en')
	end

	def test_extract_aviationweather_station_id
		url = 'http://www.aviationweather.gov/adds/metars/?station_ids=PHTO&std_trans=translated&chk_metars=on&hoursStr=most+recent+only'
		target = 'PHTO'
		result = @plugin_class::Weather::extract_station_id(url)
		assert_equal(target, result)
	end

	def test_extract_noaa_station_id
		url = 'http://weather.noaa.gov/weather/current/RJTI.html'
		target = 'RJTI'
		result = @plugin_class::Weather::extract_station_id(url)
		assert_equal(target, result)
	end

	def test_extract_raw_station_id
		url = 'RJTI'
		target = 'RJTI'
		result = @plugin_class::Weather::extract_station_id(url)
		assert_equal(target, result)
	end

	def test_no_station_id
		assert_nil(@plugin_class::Weather::extract_station_id('http://www.tdiary.org/'))
	end
end

class TestWeatherTranslaterJa < Test::Unit::TestCase
	def setup
		@plugin_class = TDiary::StubPlugin::new_plugin('misc/plugin/weather.rb', 'ja')
	end

	def test_translate_few_clouds
		ja = @plugin_class::WeatherTranslator::S.new('Few clouds').\
			translate(@plugin_class::Weather::Words_ja)
		assert_equal('曇', ja)
	end

	def test_translate_broken_clouds
		ja = @plugin_class::WeatherTranslator::S.new('broken clouds').\
			translate(@plugin_class::Weather::Words_ja)
		assert_equal('曇', ja)
	end

	def test_translate_overcast_clouod_deck
		ja = @plugin_class::WeatherTranslator::S.new('overcast cloud deck').\
			translate(@plugin_class::Weather::Words_ja)
		assert_equal('曇', ja)
	end

	def test_translate_overcast
		ja = @plugin_class::WeatherTranslator::S.new('overcast').\
			translate(@plugin_class::Weather::Words_ja)
		assert_equal('曇', ja)
	end
end

# Stub for @conf
class WeatherStubConf
	def to_native(str); str; end
	def [](*args); nil; end
end

class FetchTest < Test::Unit::TestCase
	def skip_fetch_from_aviationweather_gov
		plugin_class = TDiary::StubPlugin::new_plugin('misc/plugin/weather.rb', 'en')
		url = plugin_class::Weather::STATION_URL_TEMPLATE % 'PHTO'

		weather = plugin_class::Weather.new(Time.now, nil, WeatherStubConf.new)
		weather.get(url, {}, plugin_class::Weather_default_items)
		assert_not_nil(weather.data['temperature(C)'])
	end
end

