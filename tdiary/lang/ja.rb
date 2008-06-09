#
# tDiary language setup: Japanese(ja)
#
# Copyright (C) 2001-2007, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#

$KCODE = 'u'

require 'nkf'
begin
	require "iconv"
rescue LoadError
end

def html_lang
	'ja-JP'
end

def encoding
	'UTF-8'
end

def mobile_encoding
	'Shift_JIS'
end

def to_native( str, charset = nil )
	begin
		Iconv.conv('utf-8', charset || 'utf-8', str)
	rescue
		from = case charset
			when /^utf-8$/i
				'W'
			when /^shift_jis/i
				'S'
			when /^EUC-JP/i
				'E'
			else
				''
		end
		NKF::nkf("-m0 -#{from}w", str)
	end
end

def migrate_to_utf8( str )
	to_native( str, 'EUC-JP' )
end

def to_mobile( str )
	NKF::nkf( '-m0 -W -s', str )
end

def to_mail( str )
	begin
		Iconv.conv('iso-2022-jp', 'utf-8', str)
	rescue
		NKF::nkf('-m0 -W -j', str)
	end
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
