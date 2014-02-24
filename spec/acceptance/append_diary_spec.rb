# -*- coding: utf-8 -*-
require 'acceptance_helper'

feature '日記の追記' do
	scenario '更新画面のデフォルト表示' do
		visit '/'
		click_link '追記'
		expect(page).to have_content('日記の更新')

		y, m, d = Date.today.to_s.split('-').map {|t| t.sub(/^0+/, "") }
		within('span.year') { expect(page).to have_field('year', with: y) }
		within('span.month') { expect(page).to have_field('month', with: m) }
		within('span.day') { expect(page).to have_field('day', with: d) }
	end

	scenario '今日の日記を書く' do
		append_default_diary

		visit '/'
		within('div.day span.title'){ expect(page).to have_content "tDiaryのテスト" }
		within('div.day div.section'){
			within('h3') { expect(page).to have_content "さて、テストである。" }
			expect(page).to have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
		}
		today = Date.today.strftime('%Y年%m月%d日')
		page.find('h2', text: today).click_link today
		within('div.day span.title'){ expect(page).to have_content "tDiaryのテスト" }
		within('div.day div.section'){
			within('h3') { expect(page).to have_content "さて、テストである。" }
			expect(page).to have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
		}
	end

	scenario '日付を指定して新しく日記を書く' do
		append_default_diary('2001-04-23')

		visit '/'
		page.find('h2', text: '2001年04月23日').click_link '2001年04月23日'
		within('div.day span.title'){ expect(page).to have_content "tDiaryのテスト" }
		within('div.day div.section'){
			within('h3') { expect(page).to have_content "さて、テストである。" }
			expect(page).to have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
		}
	end

	scenario '今日の日記を追記する' do
		append_default_diary

		visit '/'
		click_link '追記'
		within('div.title') { fill_in "title", with: "Hikiのテスト" }
		within('div.textarea') {
			fill_in "body", with: <<-BODY
!さて、Hikiのテストである。
とみせかけてtDiary:-)
BODY
		}

		click_button "追記"
		expect(page).to have_content "Click here!"

		visit '/'
		within('div.day span.title'){ expect(page).to have_content "Hikiのテスト" }
		within('div.body'){
			expect(page).to have_content "さて、テストである。"
			expect(page).to have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
			expect(page).to have_content "さて、Hikiのテストである。"
			expect(page).to have_content "とみせかけてtDiary:-)"
		}
	end

	scenario '日記のプレビュー' do
		visit '/'
		click_link '追記'
		within('div.title') { fill_in "title", with: "tDiaryのテスト" }
		within('div.textarea') {
			fill_in "body", with: <<-BODY
!さて、テストである。
とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P
BODY
		}

		click_button 'プレビュー'
		expect(page).to have_content "tDiaryのテスト"
		within('div.day div.section'){
			within('h3') { expect(page).to have_content "さて、テストである。" }
			expect(page).to have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
		}
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
