# -*- coding: utf-8 -*-
module HelperMethods
	def setup_tdiary
		fixture_conf = File.expand_path("../../fixtures/just_installed/tdiary.conf", File.dirname(__FILE__))
		work_data_dir = File.expand_path("../../../data", File.dirname(__FILE__))
		FileUtils.rm_r work_data_dir if FileTest.exist? work_data_dir

		FileUtils.mkdir work_data_dir
		FileUtils.cp_r fixture_conf, work_data_dir, :verbose => false unless fixture_conf.empty?
	end

	def append_default_diary
		visit '/'

		click '追記'
		fill_in "title", :with => "tDiaryのテスト"
		fill_in "body", :with => <<-BODY
!さて、テストである。
とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P
BODY
		click_button "追記"
		page.should have_content "Click here!"
	end

	def append_default_comment
		visit "/"
		click 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
こんにちは!こんにちは!
BODY
		click_button '投稿'
		page.should have_content "Click here!"
	end
end

Spec::Runner.configuration.include(HelperMethods)
