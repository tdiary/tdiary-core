#
# tDiary language setup: Japanese(ja)
#
# Copyright (C) 2001-2011, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2. or any later version
#

def html_lang
	'ja-JP'
end

def encoding
	'UTF-8'
end

def encoding_old
	'EUC-JP'
end

def mobile_encoding
	'Shift_JIS'
end

def to_mobile( str )
	str.encode(mobile_encoding, {invalid: :replace, undef: :replace})
end

def to_mail( str )
	str.encode('iso-2022-jp', {invalid: :replace, undef: :replace})
end

def migrate_to_utf8( str )
	to_native( str, encoding_old )
end

def shorten( str, len = 120 )
	matched = str.gsub( /\n/, ' ' ).scan( /^.{0,#{len - 2}}/u )[0]
	if $'.nil? || $'.empty?
		matched
	else
		matched + '..'
	end
end

def comment_length
	60
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
