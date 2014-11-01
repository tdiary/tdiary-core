# -*- coding: utf-8 -*-
# src.rb
#
# src: 外部ファイルを挿入する(HTMLエスケープ付き)
#   パラメタ:
#     file: ファイル名
#
# Copyright (c) 2005 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL2 or any later version.
#
def src( file )
	h( File::readlines( file ).join )
end

#
# src_inline: テキストを挿入する(HTMLエスケープ付き)
#
# パラメタ: テキスト文字列
#
def src_inline( str )
	h( str )
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
