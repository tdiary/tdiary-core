#
# tDiary language setup: English(en) $Revision: 1.2 $
#

#
# setting ruby charctor encoding.
# 
$KCODE = 'n'

#
# 'html_lang' method returns String of HTML language attribute.
# 
def html_lang
	'en-US'
end

#
# 'encoding' method returns String of HTTP or HTML charactor encoding.
# 
def encoding
	'ISO-8859-1'
end

#
# 'mobile_encoding' method returns charactor encoding in mobile mode.
def mobile_encoding
	'ISO-8859-1'
end

#
# 'to_native' method converts string automatically to native encoding.
# 
def to_native( str )
	str.dup
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
