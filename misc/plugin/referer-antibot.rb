# referer-antibot.rb
#
# 検索エンジンの巡回BOTには「本日のリンク元」を見せないようにする
# これにより、無関係な検索語でアクセスされることが減る(と予想される)
# pluginディレクトリに入れるだけで動作する
#
# オプション:
#   @options['bot']
#      ターゲットにする巡回BOTのUser-Agentを追加する配列。
#      無指定時は["googlebot", "Hatena Antenna", "moget@goo.ne.jp"]のみ。
#
# なお、disp_referrer.rbプラグインには同等の機能が含まれているので、
# disp_referrerを導入済みの場合には入れる必要はない
#
# ---------
#
# This plugin hide Today's Link to search engin's robots.
# It may reduce nose marked by robots.
#
# disp_referrer.rb plugin has already this function. You don't
# need install this plugin with disp_referrer.rb.
#
# Options:
#    @options['bot']
#      An array of User-Agent of search engine's robots.
#      Default setting is ["googlebot", "Hatena Antenna", "moget@goo.ne.jp"].
#
# Copyright (C) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# Modified by TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2 or any later version.
#

# short referer
alias referer_of_today_short_antibot_backup referer_of_today_short
def referer_of_today_short( diary, limit )
	return '' if bot?
	referer_of_today_short_antibot_backup( diary, limit )
end

# long referer
alias referer_of_today_long_antibot_backup referer_of_today_long
def referer_of_today_long( diary, limit )
	return '' if bot?
	referer_of_today_long_antibot_backup( diary, limit )
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
