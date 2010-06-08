# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature 'ツッコミの管理' do
	def append_default_diary
		visit '/update.rb'

		fill_in "title", :with => "tDiaryのテスト"
		fill_in "body", :with => <<-BODY
!さて、テストである。
とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P
BODY
		click_button "追記"
	end

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

		visit "/update.rb"
		click_button "この日付の日記を編集"
		uncheck 'commentcheckboxr0'
		click_button 'ツッコミ表示状態変更'

		visit '/'
		page.should have_no_content "alpha"
		page.should have_no_content "こんにちは!こんにちは!"

		visit "/?date=#{Date.today.strftime("%Y%m%d")}"
		page.should have_no_content "alpha"
		page.should have_no_content "こんにちは!こんにちは!"
	end
end
