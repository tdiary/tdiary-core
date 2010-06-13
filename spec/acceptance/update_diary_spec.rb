# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature '日記の更新' do
	background do
		setup_tdiary
	end

	scenario '特定の日記の内容を更新する' do
		visit '/'
		click '追記'
		within('div.day div.form') {
			within('span.year') { fill_in "year", :with => '2001' }
			within('span.month') { fill_in "month", :with => '4' }
			within('span.day') { fill_in "day", :with => '23' }
			within('div.title') { fill_in "title", :with => "tDiaryのテスト" }
			within('div.textarea') {
				fill_in "body", :with => <<-BODY
!さて、テストである。
とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P

!もう一度テストである。
本当に動くかな?
BODY
			}
		}

		click_button "追記"
		page.should have_content "Click here!"

		visit '/'
		click "#{Date.parse('20010423').strftime('%Y年%m月%d日')}"
		within('div.day span.title'){ page.should have_content "tDiaryのテスト" }
		within('div.day div.section'){
			within('h3') {
				page.should have_content "さて、テストである。"
				page.should have_content "もう一度テストである。"
			}
			page.should have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
			page.should have_content "本当に動くかな?"
		}

		click '編集'
		within('div.day div.form') {
			within('div.textarea') {
				fill_in "body", :with => <<-BODY
!もう一度テストである。
本当に動くかな?
BODY
			}
		}

		click_button "登録"
		page.should have_content "Click here!"

		visit '/'
		click "#{Date.parse('20010423').strftime('%Y年%m月%d日')}"
		within('div.day span.title'){ page.should have_content "tDiaryのテスト" }
		within('div.day div.section'){
			within('h3') {
				page.should have_no_content "さて、テストである。"
				page.should have_content "もう一度テストである。"
			}
			page.should have_no_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
			page.should have_content "本当に動くかな?"
		}
	end

	scenario '日記の削除' do
		append_default_diary
		visit '/'
		click "#{Date.today.strftime('%Y年%m月%d日')}"
		click '編集'

		within('div.day div.form') {
			within('div.textarea') { fill_in "body", :with => '' }
		}

		click_button "登録"
		page.should have_content "Click here!"

		visit '/'
		within('div.day') { page.should have_no_css('h3') }
	end

	scenario '日記を隠す' do
		append_default_diary
		visit '/'
		click "#{Date.today.strftime('%Y年%m月%d日')}"
		click '編集'
		check 'hide'

		click_button "登録"
		page.should have_content "Click here!"

		visit '/'
		page.should have_no_css('div[class="day"]')
	end
end
