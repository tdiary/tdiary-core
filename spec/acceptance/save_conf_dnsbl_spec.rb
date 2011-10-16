# -*- coding: utf-8 -*-
require 'acceptance_helper'
require 'resolv'

feature 'spamフィルタ設定の利用' do
	scenario 'IPベースのブラックリストが動作する' do
		stub(IPSocket).getaddress.with_any_args { '127.0.0.1' }
		stub(Resolv).getaddress.with_any_args { '127.0.0.1' }

		append_default_diary

		visit '/update.rb?conf=dnsblfilter'
		fill_in 'spamlookup.ip.list', :with => "dnsbl.spam-champuru.livedoor.com"
		fill_in 'spamlookup.domain.list', :with => ""
		fill_in 'spamlookup.safe_domain.list', :with => ""
		click_button 'OK'

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
こんにちは!こんにちは!
http://www.example.com
BODY
		click_button '投稿'

		visit "/"
		page.should have_no_content "alpha"
		page.should have_no_content "こんにちは!こんにちは!"
	end

	scenario 'IPベースのブラックリストでセーフの場合' do
		stub(IPSocket).getaddress.with_any_args { raise TimeoutError }

		append_default_diary

		visit '/update.rb?conf=dnsblfilter'
		fill_in 'spamlookup.ip.list', :with => "dnsbl.spam-champuru.livedoor.com"
		fill_in 'spamlookup.domain.list', :with => ""
		fill_in 'spamlookup.safe_domain.list', :with => ""
		click_button 'OK'

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
こんにちは!こんにちは!
http://www.example.com
BODY
		click_button '投稿'

		visit "/"
		page.should have_content "alpha"
		page.should have_content "こんにちは!こんにちは!"
	end

	scenario 'ドメインベースのブラックリストが動作する' do
		stub(IPSocket).getaddress.with_any_args { '127.0.0.1' }
		stub(Resolv).getaddress.with_any_args { '127.0.0.1' }

		append_default_diary

		visit '/update.rb?conf=dnsblfilter'
		fill_in 'spamlookup.ip.list', :with => ""
		fill_in 'spamlookup.domain.list', :with => "bsb.spamlookup.net"
		fill_in 'spamlookup.safe_domain.list', :with => ""
		click_button 'OK'

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
こんにちは!こんにちは!
http://www.example.com
BODY
		click_button '投稿'

		visit "/"
		page.should have_no_content "alpha"
		page.should have_no_content "こんにちは!こんにちは!"
	end

	scenario 'ドメインベースのブラックリストでセーフの場合' do
		stub(Resolv).getaddress.with_any_args { raise TimeoutError }

		append_default_diary

		visit '/update.rb?conf=dnsblfilter'
		fill_in 'spamlookup.ip.list', :with => ""
		fill_in 'spamlookup.domain.list', :with => "bsb.spamlookup.net"
		fill_in 'spamlookup.safe_domain.list', :with => ""
		click_button 'OK'

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
こんにちは!こんにちは!
http://www.example.com
BODY
		click_button '投稿'

		visit "/"
		page.should have_content "alpha"
		page.should have_content "こんにちは!こんにちは!"
	end

	scenario 'ブラックリストに問い合わせないリストが動作する' do
		mock(IPSocket).getaddress.with_any_args.times(0) { '127.0.0.1' }
		mock(Resolv).getaddress.with_any_args.times(0) { '127.0.0.1' }

		append_default_diary

		visit '/update.rb?conf=dnsblfilter'
		fill_in 'spamlookup.ip.list', :with => "dnsbl.spam-champuru.livedoor.com"
		fill_in 'spamlookup.domain.list', :with => "bsb.spamlookup.net"
		fill_in 'spamlookup.safe_domain.list', :with => "www.example.com"
		click_button 'OK'

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
こんにちは!こんにちは!
http://www.example.com
BODY
		click_button '投稿'

		visit "/"
		page.should have_content "alpha"
		page.should have_content "こんにちは!こんにちは!"
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
