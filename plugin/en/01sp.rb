# English resources of 01sp.rb $Revision: 1.2 $

=begin
= Select-plugin plugin

== Abstract
Selects which plugin to be actually used.

== Usage
Put this file into the plugin/ directory.

Next, move the plugins you want to be optional into another directory.
In the example below, these plugins are assumed to be in
plugin/selectable directory.

Finally, edit the tdiary.conf file in the same directory as tdiary.rb
and add the following line:
  @options['sp.path'] = 'misc/plugin'
to indicate the directory you have put the optional plugins. It can be
an absolute path.

You can use this plugin in a secure diary.

== Options
:@options['sp.path']
	Directory name where the optional plugins are, relative from the
  directory where tdiary.rb is or absolute.

:@options['sp.showhelp']
	Define true when you want the users (writers of the diaries) to see
  the comments of the plugins.

:@options['sp.showsource']
	Define true when you want the users  to see the sources of the
	plugins.

:@options['sp.showmandatory']
	Define true when you want to show what plugins are installed in the
  non-optional path.

:@options['sp.usenew']
  Define true if you want to the users to try a newly installed plugin.
	Newly installed plugins are detected next time when the user configures
	this plugin.

== Copyright notice
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL
version 2 or later.

You should be able to find the latest version of this pluigin at
((<URL:http://zunda.freeshell.org/d/plugin/select_plugins.rb>)).
=end

@sp_label = 'Plugin selection'
@sp_label_description = '<p>Selects which plugins you want to use.</p>'
@sp_label_mandatory = %Q|<h4>Mandatory plugins</h4>
				<p>These plugins must always be used.</p>|
@sp_label_optional = "<h4>Optional plugins</h4>"
@sp_label_optional2 = "<p>Please check the plugins you want to use.</p>"
@sp_label_comment = "comments"
@sp_label_source = "source"
@sp_label_new = '[New! Try this.]'
@sp_label_noplugin = "<li>There is no optional plugins."
