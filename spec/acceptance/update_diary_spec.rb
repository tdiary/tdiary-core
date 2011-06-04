# -*- coding: utf-8 -*-
require 'acceptance_helper'

feature '日記の更新' do
	scenario '特定の日記の内容を更新する' do
		visit '/'
		click_link '追記'
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
		click_link "#{Date.parse('20010423').strftime('%Y年%m月%d日')}"
		within('div.day span.title'){ page.should have_content "tDiaryのテスト" }
		within('div.body'){
			page.should have_content "さて、テストである。"
			page.should have_content "もう一度テストである。"

			page.should have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
			page.should have_content "本当に動くかな?"
		}

		click_link '編集'
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
		click_link "#{Date.parse('20010423').strftime('%Y年%m月%d日')}"
		within('div.day span.title'){ page.should have_content "tDiaryのテスト" }
		within('div.body'){
			page.should have_no_content "さて、テストである。"
			page.should have_content "もう一度テストである。"

			page.should have_no_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
			page.should have_content "本当に動くかな?"
		}
	end

	scenario '日記の削除' do
		append_default_diary
		visit '/'
		click_link "#{Date.today.strftime('%Y年%m月%d日')}"
		click_link '編集'

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
		click_link "#{Date.today.strftime('%Y年%m月%d日')}"
		click_link '編集'
		check 'hide'

		click_button "登録"
		page.should have_content "Click here!"

		visit '/'
		page.should have_no_css('div[class="day"]')
	end

	scenario '編集画面に前の日記と次の日記のリンク表示される' do
		append_default_diary('20010502')
		append_default_diary('20010503')
		append_default_diary('20010504')

		visit '/'
		click_link "#{Date.parse('20010503').strftime('%Y年%m月%d日')}"
		click_link '編集'

		page.should have_content('«前の日記(2001年05月02日)')
		page.should have_content('次の日記(2001年05月04日)»')
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
