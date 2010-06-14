# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature '日記を読む' do
	background do
		setup_tdiary
	end

	scenario '最新の日記の表示' do
		visit '/'
		within('title') { page.should have_content('【日記のタイトル】') }
		within('h1') { page.should have_content('【日記のタイトル】') }
		page.should have_css('a[href="update.rb"]')
		page.should have_css('a[href="update.rb?conf=default"]')
	end

	scenario '月またぎの日記の表示' do
		append_default_diary('20100430')
		append_default_diary('20100501')

		visit '/'
		click "#{Date.parse('20100430').strftime('%Y年%m月%d日')}"
		within('span.adminmenu'){ page.should have_content "次の日記(#{Date.parse('20100430').strftime('%Y年%m月%d日')}})"}

		click "次の日記(#{Date.parse('20100501').strftime('%Y年%m月%d日')})"
		within('div.day') { page.should have_content "#{Date.parse('20100501').strftime('%Y年%m月%d日')}" }

	end

	scenario 'n日前の日記をまとめて表示' do
		append_default_diary('20100501')
		append_default_diary('20100502')
		append_default_diary('20100503')
		append_default_diary('20100504')

		visit '/'
		
		
	end

	scenario 'n年日記機能を表示'

	scenario '指定をした日を表示'

	scenario '1年を表示'

	scenario '1ヶ月を表示'
end
