# coding: utf-8
require 'acceptance_helper'

feature 'プラグイン選択設定の利用' do
	plugin_path = "#{TDiary::PATH}/misc/plugin/rspec.rb"
	scenario '新入荷のプラグインが表示される' do
		FileUtils.rm plugin_path if File.exists? plugin_path

		visit '/update.rb?conf=sp'
		click_button 'OK'
		page.should_not have_content '新入荷'

		FileUtils.touch plugin_path

		click_link 'プラグイン選択'

		page.should have_content '新入荷'
		page.should have_content 'rspec.rb'

		FileUtils.rm plugin_path
	end

	scenario 'プラグイン設定を保存する' do
		FileUtils.touch plugin_path

		visit '/update.rb?conf=sp'

		check "sp.rspec.rb"
		click_button 'OK'

		page.should have_checked_field "sp.rspec.rb"

		FileUtils.rm plugin_path
	end

	scenario 'プラグインが消えたら表示されない' do
		FileUtils.touch plugin_path

		visit '/update.rb?conf=sp'
		page.should have_content 'rspec.rb'

		FileUtils.rm plugin_path

		click_link 'プラグイン選択'
		page.should_not have_content 'rspec.rb'
	end

	scenario '外部の Javascript を追加するプラグインを有効にする' do
		visit '/update.rb?conf=sp'

		check "sp.category_autocomplete.rb"
		click_button 'OK'

		visit '/update.rb'

		scripts = page.all(:xpath, '//head//script').map{|s| s[:src]}.join
		scripts.should be_include('caretposition.js')
		scripts.should be_include('category_autocomplete.js')
		scripts.should be_include('http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js')
		scripts.should_not be_include('http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js?')
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
