# coding: utf-8
require 'acceptance_helper'

feature 'プラグイン選択設定の利用' do
	scenario '新入荷のプラグインが表示される' do
    visit '/'
    click_link '追記'
    click_link '設定'
    click_link 'プラグイン選択'
    click_button 'OK'

    page.should_not have_content '新入荷'

    FileUtils.touch "#{TDiary::PATH}/misc/plugin/rspec.rb"

    click_link 'プラグイン選択'

    page.should have_content '新入荷'
    page.should have_content 'rspec.rb'

    FileUtils.rm "#{TDiary::PATH}/misc/plugin/rspec.rb"
  end

	scenario 'プラグイン設定を保存する' do
    FileUtils.touch "#{TDiary::PATH}/misc/plugin/rspec.rb"

    visit '/'
    click_link '追記'
    click_link '設定'
    click_link 'プラグイン選択'
    check "sp.rspec.rb"
    click_button 'OK'

    click_link 'プラグイン選択'

    page.should have_checked_field "sp.rspec.rb"

    FileUtils.rm "#{TDiary::PATH}/misc/plugin/rspec.rb"
  end

	scenario 'プラグインが消えたら表示されない' do
    FileUtils.touch "#{TDiary::PATH}/misc/plugin/rspec.rb"

    visit '/'
    click_link '追記'
    click_link '設定'
    click_link 'プラグイン選択'
    page.should have_content 'rspec.rb'

    FileUtils.rm "#{TDiary::PATH}/misc/plugin/rspec.rb"

    click_link 'プラグイン選択'
    page.should_not have_content 'rspec.rb'
  end
end
