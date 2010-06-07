# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature '日記の追記' do
	background do
		setup_tdiary
	end

	scenario '更新画面のデフォルト表示' do
		visit '/update.rb'
		page.should have_content('日記の更新')

		y, m, d = Date.today.to_s.split('-').map {|t| t.sub(/^0+/, "") }
		within('div.day div.form') {
			within('span.year') { page.should have_field('year', :with => y) }
			within('span.month') { page.should have_field('month', :with => m) }
			within('span.day') { page.should have_field('day', :with => d) }
		}
	end

	scenario '今日の日記を書く' do
		visit '/update.rb'

		within('div.day div.form') {
			within('div.title') { fill_in "title", :with => "tDiaryのテスト" }
			within('div.textarea') {
				fill_in "body", :with => <<-BODY
!さて、テストである。
とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P
BODY
			}
		}

		click_button "追記"
		page.should have_content "Click here!"

		visit '/'
		within('div.day span.title'){ page.should have_content "tDiaryのテスト" }
		within('div.day div.section'){
			within('h3') { page.should have_content "さて、テストである。" }
			page.should have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
		}

		visit "/?date=#{Date.today.strftime("%Y%m%d")}"
		within('div.day span.title'){ page.should have_content "tDiaryのテスト" }
		within('div.day div.section'){
			within('h3') { page.should have_content "さて、テストである。" }
			page.should have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
		}
	end

	scenario '日付を指定して新しく日記を書く' do
		visit '/update.rb'

		within('div.day div.form') {
			within('span.year') { fill_in "year", :with => '2001' }
			within('span.month') { fill_in "month", :with => '4' }
			within('span.day') { fill_in "day", :with => '23' }
			within('div.title') { fill_in "title", :with => "tDiaryのテスト" }
			within('div.textarea') {
				fill_in "body", :with => <<-BODY
!さて、テストである。
とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P
BODY
			}
		}

		click_button "追記"
		page.should have_content "Click here!"

		visit '/index.rb?date=20010423'
		within('div.day span.title'){ page.should have_content "tDiaryのテスト" }
		within('div.day div.section'){
			within('h3') { page.should have_content "さて、テストである。" }
			page.should have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
		}
	end

	scenario '今日の日記を追記する' do
		visit '/update.rb'
		within('div.day div.form') {
			within('div.title') { fill_in "title", :with => "tDiaryのテスト" }
			within('div.textarea') {
				fill_in "body", :with => <<-BODY
!さて、テストである。
とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P
BODY
			}
		}
		click_button "追記"

		visit '/update.rb'
		within('div.day div.form') {
			within('div.title') { fill_in "title", :with => "Hikiのテスト" }
			within('div.textarea') {
				fill_in "body", :with => <<-BODY
!さて、Hikiのテストである。
とみせかけてtDiary:-)
BODY
			}
		}
		click_button "追記"

		visit '/'
		within('div.day span.title'){ page.should have_content "Hikiのテスト" }
		within('div.day div.section'){
			within('h3') { page.should have_content "さて、テストである。" }
			page.should have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"

			within('h3') { page.should have_content "さて、Hikiのテストである。" }
			page.should have_content "とみせかけてtDiary:-)"
		}
	end

	scenario '日記のプレビュー' do
		visit '/update.rb'
		within('div.day div.form') {
			within('div.title') { fill_in "title", :with => "tDiaryのテスト" }
			within('div.textarea') {
				fill_in "body", :with => <<-BODY
!さて、テストである。
とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P
BODY
			}
		}

		click 'プレビュー'

		within('div.day span.title'){ page.should have_content "tDiaryのテスト" }
		within('div.day div.section'){
			within('h3') { page.should have_content "さて、テストである。" }
			page.should have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
		}
	end
end
