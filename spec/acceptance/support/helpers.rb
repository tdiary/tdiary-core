# -*- coding: utf-8 -*-

module HelperMethods
	def append_default_diary(ymd = Date.today.to_s)
		date = Date.parse(ymd)
		visit '/update.rb'
		fill_in "year", :with => date.year
		fill_in "month", :with => date.month
		fill_in "day", :with => date.day
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

	def enable_plugin(name)
		visit '/update.rb?conf=sp'
		check "sp.#{name}.rb"
		click_button 'OK'
	end

	def disable_plugin(name)
		visit '/update.rb?conf=sp'
		uncheck "sp.#{name}.rb"
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
