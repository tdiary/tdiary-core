=begin

= tDiary -- a TSUKKOMI-able Web-log
tDiary is so called Weblog. tDiary has these features.

== features

=== You can change your configuration with browser.
You can not only read diary, but also write diary. Also, it is possible to change your configuration with browser. With tDiary, you can easily use and maintain Web-log system. So, you continue to write diary for a long time.

=== TSUKKOMI
'TSUKKOMI' means a short, smart and heartfelt comment in Japanese. It is possible for diary readers to add a TSUKKOMI to your diary. In other words, tDiary is equipped with BBS. With this BBS, you can communicate with your diary readers. tDiary can inform the author of a new TSUKKOMI by e-mail.

=== Today's Link (Referer)
When people links their diary to your diary, tDiary shows their URL by analysis of the referer header. This feature is supported in many Japanese web-log systems. In tDiary, this feature is more user-friendly.

=== small devices -- PDA or mobile phone
You can read your diary with PDA or mobile phone, for example, i-mode, Palm, Zaurus(SHARP's PDA) and so on. When you access the same URL as usual, tDiary creates a page for PDA or mobile phone. The page for small devices are small and suitable for reading with them. 

=== theme -- CSS 
You can change the look of the diary by CSS. In tDiary, this feature is called 'theme'. tDiary package has some themes. Of course, you can create a new theme. You can change your theme with browser.

=== Plugin 
By plugins, you can add new features to tDiary, and change the existing feature of tDiary.

=== Selectable Style and IO
You can choice a grammar of writing your diary by 'Style' feature. Some style files are in misc/style. And you can choice data saving format (IO) also. Seee HOWTO-make-io.rd for more information about Style or IO.


=== Written in Ruby
Important :-). tDiary requires Ruby-1.6.3 or later.

=== Others
tDiary also supports these features.

* Section anchor 
* Read past diaries

== Installation and Configuration 
In this manual, we presume this environment as one example.

* WWW server: Apache 1.3.x
* User: foo
* Diary URL: http://www.bar.example.org/~foo/diary/
* Diary Path: /home/foo/public_html/diary/

=== CGI script configuration
Unpack archive, and copy all the files to "/home/foo/public_html/diary/". You must change permission of two files, which are executed as CGI script.

* index.rb
* update.rb

If you use tDiary in an environment where the command "/usr/bin/env" can't be used, you need to edit these files and change their front line so that it stands for the Ruby executable. Except the case when you install Ruby under your home directory, you may be not careful about this thing.  

=== .htaccess 
Next, you arrange CGI environment. You copy "dot.htaccess" as ".htaccess". And, edit it. The file, "dot.htaccess", is like this;

  Options ExecCGI
  AddHandler cgi-script .rb
  DirectoryIndex index.rb

  <Files "*.rhtml">
        deny from all
  </Files>

  <Files "tdiary.*">
        deny from all
  </Files>

  <Files update.rb>
  AuthName      tDiary
  AuthType      Basic
  AuthUserFile  /home/foo/.htpasswd
  Require user  foo
  </Files>

"dot.htaccess" configures these things.

* makes it possible to use CGI.
* makes files whose suffix is ".rb" recognized as CGI script.
* sets "index.rb" to the default file.
* prohibits accesses to "*.rhtml" and "tdiary.*"
* When you access "update.rb", authentification is needed.

At least, you must change the "AuthUserFile" and "Require User" items. In Addition to it, you must create the the file named as "AuthUserFile" by "htpasswd" command before you access your diary. If you don't know "AuthUserFile" and "Require users", please examine these words.

If your WWW server doesn't allow you to change the suffix of CGI scripts, you need to change the "AddHandeler" or "DirectoryIndex" items. In this case, you may need to change the filenames of "index.rb" and "update.rb".

=== creation of tdiary.conf
You copy "misc/i18n/tdiary.conf.sample-en" as "tdiary.conf" and edit "tdiary.conf". ((* Notice! "tdiary.conf.sample" in INSTALLDIR is Japanese version *)). "tdiary.conf.sample" only supports Japanese. 

"tdiary.conf" is loaded as Ruby script by the CGI scripts, for example, "index.rb" and "update.rb". With tDiary, you can do configuration with browser, so an item that you must change is "@data_path". "@data_path" is appeared at the beginning of "tdiary.conf".

   @data_path = "/home/foo/diary"

In "@data_path", you specify the directory where your diary data are stored. This item is usually set to the directory which can not be accessed through WWW. In addition to it, you must set permission of this directory so that the WWW server can access it.

In "tdiary.conf", you can configure many items. They are divided into three categories.

==== The items which you can't set with browser
Like "@data_path", these are the items which you can't change with browser. These items are configured only by editing "tdiary.conf" directly.

==== The items which you can set with browser
When you click the menu, "preferences", you can change your configuration with browser. Almost all the items are changed with browser. You don't have to edit "tdiary.conf" directly. 

==== The items to which you can add values with browser
"tdiary.conf" has some items to which values are added with browser, for example, the ignored links and the rules which convert a URL. By editing these items of "tdiary.conf", you can set the default values(This is meaningful if you use multi-user mode). 


=== Configuration
The meaning of each item is explained in "tdiary.conf.sample". Generally speaking, you can change your configuration with browser after you configure @data_path. If you want to receive a new TSUKKOMI by e-mail, you configure the @smtp_host and @smtp_port.

If you run tDiary in the environment where you can't use the suffix, ".rb", as CGI script, you change the filenames of "index.rb" and "update.rb". In this case, you must configure @index and @update.

After you finish configuration, access "http://www.hoge.example.org/~foo/diary/". If you can see an empty page, tDiary works well. Unfortunately, if you encounter "Internal Server Error", you must change configuration. The error-log of Apache is useful in order to investigate the cause.    

== Security 
"tdiary.conf" has the item which change the security level. If you use tDiary on your own server, you may not care about security. But, if you lend tDiary or provide the service of web-log, you need restriction.

In these cases, you set the security level in "tdiary.conf". Normally, these two lines exists at the end of "tdiary.conf".

  @secure = false
  load_cgi_conf

By changing @secure, you set the security level. If this is false, no security check is carried out. If no security check is executed, users can change tDiary indulgently. When you run tDiary under the dangerous circumstance, you set @secure to true. If you do it, the dangerous operation, for example, file operation or variable assignment, is prohibited when "tdiary.conf" is loaded. The "@secure" affects plugins. If security check is carried out, you can't use some plugins.

"load_cgi_conf" is the function which loads the tDiary's configuration file of CGI. In this example, the CGI configuration file is loaded after the security level is configured.

Because you can change the positions of "load_cgi_conf" and @secure independently, you can do detailed configuration. If you omit @secure, @secure is set to the default value, true.

== run tDiary 

=== update the diary

At the beginning of the diary page, there are two links, "Top" and "Update". When you click "Top", you move to the page which is specified by "@index_page". When you click "Update", you move to the page which has the form to update your diary. If the authentification dialog doesn't appear in clicking "Update", there is possibility that your ".htaccess" is wrong.

The "Update" page also has the menu in its beginning. In "Update" page, "Preferences" is added in the right of the menu. When you click it, the "Preferences" page is opened. The detail about the "Preferences" page is explained in the below.

The "Update" page has the form where you can input the date, title, and body of diary. Write your diary and put the "Add" button. By this procedure, the diary is added. Because this procedure is "Add", you don't have to show all the diary data if you write diary many times a day. Once you set the title of the diary, tDiary uses it. 

If you set date and click the "Edit this day" button, the title and body of the date are loaded(If the data is empty, these data are not loaded). In this case, the last button of the form is "Register"(Be careful. It is not "Add").

In tDiary, You use a bit specialized HTML in order to describe your diary. It is a little characteristic and it takes considerable time for some people to get accustomed to writing diary in this format. Please read HOWTO-write-diary.
 
=== Configuration with browser

When you click the "Preferences" button in the "Update" page, the "Preferences" page is shown. Here, you can configure many items with browser. In the "Preferences" page, each item has explanation. When you change a item, it is good to refer to explanation. Though the "Preferences" page has many "OK" buttons, their role is the same. When any "OK" button is clicked, all the items are stored to the configuration file. These buttons are located for the purpose of convenience. 

The configuration which is done with browser is stored as "tdiary.conf", which is located in the "@data_path" directory. This "tdiary.conf" is not the "tdiary.conf" which you edit manually. This file is normally loaded after the original "tdiary.conf" is loaded, so the values of the CGI "tdiary.conf" has priority over the values of the original "tdiary.conf". (If you edit the original "tdiary.conf", you can change the timing of loading the cgi "tdiary.conf")
 
=== Read Diary
When you read your diary, tDiary provides the three kind of the pages, "Latest", "Monthly", and "Daily". In default, tDiary shows "Latest" page. You can read the "Monthly" page if you click the link of the calendar located at the beginning of the page. And you can read the "Daily" page if you click the date.

There is difference between "Latest"/"Monthly" and "Daily" page. In "Latest"/"Monthly" page, today's TSUKKOMIs and today's links are partly omitted. On the other hand, "Daily" page shows all the TSUKKOMIs and links. And, "Daily" page has the form for TSUKKOMI. 

Every month, day, section, and TSUKKOMI has an anchor, and diary readers can link other place to it. Because each anchor is also a link, you can know the URL of it if you move pointer to it. 

With small devices, for instance, mobile phone, Zaurus and Palm, you can't use some of the features above because of restriction on data amount. When you access the diary with small devices, the "Latest" page shows the page which contains only one latest diary. You can move from this page to previous day page or next day page. 

=== And ...
Now, All you have to do is that you write diary ( But, it is the most difficult to continue to write diary:-) ). Have fun.!!

== License 
tDiary is free software created by TADA Tadashi(sho@spc.gr.jp). tDiary is licensed under the terms of GPL. You can distribute and modify it under the terms of GPL. 

But, all the files that are in "erb/" directory is ERb library created by Seki-san. 
You can know the detail about the license of these files at http://www2a.biglobe.ne.jp/~seki/ruby/.

And, authors of all the plugins and themes have its copyright. All the plugins can be distributed and modified under the terms of GPL. Most themes are also under GPL, but some have original license. See each theme file.

tDiary is developed on https://sourceforge.net/projects/tdiary/.
=end
