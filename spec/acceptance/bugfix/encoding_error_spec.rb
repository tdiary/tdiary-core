require 'acceptance_helper'

feature '1.9 でエンコーディングエラーとなるリファラ' do
	scenario 'invalid sequence な場合' do
		disable_plugin('disp_referrer')

		append_default_diary

		src_path = File.expand_path('../../../fixtures/invalid-sequence-volatile.tdr', __FILE__)
		dist_path = File.expand_path('../../../../tmp/data/volatile.tdr', __FILE__)
		FileUtils.cp_r src_path, dist_path

		visit "/?date=#{Date.today.strftime('%Y%m%d')}"

		expect(page).to have_content "さて、テストである。"
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
