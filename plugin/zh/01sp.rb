# Traditional-Chinese resources of 01sp.rb $Revision: 1.1 $

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

:@options['sp.usenew']
  Define true if you want to the users to try a newly installed plugin.
	Newly installed plugins are detected next time when the user configures
	this plugin.

== Copyright notice
Copyright (C) 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL
version 2 or later.
=end

@sp_label = '選用 Plugin'
@sp_label_description = '<p>請選擇您想使用的 plugins。</p>'
@sp_label_please_select = '<p>選擇您想使用的 plugins，每個 plugin 的鍊結都會連到它的說明文件，請幫忙新增或改進說明文件的內容。</p>'
@sp_label_new = '<h4>新鮮貨！試一試啊！</h4>'
@sp_label_used = '<h4>已選用的</h4>'
@sp_label_notused = '<h4>不選用的</h4>'
@sp_label_noplugin = '<p>沒有 plugin 可選用。</p>'
