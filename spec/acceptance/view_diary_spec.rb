# -*- coding: utf-8 -*-
require 'acceptance_helper'

feature '日記を読む' do
	scenario '最新の日記の表示' do
		visit '/'
		# capybara-2.0 can't find header content.
		# within('title') { page.should have_content('【日記のタイトル】') }
		within('h1') { page.should have_content('【日記のタイトル】') }
		page.should have_css('a[href="update.rb"]')
		page.should have_css('a[href="update.rb?conf=default"]')
	end

	scenario '月またぎの日記の表示' do
		append_default_diary('20100430')
		append_default_diary('20100501')

		before_day = '2010年04月30日'
		after_day = '2010年05月01日'

		visit '/'
		page.find('h2', text: before_day).click_link "#{before_day}"
		within('div.adminmenu'){ page.should have_content "次の日記(#{after_day})"}

		click_link "次の日記(#{after_day})"
		within('div.day') { page.should have_content "#{after_day}" }
		within('div.adminmenu'){ page.should have_content "前の日記(#{before_day})"}

		click_link "前の日記(#{before_day})"
		within('div.day') { page.should have_content "#{before_day}" }
	end

	scenario 'n日前の日記をまとめて表示' do
		1.upto(11) {|i| append_default_diary("201005%02d" % i) }

		visit '/'
		within('div.main') {
			page.should have_content "#{Date.parse('20100502').strftime('%Y年%m月%d日')}"
			page.should have_content "#{Date.parse('20100511').strftime('%Y年%m月%d日')}"
			page.should have_no_content "#{Date.parse('20100501').strftime('%Y年%m月%d日')}"
		}

		click_link "前10日分"
		within('div.main') {
			page.should have_no_content "#{Date.parse('20100502').strftime('%Y年%m月%d日')}"
			page.should have_no_content "#{Date.parse('20100511').strftime('%Y年%m月%d日')}"
			page.should have_content "#{Date.parse('20100501').strftime('%Y年%m月%d日')}"
		}
	end

	scenario 'n年日記機能を表示' do
		append_default_diary('20010423')
		append_default_diary('20020423')
		append_default_diary('20030423')

		visit '/'
		page.find('h2', text: "2001年04月23日").click_link '2001年04月23日'
		click_link '長年日記'

		titles = page.all('h2 span.date a').map{|t| t.text }
		titles.should include '2001年04月23日'
		titles.should include '2002年04月23日'
		titles.should include '2003年04月23日'
	end

	scenario '指定をした日を表示' do
		append_default_diary('2001-04-23')

		visit '/?date=20010423'
		within('div.day span.title'){ page.should have_content "tDiaryのテスト" }
		within('div.day div.section'){
			within('h3') { page.should have_content "さて、テストである。" }
			page.should have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
		}
	end

	scenario '1ヶ月を表示' do
		append_default_diary('20010101')

		visit '/'
		click_link '追記'
		within('span.year') { fill_in "year", with: 2001 }
		within('span.month') { fill_in "month", with: 01 }
		within('span.day') { fill_in "day", with: 31 }
		within('div.title') { fill_in "title", with: "tDiaryのテスト" }
		within('div.textarea') {
			fill_in "body", with: <<-BODY
!さて、月末である。
今月も終わる
BODY
		}
		click_button "追記"

		visit '/'
		click_link '追記'
		within('span.year') { fill_in "year", with: 2001 }
		within('span.month') { fill_in "month", with: 02 }
		within('span.day') { fill_in "day", with: 01 }
		within('div.title') { fill_in "title", with: "tDiaryのテスト" }
		within('div.textarea') {
			fill_in "body", with: <<-BODY
!さて、月始めである。
今月も始まる
BODY
		}
		click_button "追記"

		visit '/?date=200101'
		within('div.main'){
			page.should have_content "さて、テストである。"
			page.should have_content "さて、月末である。"
			page.should have_no_content "さて、月始めである。"
			page.should have_content "とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P"
			page.should have_content "今月も終わる"
			page.should have_no_content "今月も始まる"
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
