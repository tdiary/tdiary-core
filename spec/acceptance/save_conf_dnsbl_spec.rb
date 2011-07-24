# -*- coding: utf-8 -*-
require 'acceptance_helper'

feature 'spamフィルタ設定の利用' do
	scenario 'IPベースのブラックリストが動作する'

	scenario 'ドメインベースのブラックリストが動作する'

	scenario 'ブラックリストに問い合わせないリストが動作する'
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
