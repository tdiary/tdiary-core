# list.rb
#
# <ol> 順番付きリスト生成
#   <%= ol l %>
#   パラメタ:
#     l: リスト文字列(\nくぎり)
#
# <ul> 順番無しリスト
#   <%= ul l , t %>
#   パラメタ:
#     l: リスト文字列(\nくぎり)
#
# Copyright (c) 2002 abbey <inlet@cello.no-ip.org>
# Distributed under the GPL2 or any later version.
#

def ol( l, t = nil, s = nil )
	apply_plugin( %Q[<ol>#{li l}</ol>] )
end

def ul( l, t = nil)
	apply_plugin( %Q[<ul>#{li l}</ul>] )
end

def li( text )
	list = ""
	text.each_line do |line|
		list << ("<li>" + line.chomp + "</li>")
	end
	list
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
