# -*- coding: utf-8; -*-
#
# tDiary language setup: (zh) $Revision: 1.4 $
#
# Copyright (C) 2001-2005, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#

#
# 'html_lang' method returns String of HTML language attribute.
# 
def html_lang
	'zh-TW'
end

#
# 'encoding' method returns String of HTTP or HTML charactor encoding.
# 
def encoding
	'UTF-8'
end

#
# 'mobile_encoding' method returns charactor encoding in mobile mode.
def mobile_encoding
	'UTF-8'
end

#
# 'to_native' method converts string automatically to native encoding.
# 
def to_native( str, charset = nil )
	str.dup
end

#
# 'migrate_to_utf8' method converts string to UTF-8
#
def migrate_to_utf8( str )
	require 'iconv'
	Iconv::iconv( 'UTF-8', 'Big5', str )
end

#
# 'to_mobile' method converts string automatically to mobile mode encoding.
# 
def to_mobile( str )
	str.dup
end

#
# 'to_mail' method converts string automatically to E-mail encoding.
# 
def to_mail( str )
	str.dup
end

#
# 'shorten' method cuts string length.
# 
def shorten( str, length = 120 )
	matched = str.gsub( /\n/, ' ' ).scan( /^.{0,#{length - 2}}/ )[0]
	unless $'.empty?
		matched + '..'
	else
		matched
	end
end

#
# 'comment_length' returns length of shorten comment on recent or monthly view.
#
def comment_length
	120
end
