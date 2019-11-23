require 'aws/sig_v4'
require 'json'
require 'net/http'

module AWS
	class PAAPI
		Market = Struct.new(:host, :region)
		MARKETS = {
			au: Market.new('webservices.amazon.com.au', 'us-west-2'),
			br: Market.new('webservices.amazon.com.br'  'us-east-1'),
			ca: Market.new('webservices.amazon.ca',     'us-east-1'),
			fr: Market.new('webservices.amazon.fr',     'eu-west-1'),
			de: Market.new('webservices.amazon.de',     'eu-west-1'),
			in: Market.new('webservices.amazon.in',     'eu-west-1'),
			it: Market.new('webservices.amazon.it',     'eu-west-1'),
			jp: Market.new('webservices.amazon.co.jp',  'us-west-2'),
			mx: Market.new('webservices.amazon.com.mx', 'us-east-1'),
			es: Market.new('webservices.amazon.es',     'eu-west-1'),
			tr: Market.new('webservices.amazon.com.tr', 'eu-west-1'),
			ae: Market.new('webservices.amazon.ae',     'eu-west-1'),
			uk: Market.new('webservices.amazon.co.uk',  'eu-west-1'),
			us: Market.new('webservices.amazon.com',    'us-east-1'),
		}.freeze

		def initialize(access_key, secret_key, partner_tag)
			@access_key, @secret_key, @partner_tag = access_key, secret_key, partner_tag
		end

		def get_items(asin, locale)
			asin = isbn13to10(asin) if asin.length == 13
			payload = {
				"PartnerTag" => @partner_tag,
				"PartnerType" => "Associates",
				"Marketplace" => MARKETS[locale].host.sub('webservices', 'www'),
				"ItemIds" => [asin],
				"Resources" => [
					"Images.Primary.Small",
					"Images.Primary.Medium",
					"Images.Primary.Large",
					"ItemInfo.ByLineInfo",
					"ItemInfo.Title",
					"Offers.Listings.Price"
				]
			}.to_json
			time_stamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
			signature = AWS::SigV4.signature(@secret_key, time_stamp, MARKETS[locale].region, MARKETS[locale].host, payload)
			authorization = "AWS4-HMAC-SHA256 Credential=#{@access_key}/#{time_stamp[0,8]}/#{MARKETS[locale].region}/ProductAdvertisingAPI/aws4_request, SignedHeaders=content-encoding;host;x-amz-content-sha256;x-amz-date;x-amz-target, Signature=#{signature}"

			headers = {
				"X-Amz-Target" => "com.amazon.paapi5.v1.ProductAdvertisingAPIv1.GetItems",
				"Content-Encoding" => "amz-1.0",
				"Host" => MARKETS[locale].host,
				"X-Amz-Date" => time_stamp,
				"X-Amz-Content-Sha256" => OpenSSL::Digest::SHA256.hexdigest(payload),
				"Authorization" => authorization,
				"Content-Type" => "application/json; charset=utf-8"
			}
			uri = URI("https://#{MARKETS[locale].host}/paapi5/getitems")
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			response = http.post(uri.path, payload, headers)
			response.value # raise on errors
			return response.body
		end

	private
		def isbn13to10(isbn13)
			sum, = isbn13[3, 9].split(//).map(&:to_i).reduce([0,10]){|s,d|[s[0] + d * s[1], s[1]-1]}
			return isbn13[3, 9] + %w(0 1 2 3 4 5 6 7 8 9 X 0)[11 - sum % 11]
		end
	end
end
