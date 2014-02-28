# -*- coding: utf-8 -*-
=begin
= 連番生成プラグイン sn.rb

== 概要
	各日付の日記内で通し番号を表示します。

== 使い方
	sn( number )
		number - 内部カウンタを指定した値にセットします。
	sn_anchorid

	sn()メソッドは日記の各日付ごとに、1から始まる通し番号を表示します。

	sn_anchorid()メソッドは現在のアンカーidの番号を表示します。
	sn_anchorid()を設定オプション内のセクション/ツッコミアンカー
	として指定することによって，そのセクション/ツッコミアンカーの
	URLと結び付いた数値を表示することができます。

== 参考
	anchor()はzoe氏作のnumber_anchor.rbを参考に作成しました。

= Sequential number generator plugin
== Abstract
	Display sequential numbers for every date.

== Usage
	sn( number )
		number - Set the value of the internal counter to 'number'.
	sn_anchorid

		The sn() method displays sequential numbers starting at 1 for
		every date.

		The sn_anchorid() method displays a current number of the anchorid.
		If you use sn_anchorid() as a section/comment anchor in the setup
		option, you can display the number relevant to URL of
		the section/comment anchor.

== reference
	Original anchor() appeared in the number_anchor.rb by zoe-san.

== 著作権について (Copyright notice)
	Copyright (c) 2003 SAKAMOTO Hideki <hs@on-sky.net>
	Distributed under the GPL
=end

=begin Changelog
2003-09-23 SAKAMOTO Hideki <hs@on-sky.net>
	* document corrected
2003-09-17 SAKAMOTO Hideki <hs@on-sky.net>
	* add add_body_leave_proc
2003-09-13 SAKAMOTO Hideki <hs@on-sky.net>
	* change @sn_section initialization: nil -> 0
	* delete @sn_section  clear line in sn()
	* add sn_anchorid method
2003-09-10 SAKAMOTO Hideki <hs@on-sky.net>
	* write English document
	* force to use anchor-id in section anchor
	* delete 'sn.use_anchorid' option
2003-08-29 SAKAMOTO Hideki <hs@on-sky.net>
	* first version
=end

add_body_enter_proc do |date|
	@sn_count = 1
	@sn_idx = 0
	""
end

add_body_leave_proc do |date|
	@sn_count = 1
	@sn_idx = 0
	""
end

alias :_orig_anchor_sn :anchor

def anchor( s )
	if /^(\d+)#?([pct])?(\d*)?$/ =~ s then
		if $2 then
			@sn_idx = $3.to_i
		end
	end
	_orig_anchor_sn(s)
end

def sn( number = nil )
	if number then
		@sn_count = number.to_i
	else
		number = @sn_count
	end
	@sn_count += 1
	%Q[#{'%d' % number}]
end

def sn_anchorid
	%Q[#{'%d' % @sn_idx}]
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
