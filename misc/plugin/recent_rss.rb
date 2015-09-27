# -*- indent-tabs-mode: t -*-
# recent_rss.rb: RSS recent plugin
#
# options:
#   @options['recent_rss.use-image-link'] : use image as link
#                                           instead of text if available.
#
# recent_rss: show recnet list from RSS
#   parameters (default):
#      url: URL of RSS
#      max: max of list itmes(5)
#      cache_time: cache time(second) of RSS(60*60)
#      show_modified: show modified time of the entry (true)
#
# Copyright (c) 2003-2005 Kouhei Sutou <kou@cozmixng.org>
# Distributed under the GPL2 or any later version.
#

require "rss/rss"
require "fileutils"

RECENT_RSS_FIELD_SEPARATOR = "\0"
RECENT_RSS_ENTRY_SEPARATOR = "\1"
RECENT_RSS_VERSION = "0.0.6"
RECENT_RSS_HTTP_HEADER = {
	"User-Agent" => "tDiary RSS recent plugin version #{RECENT_RSS_VERSION}. " <<
		"Using RSS parser version is #{::RSS::VERSION}.",
}

def recent_rss( url, max = 5, cache_time = 3600, show_modified = true )
	return 'DO NOT USE IN SECURE MODE' if @conf.secure

	url.untaint

	cache_file = "#{@cache_path}/recent_rss.#{CGI.escape(url)}"

	recent_rss_cache_rss(url, cache_file, cache_time.to_i)

	return '' unless test(?r, cache_file)

	rv = %Q|<div class="recent-rss">\n|

	site_info, *infos = recent_rss_read_from_cache(cache_file)

	if site_info
		title, url, time, image = site_info
		content = recent_rss_entry_to_html( title, url, time, image, show_modified )
		rv << %Q|<div class="recent-rss-title">\n|
		rv << %Q|<span class="#{recent_rss_modified_class(time)}">#{content}</span>\n|
		rv << "</div>\n"
	end

	have_entry = infos.size > 0 && max > 0

	rv << %Q|<ol class="recent-rss">\n| if have_entry
	i = 0
	infos.each do |title, url, time, image|
		break if i >= max
		next if title.nil?
		rv << '<li>'
		rv << %Q[<span class="#{recent_rss_modified_class(time)}">]
		rv << recent_rss_entry_to_html( title, url, time, image, show_modified )
		rv << %Q[</span>]
		rv << "</li>\n"
		i += 1
	end

	rv << "</ol>\n" if have_entry

	rv << "</div>\n"

	rv
end

class InvalidResourceError < StandardError; end
class RSSNotModified < StandardError; end

require 'time'
require 'timeout'
require 'net/http'
require 'uri/generic'
require 'rss/parser'
require 'rss/1.0'
require 'rss/2.0'
require 'rss/dublincore'
begin
	require 'rss/image'
rescue LoadError
end

def recent_rss_cache_rss(url, cache_file, cache_time)

	cached_time = nil
	cached_time = File.mtime(cache_file) if File.exist?(cache_file)

	if cached_time.nil? or Time.now > cached_time + cache_time

		begin
			uri = URI.parse(url)

			raise URI::InvalidURIError unless uri.is_a?(URI::HTTP)

			rss_source = recent_rss_fetch_rss(uri, cached_time)

			raise InvalidResourceError if rss_source.nil?

			# parse RSS
			rss = ::RSS::Parser.parse(rss_source.untaint, false)
			raise ::RSS::Error if rss.nil?

			# pre processing
			begin
				rss.output_encoding = @conf.charset || charset
			rescue ::RSS::UnknownConversionMethodError
			end

			rss_infos = []
			rss.items.each do |item|
				recent_rss_pubDate_to_dc_date(item)
				if item.respond_to?(:image_item) and item.image_item
					image = item.image_item.about
				else
					image = nil
				end
				rss_infos << [item.title, item.link, item.dc_date, image]
			end
			recent_rss_pubDate_to_dc_date(rss.channel)
			rss_infos.unshift([
				rss.channel.title,
				rss.channel.link,
				rss.channel.dc_date ||
					rss.items.collect{|item| item.dc_date}.compact.first,
				rss.image && rss.image.url,
			])
			recent_rss_write_to_cache(cache_file, rss_infos)

		rescue RSSNotModified
			FileUtils.touch(cache_file)
		rescue URI::InvalidURIError
			recent_rss_write_to_cache(cache_file, [['Invalid URI', url]])
		rescue InvalidResourceError, ::RSS::Error
			recent_rss_write_to_cache(cache_file, [['Invalid Resource', url]])
		end
	end

end

def recent_rss_fetch_rss(uri, cache_time)
	rss = nil

	px_host, px_port = (@conf['proxy'] || '').split( /:/ )
	px_port = 80 if px_host and !px_port
	begin
		Timeout::timeout( 10 ) do
			res = Net::HTTP::Proxy( px_host, px_port ).get_response( uri )
			case res
			when Net::HTTPSuccess
				rss = res.body
			when Net::HTTPRedirection
				raise InvalidResourceError
			when Net::HTTPNotModified
				# not modified
				raise RSSNotModified
			else
				raise InvalidResourceError
			end
		end
	rescue Timeout::Error, SocketError, StandardError
		raise InvalidResourceError
	end
	rss
end

def recent_rss_http_header(cache_time)
	header = RECENT_RSS_HTTP_HEADER.dup
	if cache_time.respond_to?(:rfc2822)
		header["If-Modified-Since"] = cache_time.rfc2822
	end
	header
end

def recent_rss_write_to_cache(cache_file, rss_infos)
	File.open(cache_file, 'w') do |f|
		f.flock(File::LOCK_EX)
		rss_infos.each do |info|
			f << info.join(RECENT_RSS_FIELD_SEPARATOR)
			f << RECENT_RSS_ENTRY_SEPARATOR
		end
		f.flock(File::LOCK_UN)
	end
end

def recent_rss_read_from_cache(cache_file)
	infos = []
	File.open(cache_file) do |f|
		while info = f.gets(RECENT_RSS_ENTRY_SEPARATOR)
			info = info.chomp(RECENT_RSS_ENTRY_SEPARATOR)
			infos << info.split(RECENT_RSS_FIELD_SEPARATOR)
		end
	end
	infos.collect do |title, url, time, image|
		[
			recent_rss_convert(title),
			recent_rss_convert(url),
			recent_rss_convert(time) {|t| Time.parse(t)},
			recent_rss_convert(image),
		]
	end
end

def recent_rss_convert(str)
	if str.nil? or str.empty?
		nil
	else
		if block_given?
			yield str
		else
			str
		end
	end
end

def recent_rss_entry_to_html(title, url, time, image = nil, show_modified = true )
	rv = ""
	unless url.nil?
		rv << %Q[<a href="#{h( url )}" title="#{h( title )}]
		rv << %Q[ (#{h( time.localtime )})] unless time.nil?
		rv << %Q[">]
	end
	if image and @options['recent_rss.use-image-link']
		rv << %Q[<img src="#{h( image )}"]
		rv << %Q[ title="#{h( title )}"]
		rv << %Q[ alt="site image"]
		rv << %Q[>\n]
	else
		rv << h( title )
	end
	rv << '</a>' unless url.nil?
	rv << "(#{recent_rss_modified(time)})" if show_modified
	rv
end

# from RWiki
def recent_rss_modified(t)
	return '-' unless t
	dif = (Time.now - t).to_i
	dif = dif / 60
	return "#{dif}m" if dif <= 60
	dif = dif / 60
	return "#{dif}h" if dif <= 24
	dif = dif / 24
	return "#{dif}d"
end

# from RWiki
def recent_rss_modified_class(t)
	return 'dangling' unless t
	dif = (Time.now - t).to_i
	dif = dif / 60
	return "modified-hour" if dif <= 60
	dif = dif / 60
	return "modified-today" if dif <= 24
	dif = dif / 24
	return "modified-month" if dif <= 30
	return "modified-year" if dif <= 365
	return "modified-old"
end

def recent_rss_pubDate_to_dc_date(target)
	if target.respond_to?(:pubDate)
		class << target
			alias_method(:dc_date, :pubDate)
		end
	end
end

add_conf_proc('recent_rss', label_recent_rss_title) do
	item = 'recent_rss.use-image-link'
	if @mode == 'saveconf'
		@conf[item] = (@cgi.params[item][0] == 't')
	end

	<<-HTML
	<div class"body">
		<h3 class="subtitle">#{label_recent_rss_use_image_link_title}</h3>
		<p>#{label_recent_rss_use_image_link_description}</p>
		<p>
			<select name=#{item}>
				<option value="f"#{@conf[item] ? '' : ' selected'}>
					#{label_recent_rss_not_use_image_link}
				</option>
				<option value="t"#{@conf[item] ? ' selected' : ''}>
					#{label_recent_rss_use_image_link}
				</option>
			</select>
		</p>
	</div>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
