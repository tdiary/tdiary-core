#
# A Simple impl of AWS Signature V4 for PA-API GetItems
#
require 'openssl'

module AWS
	module SigV4
		def self.canonical_request(host, payload, time_stamp)
			headers = {
				'Content-Encoding' => 'amz-1.0',
				'Host' => host,
				'X-Amz-Content-Sha256' => OpenSSL::Digest::SHA256.hexdigest(payload),
				'X-Amz-Date' => time_stamp,
				'X-Amz-Target' => "com.amazon.paapi5.v1.ProductAdvertisingAPIv1.GetItems",
			}
			[
				"POST",
				"/paapi5/getitems",
				'',
				headers.keys.sort.map{|k|"#{k.downcase}:#{headers[k]}"}.join("\n") + "\n",
				headers.keys.sort.map{|k|k.downcase}.join(';'),
				OpenSSL::Digest::SHA256.hexdigest(payload)
			].join("\n")
		end
		def self.string2sign(host, payload, time_stamp)
			[
				'AWS4-HMAC-SHA256',
				time_stamp,
				"#{time_stamp[0,8]}/us-west-2/ProductAdvertisingAPI/aws4_request",
				OpenSSL::Digest::SHA256.hexdigest(canonical_request(host, payload, time_stamp))
			].join("\n")
		end
		def self.signature(secret, time_stamp, region, host, payload)
			k_secret = secret
			k_date = hmac("AWS4" + k_secret, time_stamp[0,8])
			k_region = hmac(k_date, region)
			k_service = hmac(k_region, 'ProductAdvertisingAPI')
			k_credential = hmac(k_service, "aws4_request")
			OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), k_credential, string2sign(host, payload, time_stamp))
		end
		def self.hmac(key, value)
			OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, value)
		end
	end
end