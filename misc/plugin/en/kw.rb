def kw_label
	"Keyword"
end

def kw_desc
	<<-HTML
	<p>kw(KeyWord) plugin generate a Link by simple words. You can specify keywords
	as space sepalated value: "keyword URL". For example,</p>
	<pre>google http://www.google.com/search?q=$1</pre>
	<p>then you specify in your diary as:</p>
	<pre>&lt;%=kw 'google:tdiary' %&gt;</pre>
	<p>so it will be translated to link of seraching 'tdiary' at Google.</p>
	HTML
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
