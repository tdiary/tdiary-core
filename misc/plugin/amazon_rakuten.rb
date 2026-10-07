#
# amazon_rakuten.rb: look books of amazon.rb up in Rakuten Books
#
# PA-API refuses Associates accounts that don't meet its eligibility
# requirements, which leaves amazon.rb without titles and images. With
# this plugin, books given by ISBN come from Rakuten Books Book Search
# API instead, and link to Rakuten Books as its terms require.
#
# options:
#   @options['rakuten.app_id']       : application ID of Rakuten Web Service
#   @options['rakuten.access_key']   : access key of the application
#   @options['rakuten.affiliate_id'] : Rakuten Affiliate ID for the links (optional)
#
# Register the application as an API/backend service allowing the IP
# address of the server. Rakuten requires the credit this plugin puts in
# the footer.
#
# Copyright (c) 2026 Hiroshi SHIBATA <hsbt@ruby-lang.org>
# Distributed under the GPL2 or any later version.
#
require 'json'
require 'net/http'

def amazon_book_item(isbn)
	app_id = @conf['rakuten.app_id']
	access_key = @conf['rakuten.access_key']
	return nil unless app_id && access_key

	uri = URI('https://openapi.rakuten.co.jp/services/api/BooksBook/Search/20170404')
	params = {applicationId: app_id, accessKey: access_key, isbn: isbn, outOfStockFlag: 1, formatVersion: 2}
	params[:affiliateId] = @conf['rakuten.affiliate_id'] if @conf['rakuten.affiliate_id']
	uri.query = URI.encode_www_form(params)
	# Rakuten answers 429 to more than one request a second
	sleep 1 if @amazon_rakuten_requested
	@amazon_rakuten_requested = true
	response = Net::HTTP.get_response(uri)
	response.value
	book = JSON.parse(response.body)['Items'][0]
	return nil unless book

	{
		'DetailPageURL' => book['affiliateUrl'].to_s.empty? ? book['itemUrl'] : book['affiliateUrl'],
		'ItemInfo' => {
			'Title' => {'DisplayValue' => book['title']},
			'ByLineInfo' => {
				'Contributors' => [{'Name' => book['author'][%r{[^/]*}]}],
				'Manufacturer' => {'DisplayValue' => book['publisherName']}
			}
		},
		'Images' => {
			'Primary' => {
				'Small' => {'URL' => book['smallImageUrl']},
				'Medium' => {'URL' => book['mediumImageUrl']},
				'Large' => {'URL' => book['largeImageUrl']}
			}
		},
		'OffersV2' => {
			'Listings' => [{'Price' => {'Money' => {'DisplayAmount' => "￥#{book['itemPrice'].to_s.gsub(/(\d)(?=(\d{3})+\z)/, '\1,')}"}}}]
		}
	}
rescue => e
	@logger.error "amazon_rakuten.rb: #{e.message}"
	nil
end

add_footer_proc do
	%Q|<div class="footer"><a href="https://developers.rakuten.com/">Supported by Rakuten Developers</a></div>|
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
