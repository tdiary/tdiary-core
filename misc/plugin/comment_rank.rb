# -*- coding: utf-8 -*-
# comment_rank.rb
#
# comment_rank: ツッコミの数でランキング
#   パラメタ:
#     max:  最大表示数(未指定時:5)
#     sep:  セパレータ(未指定時:空白)
#     except:        無視する名前(いくつもある場合は,で区切って並べる)
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL2 or any later version.
#
#
def comment_rank( max = 5, sep = '&nbsp;', *except )
	name = Hash::new(0)
	@diaries.each_value do |diary|
		diary.each_comment do |comment|
			next if except.include?(comment.name)
			name[comment.name] += 1
		end
	end
	result = []
	name.sort{|a,b| (a[1])<=>(b[1])}.reverse.each_with_index do |ary,idx|
		break if idx >= max
		result << "<strong>#{idx+1}.</strong>#{h ary[0]}(#{ary[1].to_s})"
	end
	result.join( sep )
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
