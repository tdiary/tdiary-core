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
		page.should have_no_content "alpha"
		page.should have_no_content "こんにちは!こんにちは!"

		today = Date.today.strftime("%Y年%m月%d日")
		page.find('h2', :text => today).click_link today
		page.should have_no_content "alpha"
		page.should have_no_content "こんにちは!こんにちは!"
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
