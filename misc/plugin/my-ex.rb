# my-ex.rb
#
# my(拡張版): myプラグインを拡張し、title属性に参照先の内容を挿入します。
#             参照先がセクションの場合は(あれば)サブタイトルを、
#             ツッコミの場合はツッコんだ人の名前と内容の一部を使います。
# パラメタ:
#   a:   自分の日記内のリンク先情報('YYYYMMDD#pNN' または 'YYYYMMDD#cNN')
#        URLをそのまま書くこともできます。
#   str: リンクにする文字列
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL2 or any later version.

def my( a, str, title = nil )
	date, frag = a.scan( /(\d{4}|\d{6}|\d{8}|\d{8}-\d+)[^\d]*(?:#?([pct]\d+))?$/ )[0]
	anc = frag ? "#{date}#{frag}" : date
	place, frag = frag.scan( /([cpt])(\d\d)/ )[0] if frag
	if date and frag and @diaries[date] then
		case place
		when 'p'
			section = nil
			idx = 1
			@diaries[date].each_section do |s|
				section = s
				break if idx == frag.to_i
				idx += 1
			end
			if section and section.subtitle then
				title = h( "#{apply_plugin(section.subtitle_to_html, true)}" )
				title.sub!( /^(\[([^\]]+)\])+ */, '' )
			end
		when 'c'
			com = nil
			@diaries[date].each_comment( frag.to_i ) {|c| com = c}
			if com then
				title = h( "[#{com.name}] #{com.shorten( @conf.comment_length )}" )
			end
		when 't'
			unless @plugin_files.grep(/tb-show.rb\z/).empty?
				tb = nil
				@diaries[date].each_visible_trackback( frag.to_i ) {|t, idx| tb = t}
				if tb then
					_, name, _, excerpt = tb.body.split( /\n/,4 )
					title = h( "[#{name}] #{@conf.shorten( excerpt, @conf.comment_length )}" )
				end
			end
		end
	end
	index = /^https?:/ =~ @index ? '' : base_url
	index += @index.sub(%r|^\./|, '')
	if title then
		%Q[<a href="#{h index}#{anchor anc}" title="#{title}">#{str}</a>]
	else
		%Q[<a href="#{h index}#{anchor anc}">#{str}</a>]
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
