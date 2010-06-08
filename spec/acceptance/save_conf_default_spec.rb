# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature '基本設定の利用' do
	background do
		setup_tdiary
	end

	scenario 'サイトの情報の設定' do
		visit '/'

		click '追記'
		click '設定'

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

		click '最新'

		within('title') { page.should have_content('ただの日記') }
	end

	scenario 'ヘッダ・フッタの設定'

	scenario '表示一版の設定'

	scenario 'ログレベルの選択の設定'

	scenario 'プラグイン選択の設定'

	scenario '時差調整が保存される'

	scenario 'テーマ選択が保存される'

	scenario 'ツッコミが保存される'

	scenario 'リンク元が保存される'
end
