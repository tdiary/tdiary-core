# coding: utf-8
require 'acceptance_helper'

feature 'プラグイン選択設定の利用' do
	plugin_path = "#{TDiary.root}/misc/plugin/rspec.rb"

	scenario '新入荷のプラグインが表示される' do
		FileUtils.rm plugin_path if File.exist? plugin_path

		visit '/update.rb?conf=sp'
		page.all('div.saveconf').first.click_button 'OK'
		expect(page).not_to have_content '新入荷'

		FileUtils.touch plugin_path

		click_link 'プラグイン選択'

		expect(page).to have_content '新入荷'
		expect(page).to have_content 'rspec.rb'

		FileUtils.rm plugin_path
	end

	scenario 'プラグイン設定を保存する' do
		FileUtils.touch plugin_path

		visit '/update.rb?conf=sp'

		check "sp.rspec.rb"
		page.all('div.saveconf').first.click_button 'OK'

		expect(page).to have_checked_field "sp.rspec.rb"

		FileUtils.rm plugin_path
	end

	scenario 'プラグインが消えたら表示されない' do
		FileUtils.touch plugin_path

		visit '/update.rb?conf=sp'
		expect(page).to have_content 'rspec.rb'

		FileUtils.rm plugin_path

		click_link 'プラグイン選択'
		expect(page).not_to have_content 'rspec.rb'
	end

	scenario '外部の Javascript を追加するプラグインを有効にする' do
		visit '/update.rb?conf=sp'

		check "sp.category_autocomplete.rb"
		page.all('div.saveconf').first.click_button 'OK'

		visit '/update.rb'

		expect(page.body).to be_include('caretposition.js')
		expect(page.body).to be_include('category_autocomplete.js')
		expect(page.body).to be_include('//ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js')
		expect(page.body).not_to be_include('//ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js?')
	end
end
# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
