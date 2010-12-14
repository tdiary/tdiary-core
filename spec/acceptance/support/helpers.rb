# -*- coding: utf-8 -*-

module HelperMethods
	def setup_tdiary
		fixture_conf = File.expand_path("../../fixtures/just_installed.conf", File.dirname(__FILE__))
		work_data_dir = File.expand_path("../../../data", File.dirname(__FILE__))
		FileUtils.rm_r work_data_dir if FileTest.exist? work_data_dir

		FileUtils.mkdir work_data_dir
		FileUtils.cp_r fixture_conf, File.join(work_data_dir, "tdiary.conf"), :verbose => false unless fixture_conf.empty?
	end

	def append_default_diary(ymd = Date.today.to_s)
		y, m, d = Date.parse(ymd).to_s.split('-').map {|t| t.sub(/^0+/, "") }
		visit '/'
		click_link '追記'
		within('div.day div.form') {
			within('span.year') { fill_in "year", :with => y }
			within('span.month') { fill_in "month", :with => m }
			within('span.day') { fill_in "day", :with => d }
			within('div.title') { fill_in "title", :with => "tDiaryのテスト" }
			within('div.textarea') {
				fill_in "body", :with => <<-BODY
!さて、テストである。
とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P
BODY
			}
		}
		click_button "追記"
		page.should have_content "Click here!"
	end

	def append_default_comment
		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
こんにちは!こんにちは!
BODY
		click_button '投稿'
		page.should have_content "Click here!"
	end

  def toggle_plugin(name)
		visit "/"
		click_link '追記'
    click_link '設定'
    click_link 'プラグイン選択'
    check "sp.#{name}.rb"
    click_button 'OK'
  end
end

RSpec.configuration.include(HelperMethods)
