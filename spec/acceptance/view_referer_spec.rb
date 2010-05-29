# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature 'リンク元の表示' do
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

	scenario '日表示にリンク元が表示されている' do
		append_default_diary

		visit '/'

		visit "/?date=#{Date.today.strftime("%Y%m%d")}"
		within('div.day') {
			page.should have_css('div[class="refererlist"]')
			within('div.refererlist') { page.should have_content "http://www.example.com" }
		}
	end

	scenario 'リンク元の非表示設定' do
		append_default_diary

		visit '/update.rb?conf=referer'
		select('非表示', :from => 'show_referer')
		click_button('OK')

		visit '/'

		within('div.day') {
			visit "/?date=#{Date.today.strftime("%Y%m%d")}"
			page.should have_no_css('div[class="refererlist"]')
		}
	end
end
