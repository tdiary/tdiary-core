# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature '日記を読む' do
	background do
		setup_tdiary
	end

	scenario do
		visit '/'
		within('title') { page.should have_content('【日記のタイトル】') }
		within('h1') { page.should have_content('【日記のタイトル】') }
		page.should have_css('a[href="update.rb"]')
		page.should have_css('a[href="update.rb?conf=default"]')
	end
end
