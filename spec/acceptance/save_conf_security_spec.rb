# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature 'spamフィルタ設定の利用' do
	background do
		setup_tdiary
	end

	scenario 'おすすめフィルタの内容が保存される'

	scenario 'CSRF情報が保存される'

	scenario '基本設定が保存される'

	scenario 'キーワードでツッコミがはじかれる'

	scenario 'メールアドレスでツッコミがはじかれる'

	scenario 'URLでツッコミがはじかれる'

	scenario 'IPアドレスでツッコミが弾かれる'

	scenario 'ツッコミの注意文が保存されて表示される'

	scenario 'DNSBL設定が保存される'

	scenario 'スパムフィルター選択が保存される'

end
