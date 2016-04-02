# search_form.rb japanese resource.

def googlej_form( button_name = "Google 検索", size = 20, default_text = "" )
	first = %Q[<a href="http://www.google.com/">
		<img src="http://www.google.com/logos/Logo_40wht.gif"
			style="border-width: 0px; vertical-align: middle;" alt="Google"></a>]
	last = %Q[<input type="hidden" name="hl" value="ja"><input type="hidden" name="ie" value="utf-8">]
	search_form( "http://www.google.com/search", "q", button_name, size, default_text, first, last )
end

def google_form( button_name = "Google 検索", size = 20, default_text = "" )
	googlej_form( button_name, size, default_text )
end

def yahooj_form( button_name = "Yahoo! 検索", size = 20, default_text = "" )
	first = %Q[<a href="http://www.yahoo.co.jp/">
		<img src="http://img.yahoo.co.jp/images/yahoojp_sm.gif"
			style="border-width: 0px; vertical-align: middle;" alt="Yahoo! JAPAN"></a>]
	search_form( "http://search.yahoo.co.jp/bin/search", "p", button_name, size, default_text, first, "" )
end

def yahoo_form( button_name = "Yahoo! 検索", size = 20, default_text = "" )
	yahooj_form( button_name, size, default_text )
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
