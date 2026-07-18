require 'acceptance_helper'

feature 'ツッコミ後のcookie' do
	# The comment is posted via /index.rb, not via the form on /. With the
	# form the tdiary cookie is issued with "path=./" (derived from the empty
	# SCRIPT_NAME); browsers fall back to the default-path and restore it,
	# but the strict rack-test cookie jar drops such a cookie.
	scenario '次回のコメントフォームにnameとmailが補完される', :exclude_selenium do
		append_default_diary
		today = Date.today.strftime('%Y%m%d')

		page.driver.post '/index.rb', {
			'date' => today,
			'name' => 'アリス',
			'mail' => 'alice@example.com',
			'body' => 'こんにちは!こんにちは!',
			'comment' => 'comment'
		}
		expect(page).to have_content "Click here!"

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
