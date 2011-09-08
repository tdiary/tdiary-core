# -*- coding: utf-8; -*-
#
# tDiary language setup: (zh)
#
# Copyright (C) 2001-2011, TADA Tadashi <t@tdtds.jp>
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
#
def mobile_encoding
	'UTF-8'
end

def encoding_old
	'Big5'
end

#
# 'migrate_to_utf8' method converts string to UTF-8
#
def migrate_to_utf8( str )
	if String.method_defined?(:encode)
		str.encode(encoding, {:invalid => :replace, :undef => :replace})
	else
		require 'iconv'
		Iconv::iconv( encoding, encoding_old, str )
	end
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

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
