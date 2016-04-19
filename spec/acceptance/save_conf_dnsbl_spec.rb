require 'acceptance_helper'
require 'resolv'

feature 'spamフィルタ設定の利用', :exclude_selenium do
	scenario 'IPベースのブラックリストの spam-champuru が spamlookup に置き換わる' do
		visit '/update.rb?conf=dnsblfilter'
		fill_in 'spamlookup.ip.list', with: "dnsbl.spam-champuru.livedoor.com"
		fill_in 'spamlookup.domain.list', with: ""
		fill_in 'spamlookup.safe_domain.list', with: ""
		page.all('div.saveconf').first.click_button 'OK'

		visit '/update.rb?conf=dnsblfilter'
		expect(page).to have_no_content "dnsbl.spam-champuru.livedoor.com"
		expect(page).to have_content "bsb.spamlookup.net"
	end

	scenario 'IPベースのブラックリストが動作する' do
		allow(IPSocket).to receive(:getaddress) { '127.0.0.1' }
		allow(Resolv).to receive(:getaddress) { '127.0.0.1' }

		append_default_diary

		visit '/update.rb?conf=dnsblfilter'
		fill_in 'spamlookup.ip.list', with: "bsb.spamlookup.net"
		fill_in 'spamlookup.domain.list', with: ""
		fill_in 'spamlookup.safe_domain.list', with: ""
		page.all('div.saveconf').first.click_button 'OK'

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", with: "alpha"
		fill_in "body", with: <<-BODY
こんにちは!こんにちは!
http://www.example.com
BODY
		click_button '投稿'

		visit "/"
		expect(page).to have_no_content "alpha"
		expect(page).to have_no_content "こんにちは!こんにちは!"
	end

	scenario 'IPベースのブラックリストでセーフの場合' do
		allow(IPSocket).to receive(:getaddress) { raise Timeout::Error }

		append_default_diary

		visit '/update.rb?conf=dnsblfilter'
		fill_in 'spamlookup.ip.list', with: "bsb.spamlookup.net"
		fill_in 'spamlookup.domain.list', with: ""
		fill_in 'spamlookup.safe_domain.list', with: ""
		page.all('div.saveconf').first.click_button 'OK'

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", with: "alpha"
		fill_in "body", with: <<-BODY
こんにちは!こんにちは!
http://www.example.com
BODY
		click_button '投稿'

		visit "/"
		expect(page).to have_content "alpha"
		expect(page).to have_content "こんにちは!こんにちは!"
	end

	scenario 'ドメインベースのブラックリストが動作する' do
		allow(Resolv).to receive(:getaddress) { '127.0.0.1' }

		append_default_diary

		visit '/update.rb?conf=dnsblfilter'
		fill_in 'spamlookup.ip.list', with: ""
		fill_in 'spamlookup.domain.list', with: "bsb.spamlookup.net"
		fill_in 'spamlookup.safe_domain.list', with: ""
		page.all('div.saveconf').first.click_button 'OK'

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", with: "alpha"
		fill_in "body", with: <<-BODY
こんにちは!こんにちは!
http://www.example.com
BODY
		click_button '投稿'

		visit "/"
		expect(page).to have_no_content "alpha"
		expect(page).to have_no_content "こんにちは!こんにちは!"
	end

	scenario 'ドメインベースのブラックリストでセーフの場合' do
		allow(Resolv).to receive(:getaddress) { raise Timeout::Error }

		append_default_diary

		visit '/update.rb?conf=dnsblfilter'
		fill_in 'spamlookup.ip.list', with: ""
		fill_in 'spamlookup.domain.list', with: "bsb.spamlookup.net"
		fill_in 'spamlookup.safe_domain.list', with: ""
		page.all('div.saveconf').first.click_button 'OK'

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", with: "alpha"
		fill_in "body", with: <<-BODY
こんにちは!こんにちは!
http://www.example.com
BODY
		click_button '投稿'

		visit "/"
		expect(page).to have_content "alpha"
		expect(page).to have_content "こんにちは!こんにちは!"
	end

	scenario 'ブラックリストに問い合わせないリストが動作する' do
		expect(IPSocket).to receive(:getaddress).exactly(0)
		expect(Resolv).to receive(:getaddress).exactly(0)

		append_default_diary

		visit '/update.rb?conf=dnsblfilter'
		fill_in 'spamlookup.ip.list', with: "bsb.spamlookup.net"
		fill_in 'spamlookup.domain.list', with: "bsb.spamlookup.net"
		fill_in 'spamlookup.safe_domain.list', with: "www.example.com"
		page.all('div.saveconf').first.click_button 'OK'

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", with: "alpha"
		fill_in "body", with: <<-BODY
こんにちは!こんにちは!
http://www.example.com
BODY
		click_button '投稿'

		visit "/"
		expect(page).to have_content "alpha"
		expect(page).to have_content "こんにちは!こんにちは!"
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
