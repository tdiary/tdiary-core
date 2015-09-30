# edit_today.rb : add link to edit after title of each days.
#
# Copyright (C) 2007 by NOB <nob@harunaru.com>
# You can redistribute it and/or modify it under GPL2 or any later version.
#

def edit_today_init
	@conf['edit_today.caption'] ||= @edit_today_caption
end

add_title_proc do |date,title|
	edit_today_link( date, title )
end

def edit_today_link( date, title )
	unless /^(day|preview)$/ =~ @mode
		edit_today_init
		caption = @conf['edit_today.caption']
		<<-HTML
		#{title}\n<span class="edit-today">
		<a href="#{@update}?edit=true;#{date.strftime( 'year=%Y;month=%m;day=%d' )}" title="#{edit_today_edit_label( date )}" rel="nofollow">#{caption}</a>
		</span>
		HTML
	else
		title
	end
end

def edit_today_saveconf
	if @mode == 'saveconf' then
		@conf['edit_today.caption'] = @cgi.params['edit_today_caption'][0]
	end
end

add_conf_proc( 'edit_today', @edit_today_caption, 'update' ) do
	edit_today_saveconf
	edit_today_init
	edit_today_conf_html
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
