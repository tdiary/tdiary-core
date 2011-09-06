# -*- coding: utf-8; -*-
#
# tDiary language setup: Japanese(ja)
#
# Copyright (C) 2001-2011, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2.
#

require 'nkf'

# preload transcodes outside $SAFE=4 environment
if String.method_defined?(:encode)
	Encoding::Converter.new('UTF-16', 'UTF-8')
end

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

def to_native( str, charset = nil )
	begin
		if String.method_defined?(:encode)
			if str.encoding == Encoding::ASCII_8BIT
				str.force_encoding(charset || 'UTF-8')
			end
			unless str.valid_encoding?
				str.encode!('utf-16', {:invalid=>:replace, :undef=>:replace})
			end
			str.encode('utf-8', {:invalid=>:replace, :undef=>:replace})
		else
			require "iconv"
			Iconv.conv('utf-8', charset || 'utf-8', str)
		end
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
	to_native( str, encoding_old )
end

def to_mobile( str )
	NKF::nkf( '-m0 -W -s', str )
end

def to_mail( str )
	begin
		if String.method_defined?(:encode)
			str.encode('iso-2022-jp')
		else
			require "iconv"
			Iconv.conv('iso-2022-jp', 'utf-8', str)
		end
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

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
