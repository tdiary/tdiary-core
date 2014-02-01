=begin
= Weather-of-today plugin((-$Id: weather.rb,v 1.10 2008-03-02 09:01:46 kazuhiko Exp $-))
Records the weather when the diary is first updated for the date and
displays it.

== Acknowledgements
The idea of this plugin is due to `hsbt'. The author took the hint for
the implmentation from `zoe'. `kotak' kindly provided the information
about NOAA. The author thanks to them.

The author also appreciates National Weather Service
((<URL:http://weather.noaa.gov/>)) making such valuable data available
in public domain as described in ((<URL:http://www.noaa.gov/wx.html>)).

== Copyright
Copyright 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution,
and distribution of modified versions of this work under the terms
of GPL version 2 or later.
=end

=begin
== Instance variables
=end
@weather_plugin_name = 'Weather-of-today'

=begin
== Classes and methods
=== WeatherTranslator module
We want Japanese displayed in a diary written in Japanese.

--- Weather::Words_en
    Array of arrays of a Regexp and a Statement to be executed.
    WeatherTranslator::S.tr accepts this kind of hash to translate a
    given string. No translations are defined for English. Please see an
		example in the Japanese resource.
=end
require 'erb'

class Weather
	Words_en = []
end

=begin
=== Weather class
Weather of a date.
--- Weather.html_string
--- Weather.error_html_string
      Returns an HTML fragment showing data or error, called from
      Weather.to_html.

--- Weather.i_html_string
      Returns a CHTML fragment to be shown on a mobile browser.
=end
class Weather
	include ERB::Util

	def error_html_string
		%Q|<span class="weather">Weather error:<a href="#{h(@url)}">#{h( @error )}</a></span>|
	end

	# edit this method to define how you show the weather
	def html_string
		has_data = false
		r = '<span class="weather">'

		# weather
		r << %Q|<a href="#{h(@url)}">|
		has_condition = false
		if @data['weather'] then
			r << %Q|<span class="weather">#{h( WeatherTranslator::S.new( @data['weather']).translate( Words_en ).compact.capitalize )}</span>|
			has_condition = true
			has_data = true
		elsif @data['condition'] then
			r << %Q|<span class="condition">#{h( WeatherTranslator::S.new( @data['condition']).translate( Words_en ).compact.capitalize )}</span>|
			has_condition = true
			has_data = true
		end

		# temperature
		if @data['temperature(C)'] and t = @data['temperature(C)'].scan(/-?[\d.]+/)[-1] then
			r << ', ' if has_condition
			r << %Q| <span class="temperature">#{sprintf( '%.0f', 9.0/5.0 * t.to_f + 32.0 )} deg-F</span>|
			has_data = true
		end
		r << '</a>'

		# time stamp
		if @tz then
			tzbak = ENV['TZ']
			ENV['TZ'] = @tz	# this is not thread safe...
		end
		r << ' at '
		if @data['timestamp'] then
			r << Time::at( @data['timestamp'].to_i ).strftime( '%H:%M' ).sub( /^0/, '' )
		else
			r << Time::at( @time.to_i ).strftime( '%H:%M' ).sub( /^0/, '' )
		end
		if @tz then
			ENV['TZ'] = tzbak
		end

		r << "</span>"
		return has_data ? r : ''
	end

	# edit this method to define how you show the weather for a mobile agent
	def i_html_string
		r = ''

		# weather
		if @data['weather'] then
			r << %Q|<A HREF="#{u(@url)}">|
			r << h( WeatherTranslator::S.new( @data['weather']).translate( Words_en ).compact.capitalize )
			r << "</A>"
		elsif @data['condition'] then
			r << %Q|<A HREF="#{u(@url)}">|
			r << h( WeatherTranslator::S.new( @data['condition']).translate( Words_en ).compact.capitalize )
			r << "</A>"
		end

		return r
	end
end

# www configuration interface
def weather_configure_html( conf )
	station = Weather::extract_station_id(conf['weather.url'])
	station ||= conf['weather.url']
	<<-HTML
	<h3 class="subtitle">Weather-of-today plugin</h3>
	<p>Records the weather when the diary is first updated for the date
	and displays it.</p>
	<h4>Data source</h4>
	<p>When you want to use e.g. NOAA National Weather Service,
		select your country from &quot;Select a country...&quot; in
		<a href="http://weather.noaa.gov/">NOAA National Weather Service</a>
		and push the &quot;Go!&quot; button.
		Then select the observation point.
		Write down the URL of the page shown in the box below.
		The four letter station ID can also be used here.</p>
	<p><input name="weather.url" value="#{station}" size="60"></p>
	<p>It would be better to record your time zone in the data if you are
		likely to move to another time zone in the future.
		Thus, the weather data will be  shown in the local time where the
		diary is originally written.</p>
	<p>To record timezone, add the following line into the tdiary.conf
		file in the directory tdiary.rb is: e.g. ENV['TZ'] = 'US/Pacific',
		or write it down the box below.</p>
	<p><input name="weather.tz" value="#{conf['weather.tz']}"></p>
	<h4>Display on a normal browser</h4>
	<p>Select from below:</p>
	<p><select name="weather.in_title">
		<option value="false"#{' selected'unless conf['weather.in_title']}>
		Show weather above text
		<option value="true"#{' selected'if conf['weather.in_title']}>
		Show weather at right of title
	</select></p>
	<h4>Display on a mobile browser</h4>
	<p>Select from below:</p>
	<p><select name="weather.show_mobile">
		<option value="true"#{' selected'if conf['weather.show_mobile']}>
		Show the weather on a mobile browser.
		<option value="false"#{' selected'unless conf['weather.show_mobile']}>
		Do not show the weather on a mobile browser.
	</select></p>
	<h4>Display to search engine robots</h4>
	<p>Select from below:</p>
	<p><select name="weather.show_robot">
		<option value="true"#{' selected'if conf['weather.show_robot']}>
		Let robots know the weather.
		<option value="false"#{' selected'unless conf['weather.show_robot']}>
		Hide the weather from robots.
	</select></p>
	<h4>Other configurations</h4>
	<p>Other options can be configured by means of the tdiary.conf file.
		Please have a look in the plugin file: weather.rb if you want.</p>
	HTML
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
