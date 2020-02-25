# amazon.rb: Making link with image to Amazon using Amazon ECS.
#
# see document: #{@lang}/amazon.rb
#
# Copyright (C) 2005-2019 TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2 or any later version.
#
require 'aws/pa_api'
require 'timeout'

enable_js( 'amazon.js' )

if @conf['amazon.bitly'] and @conf['bitly.login'] and @conf['bitly.key'] then
	enable_js( 'amazon_bitly.js' )
	add_js_setting( '$tDiary.plugin.bitly' )
	add_js_setting( '$tDiary.plugin.bitly.login', "'#{@conf['bitly.login']}'" )
	add_js_setting( '$tDiary.plugin.bitly.apiKey', "'#{@conf['bitly.key']}'" )
end

class AmazonRedirectError < StandardError; end

def amazon_author(item)
	begin
		author = item["ItemInfo"]["ByLineInfo"]["Contributors"][0]["Name"]
	rescue
		'-'
	end
end

def amazon_title(item)
	item["ItemInfo"]["Title"]["DisplayValue"]
end

def amazon_image(item)
	image = {}
	begin
		size = case @conf['amazon.imgsize']
		when 0; 'Large'
		when 2; 'Small'
		else;   'Medium'
		end
		image[:src] = item["Images"]["Primary"][size]["URL"]
		image[:height] = item["Images"]["Primary"][size]["Height"]
		image[:width] = item["Images"]["Primary"][size]["Width"]
	rescue
		base = @conf['amazon.default_image_base'] || 'https://tdiary.github.io/tdiary-theme/plugin/amazon/'
		case @conf['amazon.imgsize']
		when 0
			image[:src] = "#{base}large.png"
			image[:height] = 500
			image[:width] = 380
		when 2
			image[:src] = "#{base}small.png"
			image[:height] = 75
			image[:width] = 57
		else
			image[:src] = "#{base}medium.png"
			image[:height] = 160
			image[:width] = 122
		end
	end
	image
end

def amazon_url(item)
	item["DetailPageURL"]
end

def amazon_label( item )
	begin
		item["ItemInfo"]["ByLineInfo"]["Manufacturer"]["DisplayValue"]
	rescue
		'-'
	end
end

def amazon_price(item)
	begin
		item["Offers"]["Listings"][0]["Price"]["DisplayAmount"]
	rescue
		'(no price)'
	end
end

def amazon_detail_html(item)
	author = amazon_author(item)
	title = amazon_title(item)

	size_orig = @conf['amazon.imgsize']
	@conf['amazon.imgsize'] = 2
	image = amazon_image(item)
	@conf['amazon.imgsize'] = size_orig

	url = amazon_url(item)
	<<-HTML
	<a class="amazon-detail" href="#{url}"><span class="amazon-detail">
		<img class="amazon-detail left" src="#{h image[:src]}"
		height="#{h image[:height]}" width="#{h image[:width]}"
		alt="">
		<span class="amazon-detail-desc">
			<span class="amazon-title">#{h title}</span><br>
			<span class="amazon-author">#{h author}</span><br>
			<span class="amazon-label">#{h amazon_label(item)}</span><br>
			<span class="amazon-price">#{h amazon_price(item)}</span>
		</span>
	</span></a>
	HTML
end

def amazon_to_html(item, with_image = true, label = nil, pos = 'amazon')
	with_image = false if @mode == 'categoryview'

	author = amazon_author(item)
	author = "(#{author})" unless author.empty?

	label ||= %Q|#{amazon_title(item)}#{author}|
	alt = ''
	if with_image and @conf['amazon.hidename'] || pos != 'amazon' then
		label, alt = alt, label
	end

	if with_image
		image = amazon_image(item)
		unless image[:src] then
			img = ''
		else
			size = %Q|height="#{h image[:height]}" width="#{h image[:width]}"|
			img = <<-HTML
			<img class="#{h pos}" src="#{h image[:src]}"
			#{size} alt="#{h alt}">
			HTML
			img.gsub!( /\t/, '' )
		end
	end

	url = amazon_url(item)
	%Q|<a href="#{h url}">#{img}#{h label}</a>|
end

def amazon_get(asin, with_image = true, label = nil, pos = 'amazon')
	asin = asin.to_s.strip.gsub(/-/, '')
	country, item_id = asin.scan(/\A(..):(.*)/).flatten
	unless country
		country = @conf['amazon.default_country'] || @amazon_default_country
		item_id = asin
	end

	begin
		cache = "#{@cache_path}/amazon"
		Dir::mkdir( cache ) unless File::directory?( cache )
		begin
			json = File::read("#{cache}/#{country}#{item_id}.json")
		rescue Errno::ENOENT
			access_key = @conf['amazon.access_key']
			secret_key = @conf['amazon.secret_key']
			return asin unless access_key && secret_key
			partner_tag = @conf['amazon.aid']
			paapi = AWS::PAAPI.new(access_key, secret_key, partner_tag)
			json = paapi.get_items(item_id, country.to_sym)
			File::open("#{cache}/#{country}#{item_id}.json", 'wb'){|f| f.write(json)}
		end
		item = JSON.parse(json)["ItemsResult"]["Items"][0]
		if pos == 'detail' then
			amazon_detail_html(item)
		else
			amazon_to_html(item, with_image, label, pos)
		end
	rescue Net::HTTPUnauthorized
		@logger.error "amazon.rb: Amazon API Unauthorized."
		message = asin
		if @mode == 'preview' then
			message << %Q|<span class="message">(Amazon API Unauthorized))</span>|
		end
		message
	rescue Timeout::Error
		@logger.error "amazon.rb: PA-API Timeouted."
		message = asin
		if @mode == 'preview' then
			message << %Q|<span class="message">(PA-API Timeouted))</span>|
		end
		message
	rescue Net::HTTPResponse, Net::HTTPExceptions => e
		@logger.error "amazon.rb: #{e.message}"
		message = label || asin
		if @mode == 'preview' then
			message << %Q|<span class="message">(#{h e.message})</span>|
		end
		message
	rescue NoMethodError
		@logger.error "amazon.rb: #{json["Errors"][0]["Message"]}"
		message = label || asin
		if @mode == 'preview' then
			message << %Q|<span class="message">(#{h json["Errors"][0]["Message"]})</span>|
		end
		message
	end
end

add_conf_proc( 'amazon', @amazon_label_conf ) do
	amazon_conf_proc
end

def amazon_conf_proc
	if @mode == 'saveconf' then
		@conf['amazon.imgsize'] = @cgi.params['amazon.imgsize'][0].to_i
		@conf['amazon.hidename'] = (@cgi.params['amazon.hidename'][0] == 'true')
		@conf['amazon.bitly'] = (@cgi.params['amazon.bitly'][0] == 'true')
		@conf['amazon.nodefault'] = (@cgi.params['amazon.nodefault'][0] == 'true')
		if @cgi.params['amazon.clearcache'][0] == 'true' then
			Dir["#{@cache_path}/amazon/*"].each do |cache|
				File::delete( cache )
			end
		end
		unless @conf['amazon.hideconf'] then
			@conf['amazon.aid'] = @cgi.params['amazon.aid'][0]
		end
	end

	result = ''

	result << <<-HTML
		<h3>#{@amazon_label_imgsize}</h3>
		<p><select name="amazon.imgsize">
			<option value="0"#{" selected" if @conf['amazon.imgsize'] == 0}>#{@amazon_label_large}</option>
			<option value="1"#{" selected" if @conf['amazon.imgsize'] == 1}>#{@amazon_label_regular}</option>
			<option value="2"#{" selected" if @conf['amazon.imgsize'] == 2}>#{@amazon_label_small}</option>
		</select></p>
		<h3>#{@amazon_label_title}</h3>
		<p><select name="amazon.hidename">
			<option value="true"#{" selected" if @conf['amazon.hidename']}>#{@amazon_label_hide}</option>
			<option value="false"#{" selected" unless @conf['amazon.hidename']}>#{@amazon_label_show}</option>
		</select></p>
	HTML

	if @options['bitly.login'] and @options['bitly.key'] then
		result << <<-HTML
			<h3>#{@amazon_label_bitly}</h3>
			<p><select name="amazon.bitly">
				<option value="true"#{" selected" if @conf['amazon.bitly']}>#{@amazon_label_bitly_enabled}</option>
				<option value="false"#{" selected" unless @conf['amazon.bitly']}>#{@amazon_label_bitly_disabled}</option>
			</select></p>
		HTML
	end

	result << <<-HTML
		<h3>#{@amazon_label_notfound}</h3>
		<p><select name="amazon.nodefault">
			<option value="true"#{" selected" if @conf['amazon.nodefault']}>#{@amazon_label_usetitle}</option>
			<option value="false"#{" selected" unless @conf['amazon.nodefault']}>#{@amazon_label_usedefault}</option>
		</select></p>
		<h3>#{@amazon_label_clearcache}</h3>
		<p><label for="amazon.clearcache"><input type="checkbox" id="amazon.clearcache" name="amazon.clearcache" value="true">#{@amazon_label_clearcache_desc}</label></p>
	HTML

	unless @conf['amazon.hideconf'] then
		result << <<-HTML
			<h3>#{@amazon_label_aid}</h3>
			<p>#{@amazon_label_aid_desc}</p>
			<p><input name="amazon.aid" value="#{h( @conf['amazon.aid'] ) if @conf['amazon.aid']}"></p>
		HTML
	end
	result
end

def isbn_detail( asin )
	amazon_get( asin, true, nil, 'detail' )
end

def isbn_image( asin, label = nil )
	amazon_get( asin, true, label )
end

def isbn_image_left( asin, label = nil )
	amazon_get( asin, true, label, 'left' )
end

def isbn_image_right( asin, label = nil )
	amazon_get( asin, true, label, 'right' )
end

def isbn( asin, label = nil )
	amazon_get( asin, false, label )
end

# for compatibility
alias isbnImgLeft isbn_image_left
alias isbnImgRight isbn_image_right
alias isbnImg isbn_image
alias amazon isbn_image

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
