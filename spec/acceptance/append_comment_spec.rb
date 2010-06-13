# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature 'ツッコミの更新' do
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

		click "#{Date.today.strftime('%Y年%m月%d日')}"
		within('div.day div.comment div.commentbody') { 
			within('div.commentator'){
				within('span.commenttime'){ page.should have_content "%04d年%02d月%02d日" % Date.today.strftime.split('-').map(&:to_i) }
				within('span.commentator'){ page.should have_content "alpha" }
			}
			page.should have_content "こんにちは!こんにちは!"
		}
	end

	scenario 'ツッコミを2回入れる' do
		append_default_diary
		append_default_comment
		visit "/"
		click 'ツッコミを入れる'
		fill_in "name", :with => "bravo"
		fill_in "body", :with => <<-BODY
こんばんは!こんばんは!
BODY

		click_button '投稿'
		page.should have_content "Click here!"

		visit "/"
		within('div.day div.comment div.commentshort') {
			within('span.commentator') {
				page.should have_content "alpha"
				page.should have_content "bravo"
			}
			page.should have_content "こんにちは!こんにちは!"
			page.should have_content "こんばんは!こんばんは!"
		}

		click "#{Date.today.strftime('%Y年%m月%d日')}"
		within('div.day div.comment div.commentbody') {
			within('div.commentator'){
				within('span.commenttime'){ page.should have_content "%04d年%02d月%02d日" % Date.today.strftime.split('-').map(&:to_i) }
				within('span.commentator'){ page.should have_content "alpha" }
				within('span.commentator'){ page.should have_content "bravo" }
			}
			page.should have_content "こんにちは!こんにちは!"
			page.should have_content "こんばんは!こんばんは!"
		}
	end
end
