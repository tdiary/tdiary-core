# src.rb $Revision: 1.1 $
#
# src: 外部ファイルを挿入する(HTMLエスケープ付き)
#   パラメタ:
#     file: ファイル名
#
def src( file )
	CGI::escapeHTML( File::readlines( file ).join )
end

#
# src_inline: テキストを挿入する(HTMLエスケープ付き)
#
# パラメタ: テキスト文字列
#
def src_inline( str )
	CGI::escapeHTML( str )
end

