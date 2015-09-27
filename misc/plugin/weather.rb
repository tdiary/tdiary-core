# -*- coding: utf-8 -*-
=begin
= その日の天気プラグイン / Weather-of-today plugin((-$Id: weather.rb,v 1.16 2008-03-02 09:01:45 kazuhiko Exp $-))
Records the weather when the diary is first updated for the date and
displays it.

その日の天気を、その日の日記を最初に更新する時に取得して保存し、それぞれ
の日の日記の上部に表示します。

== Acknowledgements
その日の天気プラグインのアイディアを提供してくださったhsbtさん、実装のヒ
ントを提供してくださったzoeさんに感謝します。また、NOAAの情報を提供して
くださったkotakさんに感謝します。

The author appreciates National Weather Service
((<URL:http://weather.noaa.gov/>)) making such valuable data available
in public domain as described in ((<URL:http://www.noaa.gov/wx.html>)).

== Copyright
Copyright 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution,
and distribution of modified versions of this work under the terms
of GPL version 2 or later.
=end

=begin ChangeLog
* Mon Jan 14, 2008 SHIBATA Hiroshi <h-sbt@nifty.com>
- Hide output string in RSS feed.
* Mon Sep 29, 2003 zunda <zunda at freeshell.org>
- Japanese resources divided into  a separate file, English resource
  created
* Thu Jul 24, 2003 zunda <zunda at freeshell.org>
- Syntax error in drizzle fixed
* Mon Jul 21, 2003 zunda <zunda at freeshell.org>
- changed regexp literals from %r|..| to %r[..] for Ruby 1.8.x.
* Fri Jul 17, 2003 zunda <zunda at freeshell.org>
- WWW configuration interface
* Thu Jun  5, 2003 zunda <zunda at freeshell.org>
- checks the age of data
* Tue Jun  3, 2003 zunda <zunda at freeshell.org>
- ignores `... in the vicinity', thank you kosaka-san.
- now tests translations if executed as a stand alone script.
* Mon May 26, 2003 zunda <zunda at freeshell.org>
- fix typo on weaHTer.show_mobile and weHTer.show_error, thank you halchan.
* Thu May  8, 2003 zunda <zunda at freeshell.org>
- A with B, observed,
* Mon May  5, 2003 zunda <zunda at freeshell.org>
- mobile agent
* Fri Mar 28, 2003 zunda <zunda at freeshell.org>
- overcast, Thanks kotak san.
* Fri Mar 21, 2003 zunda <zunda at freeshell.org>
- mist: kiri -> kasumi, Thanks kotak san.
* Sun Mar 16, 2003 zunda <zunda at freeshell.org>
- option weather.tz, appropriate handling of timezone
* Tue Mar 11, 2003 zunda <zunda at freeshell.org>
- records: windchill, winddir with 'direction variable', gusting wind
* Mon Mar 10, 2003 zunda <zunda at freeshell.org>
- WeatherTranslator module
* Sat Mar  8, 2003 zunda <zunda at freeshell.org>
- values with units
* Fri Mar  7, 2003 zunda <zunda at freeshell.org>
- edited to work with NOAA/NWS
* Fri Feb 28, 2003 zunda <zunda at freeshell.org>
- first draft
=end

require 'net/http'
require 'cgi'
require 'timeout'
require 'date'	# DateTime.strptime

=begin
== Classes and methods
=== WeatherParser

--- WeatherParser::parse
=end


=begin
=== WeatherTranslator module
We want Japanese displayed in a diary written in Japanese.

--- WeatherTranslator::S < String
    Extension of String class. It translates itself.

--- WeatherTranslator::S.translate( table )
    Translates self according to ((|table|)).
=end

module WeatherTranslator
	class S < String
		def translate( table )
			return '' if not self or self.empty?
			table.each do |x|
				if x[0] =~ self then
					return S.new( S.new( $` ).translate( table ) + eval( x[1] ) + S.new( $' ).translate( table ) )
				end
			end
			self
		end
		def compact
			S.new( self.split( /\/+/ ).uniq.join( '/' ) )
		end
	end
end

=begin
=== Weather class
Weather of a date.

--- Weather( date )
      A Weather is a weather datum for a ((|date|)) (a Time object).

--- Weather.get( url, header, items )
      Gets a WWW page from the ((|url|)) providing HTTP header in the
      ((|header|)) hash. The page is parsed calling Weahter.parse_html.
      Returns self.

--- Weather.parse_html( html, items )
      Parses an HTML page ((|html|)) and stores the data into @data
      according to ((|items|)).

--- Weather.to_s
      Creates a line to be stored into the cache file which will be
      parsed with Weather.parse method. Data are stored with the
      following sequence and separated with a tab:
        date(string), url, acquisition time(UNIX time) timezone, error (or empty string), item, value, ...
      Each record is terminated with a new line.

--- Weather.parse( string )
--- Weather::parse( string )
      Parses the ((|string|)) made by Weather.to_s and returns the
      resulting Weather.

--- Weather::date_to_s( date )
      Returns ((|date|)) formatted as a String used in to_s method. Used
      to find a record for the date from a file.

--- Weather.to_html( show_error = false )
      Returns an HTML fragment for the weather. When show_error is true,
      returns an error message as an HTML fragment in case an error
      occured when getting the weather.

--- Weather.to_i_html
      Returns a CHTML fragment for the weather.
=end
class Weather
	attr_reader :date, :time, :url, :error, :data, :tz

	# magic numbers
	WAITTIME = 10
	MAXREDIRECT = 10
	AVIATIONWEATHER_STATION_REGEXP = %r|(?:aviationweather.gov/adds/metars/\?.*station_ids=)([A-Z]{4,4})\b|
	NOAA_STATION_REGEXP = %r|(?:weather.noaa.gov/weather/current/)([A-Z]{4,4})\b|
	RAW_STATION_REGEXP = %r|\A([A-Z]{4,4})\z|
	STATION_URL_TEMPLATE = "http://www.aviationweather.gov/adds/metars/?station_ids=%s&std_trans=translated&chk_metars=on&hoursStr=most+recent+only"

	def Weather::extract_station_id(url)
			[AVIATIONWEATHER_STATION_REGEXP, NOAA_STATION_REGEXP, RAW_STATION_REGEXP].each do |r|
				m = r.match(url)
				return m[1] if m and m[1]
			end
			return nil
	end

	# edit this method according to the HTML we will get
	def parse_html( html, items )
		htmlitems = Hash.new

		# weather data is in the 1st table in the HTML from aviationweather.gov
		table = html.scan( %r[<table.*?>(.*?)</table>]mi )
		return if not table or not table[0] or not table[0][0]
		table[0][0].scan( %r[<tr.*?>(.*?)</tr>]mi ).collect {|a| a[0]}.each do |row|
			# <tr><td> *item* -> downcased </td><td> *value* </td></tr>
			if %r[<td.*?>(.*?)</td>\s*<td.*?>(.*?)</td>]mi =~ row then
				item = $1
				value = $2
				item = item.gsub( /<br>/i, '/' ).gsub( /<.*?>/m , '').strip.sub(/:$/, '').downcase
				value = value.gsub(/\&(nbsp|#160);/, ' ').gsub(/\&#46;/, '.').gsub(/\&#37/, '%').gsub(/\&deg;/, '').gsub( /<br>/i, '/' ).gsub( /<.*?>/m , '').strip

				# unit conversion settings
				units = []
				case item
				when 'conditions at'
					# we have to convert the UTC time into UNIX time
					if /observed\s+(.*)$/ =~ value then
						value = DateTime.strptime($1, "%H%M %z %d %B %Y").to_time.to_i.to_s
					else
						raise StandardError, 'Parse error in "Conditions at"'
					end
				when 'visibility' # we want to preserve adjective phrase if possible
					if /(.+)miles?/i =~ value then
						htmlitems["#{item}(mile)"] = $1.strip
					end
					if /([^\(]+)km/i =~ value then
						htmlitems["#{item}(km)"] = $1.strip
					end
				when 'winds' # we want to preserve adjective phrase if possible
					%w(MPH knots m/s).each do |unit|
						speed = value.scan( /([\d.]+)\s*#{unit}/i ).collect { |x| x[0] }
						htmlitems["wind(#{unit})"] = speed.join(',')
					end
					if /([\d.]+)\s*degrees?/i =~ value then
						htmlitems["wind(deg)"] = $1
					end
					if /from\s+(the\s+)?(\w+)/i =~ value then
						htmlitems["winddir"] = $2 + ($3 ? " #{$3}" : '')
					end
					if /(\(direction variable\))/i =~ value then
						htmlitems["#{item}dir"] << " #{$1}"
					end
				# just have to parse the value with the units
				when 'temperature'
					units = ['C', 'F']
				when 'windchill'
					units = ['C', 'F']
				when 'dewpoint'
					units = ['C', 'F']
				when 'relative humidity'
					units = ['%']
				when 'pressure (altimeter)'
					units = ['mb']	# mb (mbar) and hPa results in same number
				end

				# parse the value with the units if preferred and possible
				units.each do |unit|
					if /(-?[\d.]+)\s*\D?\(?#{unit}\b/i =~ value then
						number = $1
						htmlitems["#{item}(#{unit})"] = number
					end
				end

				# record the value as read from the HTML
				htmlitems[item] = value

			end	# if %r[<td.*?>(.*?)</td>\s*<td.*?>(.*?)</td>]mi =~ row
		end	# table.scan( %r[<tr.*?>(.*?)</tr>]mi ) ... do |row|

		# Obtain weather from Weather: or Clouds:
		weather = 'Unknown'
		# e.g.: FG -RA  (fog, light rain)
		if /\((.*)\)/ =~ htmlitems['weather'] then
			weather = $1.strip
		# e.g.: few clouds at 3000 feet AGL
		elsif /(.*?)\s+at/ =~ htmlitems['clouds'] then
			weather = $1.strip
		end
		# Weather seemed to have been slash divided capitalized string
		htmlitems['weather'] = weather.split(/,\s*/).map{|e| e.strip.capitalize}.join('/')

		# translate the parsed HTML into the Weather hash with more generic key
		items.each do |from, to|
			if htmlitems[from] then
				# as specified in items
				@data[to] = htmlitems[from]
			elsif f = from.dup.sub!( /\([^)]+\)$/, '' ) \
					and htmlitems[f] \
					and t = to.dup.sub!( /\([^)]+\)$/, '' ) then
				# remove the units and try again if not found
				@data[t] = htmlitems[f]
			end
		end
		@time = Time::now
	end

	# check age of data
	def check_age( oldest_sec = nil )
		if oldest_sec and @time and @data['timestamp'] and @data['timestamp'].to_i + oldest_sec < @time.to_i then
			@error = 'data too old'
		end
	end

	def initialize( date = nil, tz = nil, conf = nil )
		@conf = conf
		@date = date or Time.now
		@data = Hash.new
		@error = nil
		@url = nil
		if tz and not tz.empty? then
			@tz = tz
		elsif ENV['TZ']
			@tz = ENV['TZ']
		else
			@tz = nil
		end
	end

	def fetch( url, limit, header )
		raise ArgumentError, 'HTTP redirect too deep' if limit == 0

		px_host, px_port = (@conf['proxy'] || '').split( /:/ )
		px_port = 80 if px_host and !px_port
		u = URI::parse( url )
		Net::HTTP::Proxy( px_host, px_port ).start( u.host, u.port ) do |http|
			case res = http.get( u.request_uri, header )
			when Net::HTTPSuccess
				res.body
			when Net::HTTPRedirection
				fetch( res['location'].untaint, limit - 1 )
			else
				raise ArgumentError, res.error!
			end
		end
	end

	def get( url, header = {}, items = {} )
		@url = url.gsub(/[\t\n]/, '')
		@error = nil

		begin
			Timeout::timeout( WAITTIME ) do
				d = @conf.to_native( fetch( url, MAXREDIRECT, header ) )
				parse_html( d, items )
			end
		rescue Timeout::Error
			@error = 'Timeout'
		rescue
			@error = @conf.to_native( $!.message.gsub( /[\t\n]/, ' ' ) )
		end
		self
	end

	def to_s
		tzstr = @tz ? " #{tz}" : ''
		r = "#{Weather::date_to_s( @date )}\t#{@url}\t#{@time.to_i}#{tzstr}\t#{@error}"
		@data.each do |item, value|
			r << "\t#{item}\t#{value}" if value and not value.empty?
		end
		r << "\n"
	end

	def parse( string )
		i = string.chomp.split( /\t/ )
		y, m, d = i.shift.scan( /^(\d{4})(\d\d)(\d\d)$/ )[0]
		@date = Time::local( y, m, d )
		@url = i.shift
		itime, @tz = i.shift.split( / +/, 2 )
		@time = Time::at( itime.to_i )
		error = i.shift
		if error and not error.empty? then
			@error = error
		else
			@error = nil
		end
		@data.clear
		while not i.empty? do
			@data[i.shift] = i.shift
		end
		self
	end

	def to_html( show_error = false )
		@error ? (show_error ? error_html_string : '') : html_string
	end

	def to_i_html
		@error ? '' : i_html_string
	end

	def store( path, date )
		ddir = File.dirname( Weather::file_path( path, date ) )
		# mkdir_p logic copied from fileutils.rb
		# Copyright (c) 2000,2001 Minero Aoki <aamine@loveruby.net>
		# and edited (zunda.freeshell.org does not have fileutils.rb T_T
		dirstack = []
		until FileTest.directory?( ddir ) do
			dirstack.push( ddir )
			ddir = File.dirname( ddir )
		end
		dirstack.reverse_each do |dir|
			Dir.mkdir dir
		end
		# finally we can write a file
		File::open( Weather::file_path( path, date ), 'a' ) do |fh|
			fh.puts( to_s )
		end
	end

	class << self
		def parse( string )
			new.parse( string )
		end

		def date_to_s( date )
			date.strftime( '%Y%m%d' )
		end

		def file_path( path, date )
			date.strftime( "#{path}/%Y/%Y%m.weather" ).gsub( /\/\/+/, '/' )
		end

		def restore( path, date )
			r = nil
			datestring = Weather::date_to_s( date )
			begin
				File::open( file_path( path, date ), 'r' ) do |fh|
					fh.each( "\n" ) do |l|
						if /^#{datestring}\t/ =~ l then
							r = l # will use the last/newest data found in the file
						end
					end
				end
			rescue Errno::ENOENT
			end
			r ? Weather::parse( r ) : nil
		end

	end
end

=begin
=== Methods as a plugin
weather method also can be used as a usual plug-in in your diary body.
Please note that the argument is not a String but a Time object.

--- weather( date = nil )
      Returns an HTML flagment of the weather for the date. This will be
      provoked as a body_enter_proc. @date is used when ((|date|)) is
      nil.

--- get_weather
      Access the URL to get the current weather information when:
      * @mode is append or replace,
      * @date is today, and
      * There is no cached data without an error for today
      This will be provoked as an update_proc.
=end

Weather_default_path = "#{@cache_path}/weather"
Weather_default_items = {
	# UNIX time
	'conditions at'             => 'timestamp',
	# English phrases
	'sky conditions'            => 'condition',
	'weather'                   => 'weather',
	# Direction (e.g. SE)
	'winddir'                   => 'winddir',
	# English phrases when unit conversion failed, otherwise, key with (unit)
	'wind(m/s)'                 => 'wind(m/s)',
	'wind(deg)'                 => 'wind(deg)',
	'visibility(km)'            => 'visibility(km)',
	'temperature(C)'            => 'temperature(C)',
	'windchill(C)'              => 'windchill(C)',
	'dewpoint(C)'               => 'dewpoint(C)',
	'relative humidity(%)'      => 'humidity(%)',
	'pressure (altimeter)(mb)'  => 'pressure(hPa)',
}

# shows weather
def weather( date = nil, wrap = true )
	return '' if bot? and not @options['weather.show_robot']
	path = @options['weather.dir'] || Weather_default_path
	w = Weather::restore( path, date || @date )
	if w then
		%Q|#{wrap ? '<div class="weather">' : ' '}#{w.to_html( @options['weather.show_error'] )}#{wrap ? "</div>\n" : ''}|
	else
		''
	end
end

# gets weather when the diary is updated
def get_weather
	return unless @options['weather.url']
	return unless @mode == 'append' or @mode == 'replace'
	return unless @date.strftime( '%Y%m%d' ) == Time::now.strftime( '%Y%m%d' )
	path = @options['weather.dir'] || Weather_default_path
	w = Weather::restore( path, @date )
	if not w or w.error then
		items = @options['weather.items'] || Weather_default_items
		update_weather_url( @options )
		w = Weather.new( @date, @options['weather.tz'], @conf )
		w.get( @options['weather.url'], @options['weather.header'] || {}, items )
		if @options.has_key?( 'weather.oldest' ) then
			oldest = @options['weather.oldest']
		else
			oldest = 21600
		end
		w.check_age( oldest )
		w.store( path, @date )
	end
end

# Update URL of weather information
#
# Around April, 2012, NOAA chnaged the URL of the current weather from
# http://weather.noaa.gov/weather/current/#{station_id}.html
# to
# http://www.aviationweather.gov/adds/metars/?station_ids=#{station_id}&std_trans=translated&chk_metars=on&hoursStr=most+recent+only
def update_weather_url( hash )
	if hash['weather.url'] and match = hash['weather.url'].scan(%r[\Ahttp://weather.noaa.gov/weather/current/(\w{4,4}).html\z])[0]
		hash['weather.url'] = Weather::STATION_URL_TEMPLATE % match[0]
	end
end

# www configuration interface
def configure_weather
	if( @mode == 'saveconf' ) then
		# weather.url
		station = Weather::extract_station_id( @cgi.params['weather.url'][0] )
		if station
			@conf['weather.url'] = Weather::STATION_URL_TEMPLATE % station
		else
			@conf['weather.url'] = @cgi.params['weather.url'][0]
		end
		# weather.tz
		tz = @cgi.params['weather.tz'][0]
		unless tz.empty? then	# need more checks
			@conf['weather.tz'] = tz
		else
			@conf['weather.tz'] = ''
		end
		%w(in_title show_mobile show_robot).each do |item|
			case @cgi.params["weather.#{item}"][0]
			when 'true'
				@conf["weather.#{item}"] = true
			when 'false'
				@conf["weather.#{item}"] = false
			end
		end
	end
	update_weather_url( @conf )
	weather_configure_html( @conf )
end

add_header_proc do
	<<"_END"
\t<style type="text/css" media="all"><!--
\t\th2 span.weather{font-size: small;}
\t\tdiv.weather{text-align: right; font-size: 75%;}
\t--></style>
_END
end

if not feed? and not @options['weather.in_title'] then
	add_body_enter_proc do |date|
		weather( date )
	end
end

if not feed? and @options['weather.in_title'] then
	add_title_proc do |date, title|
		title + weather( date, false )
	end
end

add_update_proc do get_weather end
add_conf_proc( 'weather', @weather_plugin_name ) do configure_weather end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
