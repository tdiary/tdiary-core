# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature '基本設定の利用' do
	background do
		setup_tdiary
	end

	scenario 'ツッコミを非表示にできる'

	scenario '月表示の時の表示数を変更できる'

	scenario '1日あたりの最大数を変更できる'

end
