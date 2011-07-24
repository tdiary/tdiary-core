# -*- coding: utf-8 -*-
require 'acceptance_helper'

feature 'リンク元設定の利用', :mechanize => true do
	scenario 'リンク元の非表示設定' do
		append_default_diary
		visit '/update.rb?conf=referer'
		select('非表示', :from => 'show_referer')

		click_button "OK"
		within('title') { page.should have_content('(設定完了)') }

		click_link '最新'
		click_link "#{Date.today.strftime("%Y年%m月%d日")}"
		within('div.day') { page.should have_no_css('div[class="refererlist"]') }
	end

	scenario 'リンク元記録の除外設定が動いている' do
		append_default_diary
		visit '/update.rb?conf=referer'
		fill_in 'no_referer', :with => '^http://www\.example\.com/.*'

		click_button('OK')
		within('title') { page.should have_content('(設定完了)') }

		click_link '最新'
		click_link "#{Date.today.strftime('%Y年%m月%d日')}"
		within('div.day div.refererlist') { page.should have_no_link('http://www.example.com') }
	end

	pending 'リンク元記録の除外に設定していないリファラは記録されている' do
		append_default_diary
		visit '/update.rb?conf=referer'
		fill_in 'no_referer', :with => '^http://www\.example\.com/.*$'

		click_button('OK')
		within('title') { page.should have_content('(設定完了)') }

		page.driver.request.env['HTTP_REFERER'] = 'http://www.hsbt.org/'
		click_link '最新'
		click_link "#{Date.today.strftime('%Y年%m月%d日')}"
		within('div.day div.refererlist') { page.should have_link "http://www.hsbt.org/" }
	end

	scenario 'リンク元の置換が動いている' do
		append_default_diary
		visit '/update.rb?conf=referer'
		fill_in 'referer_table', :with => <<-REFERER
^http://www\.example\.com/.* alice
^http://www\.example\.net/.* bob
REFERER

		click_button('OK')
		within('title') { page.should have_content('(設定完了)') }

		click_link '最新'
		click_link "#{Date.today.strftime('%Y年%m月%d日')}"
		within('div.day div.refererlist') {
			page.should have_link "alice"
			page.should have_no_link "http://www.example.com"
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
