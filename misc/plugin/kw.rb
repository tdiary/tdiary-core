# kw.rb
#
# kw: keyword link generator
#   Parameters:
#     keyword: keyword or InterWikiName (separated by ':').
#     name: anchor string (optional).
#     title: title attribute (optional).
#
# @options['kw.dic']
#   array of dictionary table array. an item of array is:
#
#       [key, URL, style]
#
#   key:   nil or string of key.
#          If keyword is 'foo', it has key nil.
#          If keyword is 'google:foo', it has key 'google'.
#   URL:   the URL for link. '$1' is replace by keyword.
#   style: encoding style as: 'euc-jp', 'sjis', 'jis', 'utf-8' or nil.
#
#   if there isn't @options['kw.dic'], the plugin links to google.
#
# @options['kw.show_inter']
#   Show InterWikiName.
#   If this options is true, the keyword 'google:foo' shows 'google:foo'.
#   But it is false, that shows only 'foo'.
#   The default of this option is true.
#
# Copyright (C) 2003, TADA Tadashi <sho@spc.gr.jp>
# You can distribute this under GPL2 or any later version.
#

unless String.method_defined?(:encode)
	require 'nkf'
end

def kw_parse( str )
	kw_list = []
	str.each_line do |pair|
		k, u, s = pair.sub( /[\r\n]+/, '' ).split( /[ \t]+/, 3 )
		k = nil if k == '' or k == 'nil'
		s = nil if s != 'euc-jp' && s != 'sjis' && s != 'jis' && s != 'utf-8'
		kw_list << [k, u, s] if u
	end
	kw_list
end

def kw_generate_dic
	kw_dic = {nil => ['http://www.google.com/search?ie=utf-8&q=$1', 'utf-8']}

	kw_list = []
	case @conf['kw.dic'].class.to_s
	when "String"
		kw_list = kw_parse( @conf['kw.dic'] )
	when "Array"
		kw_list = @conf['kw.dic']
	end
	kw_list.each do |pair|
		kw_dic[pair[0]] = pair[1..-1]
	end
	kw_dic
end

def kw( keyword, name = nil, title = nil )
	@kw_dic = kw_generate_dic unless @kw_dic
	show_inter = @options['kw.show_inter'] == nil ? true : @options['kw.show_inter']

	inter, key = keyword.split( /:/, 2 )
	unless key then
		inter = nil
		key = keyword
	end
	keyword = key unless show_inter
	name = keyword unless name
	title = title ? %Q[ title="#{h title}"] : ''

	unless @kw_dic.has_key?(inter)
		inter = nil
	end
	style = @kw_dic[inter][1]
	if String.method_defined?(:encode)
		if style
			key = key.encode({'jis'=>'ISO-2022-JP', 'sjis'=>'Shift_JIS'}[style] || style)
		end
	else
		key = case style
			when 'euc-jp'
				NKF::nkf( '-m0 -W -e', key )
			when 'sjis'
				NKF::nkf( '-m0 -W -s', key )
			when 'jis'
				NKF::nkf( '-m0 -W -j', key )
			when 'utf-8'
				key
			else # none
				key
		end
	end
	%Q[<a href="#{h @kw_dic[inter][0].sub( /\$1/, u( key ))}"#{title}>#{h name}</a>]
end

#
# config
#
unless @resource_loaded then
	def kw_label
		"キーワード"
	end

	def kw_desc
		<<-HTML
		<h3>リンクリストの指定</h3>
		<p>特定のサイトへのリンクを、簡単な記述で生成するためのプラグイン(kw)です。
		「キー URL エンコードスタイル」と空白で区切って指定します。例えば、</p>
		<pre>google http://www.google.com/search?ie=utf-8&amp;q=$1 utf-8</pre>
		<p>と指定すると、</p>
		<pre>&lt;%=kw('google:tdiary')%&gt;</pre>
		<p>のように日記に書けばgoogleでtdiaryを検索するリンクになります
		(記述方法はスタイルによって変わります)。なお、キーにnilを指定すると、
		「google:」の部分を書かない場合の指定ができます。</p>
		HTML
	end
end

add_conf_proc( 'kw', kw_label ) do
	if @mode == 'saveconf' then
		kw_list = kw_parse( @conf.to_native( @cgi.params['kw.dic'][0] ) )
		if kw_list.empty? then
			@conf.delete( 'kw.dic' )
		else
			@conf['kw.dic'] = kw_list.collect{|a|a.join( ' ' )}.join( "\n" )
		end
	end
	dic = kw_generate_dic
	if dic[nil] then
		dic['nil'] = dic[nil]
		dic.delete( nil )
	end
	<<-HTML
	#{kw_desc}
	<p><textarea name="kw.dic" cols="60" rows="10">#{h dic.collect{|a|a.flatten.join( " " )}.join( "\n" )}</textarea></p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
