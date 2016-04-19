require 'acceptance_helper'

feature 'ツッコミ設定の利用' do
	scenario 'ツッコミを非表示にできる' do
		append_default_diary
		append_default_comment

		visit '/update.rb?conf=comment'
		select '非表示', from: 'show_comment'

		page.all('div.saveconf').first.click_button "OK"
		# within('title') { page.should have_content('(設定完了)') }

		click_link '最新'
		within('div.day div.comment') {
			expect(page).to have_no_css('div[class="commentshort"]')
			expect(page).to have_no_content "alpha"
			expect(page).to have_no_content "こんにちは!こんにちは!"
		}
	end

	scenario '月表示の時の表示数を変更できる' do
		append_default_diary
		append_default_comment

		visit "/"
		click_link 'ツッコミを入れる'
		fill_in "name", with: "bravo"
		fill_in "body", with: <<-BODY
こんばんは!こんばんは!
BODY

		click_button '投稿'
		expect(page).to have_content "Click here!"

		visit '/update.rb?conf=comment'
		fill_in 'comment_limit', with: '1'

		page.all('div.saveconf').first.click_button "OK"
		# within('title') { page.should have_content('(設定完了)') }

		click_link '最新'
		within('div.day div.comment div.commentshort') {
			expect(page).to have_no_content "alpha"
			expect(page).to have_content "bravo"
			expect(page).to have_no_content "こんにちは!こんにちは!"
			expect(page).to have_content "こんばんは!こんばんは!"
		}

		today = Date.today.strftime('%Y年%m月%d日')
		page.find('h2', text: today).click_link today
		within('div.day div.comment div.commentbody') {
			expect(page).to have_content "alpha"
			expect(page).to have_content "bravo"
			expect(page).to have_content "こんにちは!こんにちは!"
			expect(page).to have_content "こんばんは!こんばんは!"
		}
	end

	scenario '1日あたりの最大数を変更できる' do
		append_default_diary
		append_default_comment

		visit '/update.rb?conf=comment'
		fill_in 'comment_limit_per_day', with: '1'

		page.all('div.saveconf').first.click_button "OK"
		# within('title') { page.should have_content('(設定完了)') }

		click_link '最新'
		today = Date.today.strftime('%Y年%m月%d日')
		page.find('h2', text: today).click_link today
		within('div#comment-form-section') {
			within('div.caption') { expect(page).to have_content('本日の日記はツッコミ数の制限を越えています。') }
			expect(page).to have_no_css('form')
		}
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
