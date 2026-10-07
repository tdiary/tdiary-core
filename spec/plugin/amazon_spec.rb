require File.expand_path('../plugin_helper', __FILE__)
require 'aws/pa_api'
require 'logger'
require 'tmpdir'

describe "amazon plugin" do
	around do |example|
		Dir.mktmpdir {|dir| @cache_path = dir; example.run }
	end

	let(:conf) {
		PluginFake::Config.new.tap {|conf|
			conf.plugin_path = "spec/fixtures/plugin"
			conf.lang = "ja"
			conf.options['amazon.aid'] = 'tdiary-22'
			conf.options['rakuten.app_id'] = 'app-id'
			conf.options['rakuten.access_key'] = 'pk_key'
		}
	}

	let(:book) {
		{
			'title' => 'プログラミングTypeScript',
			'author' => 'Boris Cherny/今村 謙士/原 隆文',
			'publisherName' => 'オライリー・ジャパン',
			'itemUrl' => 'https://books.rakuten.co.jp/rb/16199514/',
			'affiliateUrl' => '',
			'itemPrice' => 3520,
			'smallImageUrl' => 'https://thumbnail.image.rakuten.co.jp/@0_mall/book/cabinet/9045/9784873119045.jpg?_ex=64x64',
			'mediumImageUrl' => 'https://thumbnail.image.rakuten.co.jp/@0_mall/book/cabinet/9045/9784873119045.jpg?_ex=120x120',
			'largeImageUrl' => 'https://thumbnail.image.rakuten.co.jp/@0_mall/book/cabinet/9045/9784873119045.jpg?_ex=200x200'
		}
	}

	let(:rakuten_requests) { [] }

	def rakuten_returns( *items )
		allow( Net::HTTP ).to receive( :get_response ) {|uri|
			rakuten_requests << uri
			Net::HTTPOK.new( '1.1', '200', 'OK' ).tap {|response|
				allow( response ).to receive( :body ).and_return( {'Items' => items}.to_json )
			}
		}
	end

	def amazon_refuses
		conf.options['amazon.access_key'] = 'access'
		conf.options['amazon.secret_key'] = 'secret'
		forbidden = Net::HTTPForbidden.new( '1.1', '403', 'Forbidden' )
		allow( forbidden ).to receive( :body ).and_return( '' )
		allow_any_instance_of( AWS::PAAPI ).to receive( :get_items ).and_raise( Net::HTTPClientException.new( '403 "Forbidden"', forbidden ) )
	end

	def amazon_plugin( *files )
		TDiary::Plugin.new( conf: conf, mode: 'day', cache_path: @cache_path, logger: Logger.new( nil ) ).tap {|plugin|
			files.each {|file| plugin.load_plugin( "misc/plugin/#{file}" ) }
		}
	end

	it "shows a book from Rakuten Books with a link to it" do
		rakuten_returns( book )
		plugin = amazon_plugin( 'amazon.rb', 'amazon_rakuten.rb' )
		html = plugin.isbn_image( '4-87311-904-9' )

		expect( html ).to include 'href="https://books.rakuten.co.jp/rb/16199514/"'
		expect( html ).to include %Q|src="#{book['mediumImageUrl']}"|
		expect( html ).not_to include 'height='
		expect( html ).to include 'プログラミングTypeScript(Boris Cherny)'
		expect( plugin.instance_eval { footer_proc } ).to include 'Supported by Rakuten Developers'

		expect( URI.decode_www_form( rakuten_requests.first.query ).to_h ).to include( 'applicationId' => 'app-id', 'accessKey' => 'pk_key', 'isbn' => '4873119049' )
	end

	it "shows the details of a book from Rakuten Books" do
		rakuten_returns( book )
		html = amazon_plugin( 'amazon.rb', 'amazon_rakuten.rb' ).isbn_detail( '4873119049' )

		expect( html ).to include %Q|src="#{book['smallImageUrl']}"|
		expect( html ).to include '<span class="amazon-label">オライリー・ジャパン</span>'
		expect( html ).to include '<span class="amazon-price">￥3,520</span>'
	end

	it "falls back to Rakuten Books when Amazon refuses the request" do
		amazon_refuses
		rakuten_returns( book )
		plugin = amazon_plugin( 'amazon.rb', 'amazon_rakuten.rb' )

		expect( plugin.isbn_image( '9784873119045' ) ).to include 'href="https://books.rakuten.co.jp/rb/16199514/"'
		expect( plugin.isbn_image( '9784873119045' ) ).to include %Q|src="#{book['mediumImageUrl']}"|
		expect( rakuten_requests.size ).to eq 1
	end

	it "links to Rakuten Books with the affiliate ID" do
		conf.options['rakuten.affiliate_id'] = 'aff-id'
		rakuten_returns( book.merge( 'affiliateUrl' => 'https://hb.afl.rakuten.co.jp/hgc/aff-id/?pc=https%3A%2F%2Fbooks.rakuten.co.jp%2Frb%2F16199514%2F' ) )
		plugin = amazon_plugin( 'amazon.rb', 'amazon_rakuten.rb' )

		expect( plugin.isbn_image( '4873119049' ) ).to include 'href="https://hb.afl.rakuten.co.jp/hgc/aff-id/?pc=https%3A%2F%2Fbooks.rakuten.co.jp%2Frb%2F16199514%2F"'
		expect( URI.decode_www_form( rakuten_requests.first.query ).to_h ).to include( 'affiliateId' => 'aff-id' )
	end

	it "keeps the link to Amazon when Rakuten Books doesn't know the book" do
		amazon_refuses
		rakuten_returns
		plugin = amazon_plugin( 'amazon.rb', 'amazon_rakuten.rb' )

		expect( plugin.isbn_image( '4873119049', 'TypeScript' ) ).to eq '<a href="https://www.amazon.co.jp/dp/4873119049">TypeScript</a>'
	end

	it "doesn't look up items other than books" do
		rakuten_returns( book )
		plugin = amazon_plugin( 'amazon.rb', 'amazon_rakuten.rb' )

		expect( plugin.isbn_image( 'B000067P0I' ) ).to eq 'B000067P0I'
		expect( rakuten_requests ).to be_empty
	end

	it "works as before without amazon_rakuten.rb" do
		rakuten_returns( book )
		plugin = amazon_plugin( 'amazon.rb' )

		expect( plugin.isbn_image( '4873119049' ) ).to eq '4873119049'
		expect( rakuten_requests ).to be_empty
	end
end
