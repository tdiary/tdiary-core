# html_anchor
#
# anchor: アンカーを「YYYYMMDD.html」「YYYYMM.html」形式に置き換える
#         tDiaryから自動的に呼び出されるので、プラグインファイルを
#         設置するだけでよい。このプラグインを有効に使うためには、
#         Webサーバ側の設定変更も必要。Webサーバの設定に関しては、
#         以下のサイトが参考になる。
#
#         http://tdiary-users.sourceforge.jp/cgi-bin/wiki.cgi?html%A4%C7%A5%A2%A5%AF%A5%BB%A5%B9%A4%B7%A4%BF%A4%A4
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL2 or any later version.
#

def anchor( s )
	if /^([\-\d]+)#?([pct]\d*)?$/ =~ s then
		if $2 then
			"#$1.html##$2"
		else
			"#$1.html"
		end
	else
		""
	end
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
