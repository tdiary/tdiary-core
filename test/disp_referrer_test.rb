# -*- coding: utf-8 -*-

require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../test_plugin_helper', __FILE__)

include TDiary::PluginTestStub

require 'ja/disp_referrer'
require 'nkf'
require 'uri'

# Test cases which are far from complete:
# run this script to unit-test just small part of the features

# I am sorry that the language resouce has been loaded to the
# top level. Therefore, we will spit required objects defined
# in tdiary.rb to the top level.

# Stab for @conf
class StabConf
	def secure; false; end
	def options; {}; end
	def referer_table; []; end
	def no_referer; []; end
	def io_class; nil; end
end
@conf = StabConf.new

# Required module and class structures
module TDiary
	class TDiaryLatest
	end

	class IO::Default
	end
end

# Methods that shuold have been defined in Plugin
class Object
	def referer_today; '本日のリンク元'; end
end

# load the main plugin file
require 'disp_referrer'

class TestSearchEngines < Test::Unit::TestCase
	def setup
		@dr2_setup = DispRef2Setup.new(StabConf.new, nil, true, [], '')
	end

	def match(url, keyword, provider = nil)
		x = DispRef2URL.new(url).parse(@dr2_setup)
		assert_equal(:search, x.category, url)
		assert_equal(to_native(keyword), to_native(x.key), url)
		assert_equal(to_native(provider), to_native(x.title_ignored), url) if provider
	end

	def test_search_engines
		[
			# simple test to test the unittest code
			['http://www.google.com/search?q=test', 'test', '.comのGoogle検索'],
			['http://www.google.com/search?q=test', 'test'],
			['http://images.google.com/images?q=qwertz&start=240&ndsp=20&svnum=10&hl=fr&lr=&sa=N', 'qwertz'],
			['http://bloger.x0.com/result/%E3%83%86%E3%82%B9%E3%83%88%E3%81%A7%E3%81%99%E3%81%A8/%E3%83%86%E3%82%B9%E3%83%88%E3%81%A7%E3%81%99%E3%81%A8', 'テストですと', 'YGブログ検索'],
			['http://wordtantei.com/result/%E3%83%86%E3%82%B9%E3%83%88/%E3%83%86%E3%82%B9%E3%83%88', 'テスト', 'ワード探偵'],
			['http://www.sfa-cms.net/word/zunda/zunda+%E3%81%9A%E3%82%93%E3%81%A0', 'zunda ずんだ', '入れ⇔替え検索'],
			['http://search.hatena.ne.jp/search?word=zunda&site=', 'zunda', 'はてな検索'],
			['http://search.live.com/results.aspx?q=%E3%81%8A%E3%81%BE%E3%81%AC%E3%81%91%E6%B4%BB%E5%8B%95%E6%97%A5%E8%AA%8C&go=%E6%A4%9C%E7%B4%A2&mkt=ja-jp&scope=&FORM=LIVSOP', 'おまぬけ活動日誌', 'Live Search'],
		].each do |url, keyword, provider|
			match(url, keyword, provider)
		end
	end

	def test_cached_urls
		[
			['http://72.14.235.104/search?q=cache:gj71ka2AWYgJ:zunda.freeshell.org/d/20071019.html+rsync+error+error+in+file+IO&hl=ja&ct=clnk&cd=2&gl=jp', 'rsync error error in file IO', 'Google検索(zunda.freeshell.org/d/20071019.htmlのキャッシュ)'],
		].each do |url, keyword, provider|
			match(url, keyword, provider)
		end
	end

	def test_recursive_conversion
		[
			['http://images.google.com/imgres?imgurl=http://zunda.freeshell.org/p/020302_GermanKbdSml.jpg&imgrefurl=http://zunda.freeshell.org/d/20050629.html&h=170&w=512&sz=30&hl=fr&start=256&tbnid=TlfDZCEB4H1PTM:&tbnh=43&tbnw=131&prev=/images%3Fq%3Dqwertz%26start%3D240%26ndsp%3D20%26svnum%3D10%26hl%3Dfr%26lr%3D%26sa%3DN', 'qwertz', '.comのGoogleイメージ検索'],
			['http://translate.google.com/translate?hl=en&sl=ja&u=http://zunda.freeshell.org/d/20070706.html&sa=X&oi=translate&resnum=2&ct=result&prev=/search%3Fq%3Del%2Bcombote%2Binternational%2Blotto%2Bcommission%26hl%3Den', 'el combote international lotto commission', '.comのGoogle検索'],
			['http://64.233.179.104/translate_c?hl=en&sl=ja&u=http://zunda.freeshell.org/d/20070501.html&prev=/search%3Fq%3Dhtaccess%2Bbrowser%2Bagent%2BDoCoMo/1.0/N505i/c20/TB/W20H10%26hl%3Den%26client%3Dfirefox-a%26rls%3Dorg.mozilla:en-US:official%26hs%3DKUR', 'htaccess browser agent DoCoMo/1.0/N505i/c20/TB/W20H10', 'Google検索'],
			['http://216.239.37.104/translate_c?hl=en&sl=ja&u=http://zunda.freeshell.org/d/20050907.html&prev=/search%3Fq%3Drnbovdd.dll%26start%3D10%26hl%3Den%26lr%3D%26client%3Dfirefox-a%26rls%3Dorg.mozilla:en-US:official%26sa%3DN', 'rnbovdd.dll', 'Google検索'],
			['http://66.249.93.104/translate_c?hl=en&sl=ja&u=http://zunda.freeshell.org/d/20051017.html&prev=/search%3Fq%3Dgperf%2Bwarning%2B%2522missing%2Binitializer%2522%26hl%3Den%26sa%3DG', 'gperf warning "missing initializer"']
		].each do |url, keyword, provider|
			match(url, keyword, provider)
		end
	end
end
