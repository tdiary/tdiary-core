require 'acceptance_helper'

feature '基本設定の利用' do
	scenario 'サイトの情報の設定' do
		visit '/update.rb?conf=default'
		fill_in "author_name", with: "ただただし"
		fill_in "html_title", with: "ただの日記"
		fill_in "author_mail", with: "t@tdtds.jp"
		fill_in "index_page", with: "http://www.example.com"
		fill_in "description", with: "ただただしによる日々の記録"
		fill_in "icon", with: "http://tdtds.jp/favicon.png"
		# TODO banner の値が fill_in されない
		#fill_in "banner", with: "http://sho.tdiary.net/images/banner.png"
		# TODO x_frame_open の設定

		page.all('div.saveconf').first.click_button "OK"
		# within('title') { page.should have_content('(設定完了)') }

		click_link '最新'
		# TODO その他の項目の反映を確認
		# within('title') { page.should have_content('ただの日記') }

		visit '/update.rb?conf=default'
		expect(page).to have_field "author_name", with: "ただただし"
		expect(page).to have_field "html_title", with: "ただの日記"
		expect(page).to have_field "author_mail", with: "t@tdtds.jp"
		expect(page).to have_field "index_page", with: "http://www.example.com"
		expect(page).to have_field "description", with: "ただただしによる日々の記録"
		expect(page).to have_field "icon", with: "http://tdtds.jp/favicon.png"
		# TODO banner の値が fill_in されない
		# page.should have_field("banner", with: "http://sho.tdiary.net/images/banner.png")
	end

	scenario 'ヘッダ・フッタの設定' do
		visit '/update.rb?conf=header'
		fill_in "header", with: <<-HEADER
<%= navi %>
<h1>alpha</h1>
<div class="main">
HEADER
		fill_in "footer", with: <<-FOOTER
</div>
<div class="sidebar">
bravo
</div>
FOOTER
		page.all('div.saveconf').first.click_button "OK"
		#within('title') { page.should have_content('(設定完了)') }

		click_link '最新'
		within('h1') { expect(page).to have_content('alpha') }
		within('div.sidebar') { expect(page).to have_content('bravo')}

		visit '/update.rb?conf=header'
		expect(page).to have_field "header", with: <<-HEADER
<%= navi %>
<h1>alpha</h1>
<div class="main">
HEADER
		expect(page).to have_field "footer", with: <<-FOOTER
</div>
<div class="sidebar">
bravo
</div>
FOOTER
	end

	scenario '表示一版の設定' do
		today = Date.today
		yestarday = Date.today - 1

		append_default_diary(today.to_s)
		append_default_diary(yestarday.to_s)
		append_default_comment

		visit '/update.rb?conf=display'
		fill_in 'section_anchor', with: '<span class="sanchor">★</span>'
		fill_in 'comment_anchor', with: '<span class="canchor">●</span>'
		fill_in 'date_format', with: '%Y:%m:%d'
		fill_in 'latest_limit', with: 1
		select '非表示', from: 'show_nyear'

		page.all('div.saveconf').first.click_button "OK"
		# within('title') { page.should have_content('(設定完了)') }

		click_link '最新'
		expect(page).to have_content('★')
		expect(page).to have_content('●')
		titles = page.all('h2 span.date a').map(&:text)
		expect(titles).to include("#{today.year}:#{'%02d' % today.month}:#{'%02d' % today.day}")
		expect(titles).not_to include("#{yestarday.year}:#{'%02d' % yestarday.month}:#{'%02d' % yestarday.day}")
		expect(page).not_to have_content("長年日記")
	end

	scenario 'ログレベルの選択の設定' do
		visit '/update.rb?conf=logger'
		select 'DEBUG', from: 'log_level'

		page.all('div.saveconf').first.click_button "OK"
		# within('title') { page.should have_content('(設定完了)') }

		click_link '最新'
		# TODO ログレベルの確認

		visit '/update.rb?conf=logger'
		within('select option[selected]'){ expect(page).to have_content 'DEBUG' }
	end

	scenario '時差調整が保存される' do
		visit '/update.rb?conf=timezone'
		fill_in 'hour_offset', with: '-24'

		page.all('div.saveconf').first.click_button "OK"
		# within('title') { page.should have_content('(設定完了)') }

		click_link '追記'
		y, m, d = (Date.today - 1).to_s.split('-').map {|t| t.sub(/^0+/, "") }
		within('span.year') { expect(page).to have_field('year', with: y) }
		within('span.month') { expect(page).to have_field('month', with: m) }
		within('span.day') { expect(page).to have_field('day', with: d) }

		click_link '設定'
		click_link '時差調整'
		expect(page).to have_field('hour_offset', with: '-24.0')
	end

	scenario 'Rack 環境でテーマ選択が保存される', :exclude_selenium do
		visit '/update.rb?conf=theme'
		select 'Tdiary1', from: 'theme'

		page.all('div.saveconf').first.click_button "OK"

		click_link '最新'
		expect(page.body).to be_include('href="assets/base.css"')
		expect(page.body).to be_include('href="assets/tdiary1/tdiary1.css"')

		visit '/update.rb?conf=theme'
		within('select option[selected]'){
			expect(page).to have_content 'Tdiary1'
		}
	end

	scenario 'Webrick 環境でテーマ選択が保存される', :exclude_rack do
		visit '/update.rb?conf=theme'
		select 'Tdiary1', from: 'theme'

		page.all('div.saveconf').first.click_button "OK"

		click_link '最新'
		within('head') {
			expect(page).to have_css('link[href="theme/base.css"]')
			expect(page).to have_css('link[href="theme/tdiary1/tdiary1.css"]')
		}

		visit '/update.rb?conf=theme'
		within('select option[selected]'){
			expect(page).to have_content 'Tdiary1'
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
