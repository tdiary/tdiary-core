# bq.rb $Revision: 1.1 $
#
# bq: blockquoteを使った引用を生成する
#   パラメタ:
#     src:   引用するテキスト
#     title: 引用元のタイトル
#     url:   引用元のURL
#
#   引用元タイトルをうまく表示するには、スタイルシートでp.sourceを
#   定義する必要があります。スタイルの例:
#
#       p.source {
#          margin-top: 0.3em;
#          text-align: right;
#          font-size: 90%;
#       }
#
# Copyright (C) 2002 by s.sawada <http://mwave.sppd.ne.jp/diary/>
#
=begin ChangeLog
2002-04-15 TADA Tadashi <http://sho.tdiary.net/>
	* omit title or url.
	* sarround with <p>...</p> by each lines in src.

2002-04-15 s.sawada
	* create.
=end

def bq( src, title = nil, url = nil )
	if url then
		result = %Q[<blockquote cite="#{url}" title="#{title}">\n]
	elsif title
		result = %Q[<blockquote title="#{title}">\n]
	else
		result = %Q[<blockquote>\n]
	end
	result << %Q[<p>#{src.gsub( /\n/, "</p>\n<p>" )}</p>\n].sub( '<p></p>', '' )
	result << %Q[</blockquote>\n]
	if url then
		result << %Q[<p class="source">[<cite><a href="#{url}" title="#{title}より引用">#{title}</a></cite>より引用]</p>\n]
	elsif title
		result << %Q[<p class="source">[<cite>#{title}</cite>より引用]</p>\n]
	end
	result
end

