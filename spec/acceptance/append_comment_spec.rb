# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature 'ツッコミの更新' do
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

	scenario 'ツッコミを入れてlatestとdayで表示する' do
		append_default_diary

		visit '/'

		click 'ツッコミを入れる'

		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
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

		visit "/?date=#{Date.today.strftime("%Y%m%d")}"
		within('div.day div.comment div.commentbody') { 
			within('div.commentator'){
				within('span.commenttime'){ page.should have_content "%04d年%02d月%02d日" % Date.today.strftime.split('-') }
				within('span.commentator'){ page.should have_content "alpha" }
			}
			page.should have_content "こんにちは!こんにちは!"
		}
	end

	scenario 'ツッコミを2回入れる' do
		append_default_diary

		visit '/'

		click 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
こんにちは!こんにちは!
BODY
		click_button '投稿'

		visit "/"
		click 'ツッコミを入れる'
		fill_in "name", :with => "bravo"
		fill_in "body", :with => <<-BODY
こんばんは!こんばんは!
BODY
		click_button '投稿'

		visit "/"
		within('div.day div.comment div.commentshort') {
			within('span.commentator') {
				page.should have_content "alpha"
				page.should have_content "bravo"
			}
			page.should have_content "こんにちは!こんにちは!"
			page.should have_content "こんばんは!こんばんは!"
		}

		visit "/?date=#{Date.today.strftime("%Y%m%d")}"
		within('div.day div.comment div.commentbody') {
			within('div.commentator'){
				within('span.commenttime'){ page.should have_content "%04d年%02d月%02d日" % Date.today.strftime.split('-') }
				within('span.commentator'){ page.should have_content "alpha" }
				within('span.commentator'){ page.should have_content "bravo" }
			}
			page.should have_content "こんにちは!こんにちは!"
			page.should have_content "こんばんは!こんばんは!"
		}
	end
end
