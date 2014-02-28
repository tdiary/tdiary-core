# search_form.rb English resource.

def google_form( button_name = "Google Search", size = 20, default_text = "" )
	first = %Q[<a href="http://www.google.com/">
		<img src="http://www.google.com/logos/Logo_40wht.gif"
			style="border-width: 0px; vertical-align: middle;" alt="Google"></a>]
	search_form( "http://www.google.com/search", "q", button_name, size, default_text, first, '' )
end

def yahoo_form( button_name = "Yahoo! Search", size = 20, default_text = "" )
	first = %Q[<a href="http://www.yahoo.com/">
		<img src="http://us.i1.yimg.com/us.yimg.com/i/yahootogo/ytg_search.gif"
			style="border-width: 0px; vertical-align: middle;" alt="[Yahoo!]"></a>]
	search_form( "http://search.yahoo.com/search", "p", button_name, size, default_text, first, "" )
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
