# kw.rb $Revision: 1.1 $
#
# kw: keyword link generator
#   Parameters:
#     keyword: keyword or InterWikiName (separated by ':').
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
#   style: encoding style as: 'euc-jp', 'sjis', 'jis' or nil.
#
#   if there isn't @options['kw.dic'], the plugin links to google.
#
# Copyright (C) 2003, TADA Tadashi <sho@spc.gr.jp>
# You can distribute this under GPL.
#

def kw( keyword )
	unless @kw_dic then
		@kw_dic = {}
		(@options['kw.dic'] || [[nil,'http://www.google.com/search?ie=euc-jp&amp;q=$1', 'euc-jp']]).each do |dic|
			@kw_dic[dic[0]] = dic[1..-1]
		end
	end
	inter, key = keyword.split( ':', 2 )
	unless key then
		inter = nil
		key = keyword
	end
	begin
		key = CGI::escape( case @kw_dic[inter][1]
			when 'euc-jp'
				#NKF::nkf( '-e', key )
				key
			when 'sjis'
				NKF::nkf( '-s', key )
			when 'jis'
				NKF::nkf( '-j', key )
			else # none
				key
		end )
	rescue NameError
		inter = nil
		retry
	end
	%Q[<a href="#{@kw_dic[inter][0].sub( /\$1/, key )}">#{keyword}</a>]
end
