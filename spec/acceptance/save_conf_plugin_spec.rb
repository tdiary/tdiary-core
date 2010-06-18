# coding: utf-8
require File.expand_path('../acceptance_helper', __FILE__)

feature 'プラグイン選択設定の利用' do
	background do
		setup_tdiary
	end

	scenario '新入荷のプラグインが表示される'

	scenario 'プラグイン設定を保存する'

	scenario 'プラグインが消えたら表示されない'

end
