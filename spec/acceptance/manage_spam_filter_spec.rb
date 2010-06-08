# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature 'spamフィルタの確認' do
	background do
		setup_tdiary
	end

	scenario 'おすすめフィルタの内容が保存される'

	scenario '基本設定が保存される'

	scenario 'DNSBL設定が保存される'

	scenario 'ツッコミの注意文が保存される'
end
