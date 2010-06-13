# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature 'ツッコミの表示' do
	background do
		setup_tdiary
	end

	scenario 'ツッコミを隠す' do
		append_default_diary

		visit '/'
		click 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
こんにちは!こんにちは!
BODY

		click_button '投稿'
		page.should have_content "Click here!"

		visit '/'
		click '追記'
		click_button "この日付の日記を編集"
		uncheck 'commentcheckboxr0'
		click_button 'ツッコミ表示状態変更'
		visit '/'
		page.should have_no_content "alpha"
		page.should have_no_content "こんにちは!こんにちは!"

		click "#{Date.today.strftime("%Y年%m月%d日")}"
		page.should have_no_content "alpha"
		page.should have_no_content "こんにちは!こんにちは!"
	end
end
