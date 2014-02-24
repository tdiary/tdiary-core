# -*- coding: utf-8 -*-
require 'acceptance_helper'

feature 'カテゴリ機能の動作' do
	scenario 'カテゴリ機能が動く' do
		enable_plugin('category')

		visit '/'
		click_link '追記'

		within('span.year') { fill_in "year", with: '2001' }
		within('span.month') { fill_in "month", with: '4' }
		within('span.day') { fill_in "day", with: '23' }
		within('div.textarea') {
			fill_in "body", with: <<-BODY
![category] さて、テストである。
とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P

![tdiary] もう一度テストである。
本当に動くかな?
BODY
		}

		click_button "追記"

		visit '/'
		page.find('a', text: "category").click
		expect(page).to have_content 'Categories'
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
