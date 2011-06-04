# -*- coding: utf-8 -*-

module HelperMethods
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
	end

	def append_default_comment
		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => <<-BODY
こんにちは!こんにちは!
BODY
		click_button '投稿'
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
