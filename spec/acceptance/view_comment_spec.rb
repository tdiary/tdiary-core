# -*- coding: utf-8 -*-
require 'acceptance_helper'

feature 'ツッコミの表示' do
	scenario 'ツッコミを隠す' do
		append_default_diary
		append_default_comment

		visit '/'
		click_link '追記'
		click_button "この日付の日記を編集"
		uncheck 'commentcheckboxr0'
		click_button 'ツッコミ表示状態変更'
		visit '/'
		expect(page).to have_no_content "alpha"
		expect(page).to have_no_content "こんにちは!こんにちは!"

		today = Date.today.strftime("%Y年%m月%d日")
		page.find('h2', text: today).click_link today
		expect(page).to have_no_content "alpha"
		expect(page).to have_no_content "こんにちは!こんにちは!"
	end

	scenario "日付表示だと絵文字を表示できる", :exclude_selenium do
		append_default_diary

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", with: "寿司"
		fill_in "body", with: <<-BODY
:sushi: は美味しい
BODY
		click_button '投稿'

		visit "/"
		today = Date.today.strftime("%Y年%m月%d日")
		page.find('h2', text: today).click_link today
		within('div.day div.comment div.commentbody') {
			expect(page.body).to be_include "<img src='http://www.emoji-cheat-sheet.com/graphics/emojis/sushi.png' width='20' height='20' title='sushi' alt='sushi' class='emoji' /> は美味しい"
		}
	end

	scenario "一覧表示でも絵文字を表示できる", :exclude_selenium do
		append_default_diary

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", with: "寿司"
		fill_in "body", with: <<-BODY
:sushi: は美味しい
BODY
		click_button '投稿'

		visit "/"
		within('div.day div.comment div.commentshort') {
			expect(page.body).to be_include "<img src='http://www.emoji-cheat-sheet.com/graphics/emojis/sushi.png' width='20' height='20' title='sushi' alt='sushi' class='emoji' /> は美味しい"
		}
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
