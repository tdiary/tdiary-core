# -*- coding: utf-8 -*-
require 'acceptance_helper'

feature 'spamフィルタ設定の利用' do
	scenario 'おすすめフィルタの内容が保存される'

	scenario 'CSRF情報が保存される'

	scenario 'spamと判定されたツッコミを捨てる'

	scenario 'URLの数によるspam判定' do
		append_default_diary

		visit '/'
		click_link '追記'
		click_link '設定'
		click_link 'spamフィルタ'
		fill_in "spamfilter.max_uris", :with => 1

		click_button 'OK'
		within('title') { page.should have_content('(設定完了)') }

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
こんにちは!こんにちは!
http://www.example.org
http://www.example.org
BODY
		click_button '投稿'

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "bravo"
		fill_in "body", :with => <<-BODY
こんばんは!こんばんは!
http://www.example.org
BODY
		click_button '投稿'

		visit "/"
		page.should have_no_content "alpha"
		page.should have_no_content "こんにちは!こんにちは!"
		page.should have_content "bravo"
		page.should have_content "こんばんは!こんばんは!"
	end

	scenario 'URLの割合によるspam判定' do
		append_default_diary

		visit '/'
		click_link '追記'
		click_link '設定'
		click_link 'spamフィルタ'
		fill_in "spamfilter.max_rate", :with => 50

		click_button 'OK'
		within('title') { page.should have_content('(設定完了)') }

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
こんにちは!こんにちは!
http://www.example.org
http://www.example.org
http://www.example.org
BODY
		click_button '投稿'

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "bravo"
		fill_in "body", :with => <<-BODY
こんばんは!こんばんは!
こんばんは!こんばんは!
http://www.example.org
BODY
		click_button '投稿'

		visit "/"
		page.should have_no_content "alpha"
		page.should have_no_content "こんにちは!こんにちは!"
		page.should have_content "bravo"
		page.should have_content "こんばんは!こんばんは!"
	end

	scenario 'キーワードでツッコミがはじかれる' do
		append_default_diary

		visit '/'
		click_link '追記'
		click_link '設定'
		click_link 'spamフィルタ'
		fill_in "spamfilter.bad_comment_patts", :with => <<-BODY
こんにちは!
BODY
		click_button 'OK'
		within('title') { page.should have_content('(設定完了)') }

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
こんにちは!こんにちは!
BODY
		click_button '投稿'

		visit "/"
		page.should have_no_content "alpha"
		page.should have_no_content "こんにちは!こんにちは!"
	end

	scenario 'メールアドレスでツッコミがはじかれる' do
		append_default_diary

		visit '/'
		click_link '追記'
		click_link '設定'
		click_link 'spamフィルタ'
		fill_in "spamfilter.bad_mail_patts", :with => <<-BODY
example.com
BODY
		click_button 'OK'
		within('title') { page.should have_content('(設定完了)') }

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "mail", :with => "admin@example.com"
		fill_in "body", :with => <<-BODY
こんにちは!こんにちは!
BODY
		click_button '投稿'

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "bravo"
		fill_in "mail", :with => "t@tdtds.jp"
		fill_in "body", :with => <<-BODY
こんばんは!こんばんは!
BODY
		click_button '投稿'

		visit "/"
		page.should have_no_content "alpha"
		page.should have_no_content "こんにちは!こんにちは!"
		page.should have_content "bravo"
		page.should have_content "こんばんは!こんばんは!"

	end

	scenario 'URLでツッコミがはじかれる' do
		append_default_diary

		visit '/'
		click_link '追記'
		click_link '設定'
		click_link 'spamフィルタ'
		fill_in "spamfilter.bad_uri_patts", :with => <<-BODY
example
BODY
		click_button 'OK'
		within('title') { page.should have_content('(設定完了)') }

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
こんにちは! http://www.example.com
BODY
		click_button '投稿'

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "bravo"
		fill_in "body", :with => <<-BODY
example こんにちは!
BODY
		click_button '投稿'

		visit "/"
		page.should have_no_content "alpha"
		page.should have_no_content "こんにちは!こんにちは!"
		page.should have_content "bravo"
		page.should have_content "example こんにちは!"
	end

	scenario 'IPアドレスでツッコミが弾かれる'

	scenario 'ツッコミの注意文が保存されて表示される'

	scenario 'スパムフィルター選択が保存される'

end
