# -*- coding: utf-8 -*-
require 'acceptance_helper'

feature 'リンク元の表示', :mechanize => true do
	scenario '日表示にリンク元が表示されている' do
		append_default_diary
		visit '/'
		click_link "#{Date.today.strftime("%Y年%m月%d日")}"
		within('div.day') {
			page.should have_css('div[class="refererlist"]')
			within('div.refererlist') { page.should have_content "http://www.example.com" }
		}
	end

	scenario '更新画面にリンク元が表示されている' do
		append_default_diary
		visit "/"
		click_link "#{Date.today.strftime('%Y年%m月%d日')}"
		within('div.day div.refererlist') { page.should have_link "http://www.example.com" }
	end
end
