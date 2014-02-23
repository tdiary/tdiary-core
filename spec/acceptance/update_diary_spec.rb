# -*- coding: utf-8 -*-
require 'acceptance_helper'

feature '日記の更新' do
	scenario '特定の日記の内容を更新する' do
		visit '/update.rb'
		fill_in "year", with: '2001'
		fill_in "month", with: '4'
		fill_in "day", with: '23'
		fill_in "title", with: "tDiaryのテスト"
		fill_in "body", with: <<-BODY
!さて、テストである。
とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P

!もう一度テストである。
本当に動くかな?
BODY

		click_button "追記"

		visit '/'
		page.find('h2', text: '2001年04月23日').click_link '2001年04月23日'
		within('div.day span.title'){ expect(page).to have_content "tDiaryのテスト" }
		within('div.body'){
			expect(page).to have_content "さて、テストである。"
			expect(page).to have_content "もう一度テストである。"

			expect(page).to have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
			expect(page).to have_content "本当に動くかな?"
		}

		visit '/update.rb'
		fill_in "year", with: '2001'
		fill_in "month", with: '4'
		fill_in "day", with: '23'
		click_button 'この日付の日記を編集'

		fill_in "body", with: <<-BODY
!もう一度テストである。
本当に動くかな?
BODY

		click_button "登録"

		visit '/'
		page.find('h2', text: '2001年04月23日').click_link '2001年04月23日'
		within('div.day span.title'){ expect(page).to have_content "tDiaryのテスト" }
		within('div.body'){
			expect(page).to have_no_content "さて、テストである。"
			expect(page).to have_content "もう一度テストである。"

			expect(page).to have_no_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
			expect(page).to have_content "本当に動くかな?"
		}
	end

	scenario '日記の削除' do
		append_default_diary

		visit '/update.rb'
		fill_in "year", with: Date.today.year
		fill_in "month", with: Date.today.month
		fill_in "day", with: Date.today.day
		click_button 'この日付の日記を編集'

		within('div.textarea') { fill_in "body", with: '' }

		click_button "登録"
		expect(page).to have_content "Click here!"

		visit '/'
		within('div.day') { expect(page).to have_no_css('h3') }
	end

	scenario '日記を隠す' do
		append_default_diary

		visit '/update.rb'
		fill_in "year", with: Date.today.year
		fill_in "month", with: Date.today.month
		fill_in "day", with: Date.today.day
		click_button 'この日付の日記を編集'
		check 'hide'

		click_button "登録"
		expect(page).to have_content "Click here!"

		visit '/'
		expect(page).to have_no_css('div[class="day"]')
	end

	scenario '編集画面に前の日記と次の日記のリンク表示される' do
		append_default_diary('20010502')
		append_default_diary('20010503')
		append_default_diary('20010504')

		visit '/update.rb'
		fill_in "year", with: '2001'
		fill_in "month", with: '5'
		fill_in "day", with: '3'
		click_button 'この日付の日記を編集'

		expect(page).to have_content('«前の日記(2001年05月02日)')
		expect(page).to have_content('次の日記(2001年05月04日)»')
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
