require 'acceptance_helper'

feature 'spamフィルタ設定の利用' do
	scenario '新入荷のプラグインが表示される' do
		visit '/update.rb?conf=sf'

		page.all('div.saveconf').first.click_button 'OK'
		expect(page).not_to have_content '新入荷'

		FileUtils.cp_r "#{TDiary.root}/spec/fixtures/sample.rb", "#{TDiary.root}/misc/filter/"

		click_link 'スパムフィルター選択'
		expect(page).to have_content '新入荷'
		expect(page).to have_content 'sample.rb'

		FileUtils.rm "#{TDiary.root}/misc/filter/sample.rb"
	end

	scenario 'スパムフィルター選択が保存される' do
		FileUtils.cp_r "#{TDiary.root}/spec/fixtures/sample.rb", "#{TDiary.root}/misc/filter/"

		visit '/update.rb?conf=sf'
		check "sf.sample.rb"
		page.all('div.saveconf').first.click_button 'OK'

		expect(page).to have_checked_field "sf.sample.rb"

		FileUtils.rm "#{TDiary.root}/misc/filter/sample.rb"
	end

	scenario 'プラグインが消えたら表示されない' do
		FileUtils.cp_r "#{TDiary.root}/spec/fixtures/sample.rb", "#{TDiary.root}/misc/filter/"

		visit '/update.rb?conf=sf'
		expect(page).to have_content 'sample.rb'

		FileUtils.rm "#{TDiary.root}/misc/filter/sample.rb"
		click_link 'スパムフィルター選択'
		expect(page).not_to have_content 'sample.rb'
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
