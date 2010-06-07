# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature '日記の更新' do
	background do
		setup_tdiary
	end

	scenario '特定の日記の内容を更新する'

	scenario '日記の削除' do
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

		visit '/index.rb?date=20010423'
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

		visit '/index.rb?date=20010423'
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

	scenario '日記を隠す'
end
