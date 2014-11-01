=begin
= Search control plugin((-$Id: search_control.rb,v 1.2 2004-11-09 21:07:45 zunda Exp $-))
English resource

== Summary
Ask crawlers whether to make index or not depending upon views (latest,
day, etc.) using the meta tag.

== Usage
Select this plugin through the Select-plugin plugin.

To set up, click `Search control' in the configuration view. You can
choose if you want crawlers from external search engines to index your
one-day view, latest view, etc. The default is to ask the crawlers to
only index one-day view.

To this plugin to take effect, we have to wish that the crawlers regards
the meta-tag.

This plugin also works in a diary with @secure = true.

== License
Copyright (C) 2003, 2004 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL version 2 or later.
=end

=begin ChangeLog
See ../ChangeLog for changes after this.

* Aug 28, 2003 zunda <zunda at freeshell.org>
- 1.3
- simpler configuration display

* Aug 26, 2003 zunda <zunda at freeshell.org>
- 1.2
- no table in configuration view, thanks to Tada-san.

* Aug 26, 2003 zunda <zunda at freeshell.org>
- no nofollow
- English translation
=end ChangeLog

# configuration
unless defined?( Search_control_plugin_name ) then
	Search_control_plugin_name = 'Search control'
	Search_control_description_html = <<'_HTML'
<p>Asks the crawlers from external search engines not to index
unwanted pages by using the meta tag. Check the viewes you want the
search engines to index.</p>
<p>Multiple settings can be made for different user agents.
If the given user agent does not match any of your settings,
the default setting is used.</p>
_HTML
	Search_control_delete_label = 'delete this agent'
	Search_control_new_label = 'add this agent'
	Search_control_default_label = 'Default'
	Search_control_categories = [
		[ 'Latest', 'latest' ],
		[ 'One-day', 'day' ],
		[ 'One-month', 'month' ],
		[ 'Same-day', 'nyear' ],
		[ 'Category', 'category' ]
	]
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
