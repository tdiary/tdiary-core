# -*- coding: utf-8 -*-
# recent_namazu.rb
#
# recent_namazu: Namazu検索語新しい順
# 		 namazi.cgiが作成する検索キーワードログ(NMZ.slog)から
#		 最新xx件分の検索語を表示します。
# パラメタ:
#   file:       検索キーワードログファイル名(絶対パス表記)
#   namazu:     なまずcgi名
#   limit:      表示件数(未指定時:5)
#   sep:        セパレータ(未指定時:空白)
#   make_link:  <a>を生成するか?(未指定時:生成する)
#
#
# Copyright (c) 2002 Hiroyuki Ikezoe <zoe@kasumi.sakura.ne.jp>
# Distributed under the GPL

def recent_namazu(file, namazu, limit = 5, sep='&nbsp;', make_link = true)
	begin
		lines = []
		log = open(file)
		if log.stat.size > 300 * limit then
			log.seek(-300 * limit,IO::SEEK_END)
		end
		log.each_line do |line|
			lines << line
		end

		result = []
		lines.reverse.each_with_index do |line,idx|
			break if idx >= limit
			word = line.split(/\t/)[0]
			if make_link
				result << %Q[<a href="#{h( namazu )}?query=#{u( word )}">#{h( word )}</a>]
			else
				result << h( word )
			end
		end
		result.join( sep )
	rescue
		%Q[<p class="message">#$! (#{$!.class})<br>cannot read #{file}.</p>]
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
