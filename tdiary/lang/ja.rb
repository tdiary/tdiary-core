#
# tDiary language setup: Japanese(ja)
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
begin
	require 'uconv'
	eval( <<-TOPLEVEL_CLASS, TOPLEVEL_BINDING )
		def Uconv.unknown_unicode_handler( unicode )
			if unicode == 0xff5e
				"`"
			else
				raise Uconv::Error
			end
		end
	TOPLEVEL_CLASS

	@reg_char_utf8 = /&#[0-9]+;/
	def to_native( str )
		if @reg_char_utf8 =~ str then
			str.gsub!( @reg_char_utf8 ) do |v|
				Uconv.u8toeuc( [$1.to_i].pack( "U" ) )
			end
		else
			begin
				str = Uconv.u8toeuc( str )
			rescue Uconv::Error
				str = NKF::nkf( '-m0 -e', str )
			end
		end
		str
	end
rescue LoadError
	def to_native( str )
		NKF::nkf( '-m0 -e', str )
	end
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
	lines[0]
end

def comment_length
	60
end
