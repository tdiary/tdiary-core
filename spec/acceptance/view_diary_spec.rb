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

	scenario '月またぎの日記の表示'

	scenario 'n日前の日記をまとめて表示'

	scenario 'n年日記機能を表示'

	scenario '指定をした日を表示'

	scenario '1年を表示'

	scenario '1ヶ月を表示'
end
