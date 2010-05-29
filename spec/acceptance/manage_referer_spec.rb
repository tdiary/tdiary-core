# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature 'リンク元の管理' do
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

	scenario '更新画面にリンク元が表示されている' do
		append_default_diary

		visit "/"
		click "#{Date.today.strftime('%Y年%m月%d日')}"
		within('div.day div.refererlist') { page.should have_link "http://www.example.com" }
	end

	scenario 'リンク元記録の除外設定が動いている' do
		append_default_diary

		visit '/update.rb?conf=referer'
		fill_in 'no_referer', :with => '^http://www\.example\.com/.*'
		click_button('OK')

		click '最新'
		click "#{Date.today.strftime('%Y年%m月%d日')}"
		within('div.day div.refererlist') { page.should have_no_link('http://www.example.com') }
	end

	scenario 'リンク元記録の除外に設定していないリファラは記録されている' do
		pending 'リファラを切り替えて記録する方法がわからない'
		append_default_diary

		visit '/update.rb?conf=referer'
		fill_in 'no_referer', :with => '^http://www\.example\.com/.*$'
		click_button('OK')

		page.driver.request.env['HTTP_REFERER'] = 'http://www.hsbt.org/'
		click '最新'
		click "#{Date.today.strftime('%Y年%m月%d日')}"
		within('div.day div.refererlist') { page.should have_link "http://www.hsbt.org/" }
	end

	scenario 'リンク元の置換が動いている' do
		append_default_diary

		visit '/update.rb?conf=referer'
		fill_in 'referer_table', :with => '^http://www\.example\.com/.* alice'
		click_button('OK')

		click '最新'
		click "#{Date.today.strftime('%Y年%m月%d日')}"
		within('div.day div.refererlist') {
			page.should have_link "alice"
			page.should have_no_link "http://www.example.com"
		}
	end
end
