# -*- coding: utf-8 -*-
require File.expand_path('../acceptance_helper', __FILE__)

feature '日記を読む' do
	background do
		setup_tdiary
	end

	scenario '特定の日記の内容を更新する'

	scenario '日記の削除'

	scenario '日記を隠す'
end
