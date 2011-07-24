# -*- coding: utf-8 -*-

module HelperMethods
	def append_default_diary(ymd = Date.today.to_s)
		y, m, d = Date.parse(ymd).to_s.split('-').map {|t| t.sub(/^0+/, "") }
		visit '/update.rb'
		fill_in "year", :with => y
		fill_in "month", :with => m
		fill_in "day", :with => d
		fill_in "title", :with => "tDiaryのテスト"
		fill_in "body", :with => <<-BODY
!さて、テストである。
とりあえず自前の環境ではちゃんと動いているが、きっと穴がいっぱいあるに違いない:-P
BODY
		click_button "追記"
	end

	def append_default_comment
		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", :with => "alpha"
		fill_in "body", :with => 'こんにちは!こんにちは!'
		click_button '投稿'
	end

  def toggle_plugin(name)
	visit '/update.rb?conf=sp'
	check "sp.#{name}.rb"
	click_button 'OK'
  end
end

RSpec.configuration.include(HelperMethods)

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
