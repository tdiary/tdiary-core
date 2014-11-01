# -*- coding: utf-8; -*-
# English resources of 60sf.rb
# Based on English resources of 50sp.rb Revision: 1.2
# Modified by KURODA Hiraku

=begin
= Select-spamfilter plugin

== Abstract
Selects which filter to be actually used.

== Usage
Put this file into the plugin/ directory.

Next, move the filterss you want to be optional into another directory.
In the example below, these filters are assumed to be in
filter/selectable directory.

Finally, edit the tdiary.conf file in the same directory as tdiary.rb
and add the following line:
  @conf.options['sf.path'] = 'misc/filter'
to indicate the directory you have put the optional filters. It can be
an absolute path.

== Options
:@conf.options['sf.path']
	Directory name where the optional filters are, relative from the
  directory where tdiary.rb is or absolute.

:@conf.options['sf.usenew']
  Define true if you want to the users to try a newly installed filter.
	Newly installed filters are detected next time when the user configures
	this plugin.

== Copyright notice
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL version 2 or later.

Original version of these files is for selecting plugins.
Modifying for selecting filters is by KURODA Hiraku <hiraku at hinet.mydns.jp>
Feb. 2008
=end

@sf_label = 'Filter selection'
@sf_label_description = '<p>Selects which filters you want to use.</p>'
@sf_label_please_select = '<p>Please check the filters you want to use. Each filter filename is linked to its document. Please create or improve the document!</p>'
@sf_label_new = '<h3>New! Give it a try.</h3>'
@sf_label_used = '<h3>Being used</h3>'
@sf_label_notused = '<h3>Currently not used</h3>'
@sf_label_nofilter = '<p>There is no optional filters.</p>'

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
