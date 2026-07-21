require 'acceptance_helper'

feature 'ツッコミ後のcookie' do
	scenario '次回のコメントフォームにnameとmailが補完される', :exclude_selenium do
		append_default_diary
		visit '/'
		click_link 'ツッコミを入れる'
		fill_in "name", with: "アリス"
		fill_in "mail", with: "alice@example.com"
		fill_in "body", with: "こんにちは!こんにちは!"
		click_button '投稿'
		expect(page).to have_content "Click here!"

		today = Date.today.strftime('%Y%m%d')
		visit "/?date=#{today}"
		expect(page.find('input[name=name]').value).to eq "アリス"
		expect(page.find('input[name=mail]').value).to eq "alice@example.com"
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
