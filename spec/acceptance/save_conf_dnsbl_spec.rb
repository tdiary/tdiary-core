# -*- coding: utf-8 -*-
require 'acceptance_helper'

feature 'spamフィルタ設定の利用' do
	scenario 'IPベースのブラックリストが動作する'

	scenario 'ドメインベースのブラックリストが動作する'

	scenario 'ブラックリストに問い合わせないリストが動作する'
end
