# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature 'spamフィルタが動く' do
	background do
		setup_tdiary
	end

	scenario 'キーワードでツッコミがはじかれる'

	scenario 'メールアドレスでツッコミがはじかれる'

	scenario 'URLでツッコミがはじかれる'

	scenario 'IPアドレスでツッコミが弾かれる'
end
