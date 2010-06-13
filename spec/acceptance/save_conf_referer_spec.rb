# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature 'リンク元の管理' do
	background do
		setup_tdiary
	end

	scenario 'リンク元の非表示設定' do
		append_default_diary
		visit '/'
		click '追記'
		click '設定'
		click 'リンク元'
		select('非表示', :from => 'show_referer')

		click_button "OK"
		within('title') { page.should have_content('(設定完了)') }

		click '最新'
		click "#{Date.today.strftime("%Y年%m月%d日")}"
		within('div.day') { page.should have_no_css('div[class="refererlist"]') }
	end

	scenario 'リンク元記録の除外設定が動いている' do
		append_default_diary
		visit '/'
		click '追記'
		click '設定'
		click 'リンク元'
		fill_in 'no_referer', :with => '^http://www\.example\.com/.*'

		click_button('OK')
		within('title') { page.should have_content('(設定完了)') }

		click '最新'
		click "#{Date.today.strftime('%Y年%m月%d日')}"
		within('div.day div.refererlist') { page.should have_no_link('http://www.example.com') }
	end

	scenario 'リンク元記録の除外に設定していないリファラは記録されている' do
		pending 'リファラを切り替えて記録する方法がわからない'

		append_default_diary
		visit '/'
		click '追記'
		click '設定'
		click 'リンク元'
		fill_in 'no_referer', :with => '^http://www\.example\.com/.*$'

		click_button('OK')
		within('title') { page.should have_content('(設定完了)') }

		page.driver.request.env['HTTP_REFERER'] = 'http://www.hsbt.org/'
		click '最新'
		click "#{Date.today.strftime('%Y年%m月%d日')}"
		within('div.day div.refererlist') { page.should have_link "http://www.hsbt.org/" }
	end

	scenario 'リンク元の置換が動いている' do
		append_default_diary
		visit '/'
		click '追記'
		click '設定'
		click 'リンク元'
		fill_in 'referer_table', :with => '^http://www\.example\.com/.* alice'

		click_button('OK')
		within('title') { page.should have_content('(設定完了)') }

		click '最新'
		click "#{Date.today.strftime('%Y年%m月%d日')}"
		within('div.day div.refererlist') {
			page.should have_link "alice"
			page.should have_no_link "http://www.example.com"
		}
	end
end
