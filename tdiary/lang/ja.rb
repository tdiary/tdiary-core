#
# tDiary language setup: Japanese(ja)
#
# Copyright (C) 2001-2007, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#

$KCODE = 'e'

def html_lang
	'ja-JP'
end

def encoding
	'EUC-JP'
end

def mobile_encoding
	'Shift_JIS'
end

require 'nkf'

def to_native( str, charset = nil )
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
	from = @options['encode_from'] if @options['encode_from'] and from.size == 0
	NKF::nkf( "-m0 -#{from}e", str )
end

def to_mobile( str )
	NKF::nkf( '-m0 -s', str )
end

def to_mail( str )
	NKF::nkf( '-m0 -j', str )
end

def shorten( str, len = 120 )
	lines = NKF::nkf( "-e -m0 -f#{len}", str.gsub( /\n/, ' ' ) ).split( /\n/ )
	lines[0].concat( '..' ) if lines[0] and lines[1]
	lines[0] || ''
end

def comment_length
	60
end
