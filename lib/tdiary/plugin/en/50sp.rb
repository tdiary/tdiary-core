# English resources of 50sp.rb

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
  @conf.options['sp.path'] = 'misc/plugin'
to indicate the directory you have put the optional plugins. It can be
an absolute path.

== Options
:@conf.options['sp.path']
	Directory name where the optional plugins are, relative from the
  directory where tdiary.rb is or absolute.

:@conf.options['sp.usenew']
  Define true if you want to the users to try a newly installed plugin.
	Newly installed plugins are detected next time when the user configures
	this plugin.

== Copyright notice
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL version 2 or later.
=end

@sp_label = 'Plugin selection'
@sp_label_description = '<p>Selects which plugins you want to use.</p>'
@sp_label_please_select = '<p>Please check the plugins you want to use. Each plugin filename is linked to its document. Please create or improve the document!</p>'
@sp_label_new = '<h3>New! Give it a try.</h3>'
@sp_label_used = '<h3>Being used</h3>'
@sp_label_notused = '<h3>Currently not used</h3>'
@sp_label_noplugin = '<p>There is no optional plugins.</p>'

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
