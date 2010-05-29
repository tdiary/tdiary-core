# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature '設定画面の利用' do
	background do
		setup_tdiary
	end

	scenario do
		visit '/update.rb?conf=default'

		fill_in "author_name", :with => "ただただし"
		fill_in "html_title", :with => "ただの日記"
		fill_in "author_mail", :with => "t@tdtds.jp"
		fill_in "index_page", :with => "http://www.example.com"
		fill_in "description", :with => "ただただしによる日々の記録"
		fill_in "icon", :with => "http://tdtds.jp/favicon.png"
		fill_in "banner", :with => "http://sho.tdiary.net/images/banner.png"

		click_button "OK"

		within('title') { page.should have_content('(設定完了)') }
		within('h1') { page.should have_content('(設定)') }

		visit '/'

		within('title') { page.should have_content('ただの日記') }
	end
end
