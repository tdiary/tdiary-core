# -*- coding: utf-8 -*-
require 'acceptance_helper'

feature 'ツッコミの更新' do
	scenario 'ツッコミを入れてlatestとdayで表示する' do
		append_default_diary
		visit '/'
		click_link 'ツッコミを入れる'
		fill_in "name", with: "alpha"
		fill_in "body", with: <<-BODY
こんにちは!こんにちは!
BODY

		click_button '投稿'
		page.should have_content "Click here!"

		visit "/"
		within('div.day div.comment div.commentshort') {
			within('span.commentator') {
				page.should have_content "alpha"
			}
			page.should have_content "こんにちは!こんにちは!"
		}
		today = Date.today.strftime('%Y年%m月%d日')
		page.find('h2', text: today).click_link today
		within('div.day div.comment div.commentbody') {
			within('div.commentator'){
				t = Time.now
				within('span.commenttime'){ page.should have_content "%04d年%02d月%02d日" % [t.year, t.month, t.day] }
				within('span.commentator'){ page.should have_content "alpha" }
			}
			page.should have_content "こんにちは!こんにちは!"
		}
	end

	scenario 'ツッコミを2回入れる' do
		append_default_diary
		append_default_comment
		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", with: "bravo"
		fill_in "body", with: <<-BODY
こんばんは!こんばんは!
BODY

		click_button '投稿'
		page.should have_content "Click here!"

		visit "/"
		within('div.day div.comment div.commentshort') {
			page.should have_content "alpha"
			page.should have_content "bravo"
			page.should have_content "こんにちは!こんにちは!"
			page.should have_content "こんばんは!こんばんは!"
		}

		today = Date.today.strftime('%Y年%m月%d日')
		page.find('h2', text: today).click_link today
		within('div.day div.comment div.commentbody') {
			t = Time.now
			page.should have_content "%04d年%02d月%02d日" % [t.year, t.month, t.day]
			page.should have_content "alpha"
			page.should have_content "bravo"
			page.should have_content "こんにちは!こんにちは!"
			page.should have_content "こんばんは!こんばんは!"
		}
	end

	scenario 'recent_comment3.rb', :exclude_secure do
		append_default_diary
		visit '/'
		click_link 'ツッコミを入れる'
		fill_in "name", with: "alpha"
		fill_in "body", with: <<-BODY
こんにちは!こんにちは!
BODY

		click_button '投稿'
		page.should have_content "Click here!"

		visit "/"
		within('ol.recent-comment > li') do
			page.should have_content "alpha"
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
