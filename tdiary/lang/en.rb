#
# tDiary language setup: English(en)
#

$KCODE = 'n'

def html_lang
	'en-US'
end

def encoding
	'ISO-8859-1'
end

def mobile_encoding
	'ISO-8859-1'
end

def to_native( str )
	str.dup
end

def to_mobile( str )
	str.dup
end

def to_mail( str )
	str.dup
end

def shorten( str, length = 120 )
	matched = str.gsub( /\n/, ' ' ).scan( /^.{0,#{length - 2}}/ )[0]
	unless $'.empty?
		matched + '..'
	else
		matched
	end
end

def comment_length
	120
end
