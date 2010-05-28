# search_form.rb
#
# Show a form for search engines.
#
# Copyright (c) 2002 MUTOH Masao <mutoh@highway.ne.jp>
# Distributed under the same license terms as tDiary.
#

add_header_proc do
	@extract_search_keyword = ''
	if @cgi.referer then
		begin
			setup = DispRef2Setup::new( @conf, 1, true, nil, @mode )
			disp_url = DispRef2URL::new( @cgi.referer )
			disp_url.parse( setup )
			if disp_url.category == :search then
				@extract_search_keyword = disp_url.key
			end
		rescue NameError
		end
	end
	''
end

def extract_search_keyword
	h @extract_search_keyword
end


def search_form(url, query, button_name = "Search", size = 20, default_text = "", first_form = "", last_form = "")
	default_text = @extract_search_keyword if default_text.empty?
	%Q[
		<form class="search" method="GET" action="#{h( url )}">
		<div class="search">
		#{first_form}
			<input class="search" type="text" name="#{h( query )}" size="#{h( size )}" value="#{h( default_text )}">
			<input class="search" type="submit" value="#{h button_name}">
		#{last_form}
		</div>
		</form>
	]
end

def namazu_form( url, button_name = "Search", size = 20, default_text = "" )
	search_form( url, "query", button_name, size, default_text )
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
