= tDiary -- Commentable Web-log
tDiary is so called Web-log. tDiary has these features.

== features

=== You can change the configuration with browser.
You can not only read diary, but also write diary, and change the configuration with browser. With tDiary, you can easily use and maintain Web-log system. And you continue to write diary for a long time.

=== Comment
It is possible for diary readers to comment your diary. In other words, tDiary is equiped with BBS. With this BBS, you can communicate with your diary readers. tDiary can inform the author of a new comment by mail.

=== today's link(Referer)
#(そもそもこの一文が理解できるのか?)
When people links their diary to your diary, 
tDiary shows its URL by the analysis of the referer header. This feature is supported in many japanese web-log systems. In tDiary, this feature is more user-friendly.

=== small devices -- PDA or mobile phone
You can read your diary with PDA or mobile phone, for example, i-mode, Palm, Zaurus, and so on. When you access the same URL as usual, tDiary creates a page for PDA or mobile phone. The page for small devices are small and suitable for reading with them. 

=== theme -- CSS 
You can change the look of the diary by CSS. In tDiary, this feature is called 'theme'. tDiary package has some themes. Of course, you can create a new theme. You can change the theme with browser.

# 個々のプラグインの説明がないのに訳すことは出来ません。
#=== Plugin 
#By plugins, you can add new features to tDiary, and change the existing feature of tDiary. The detail is available from HOWTO-use-plugin.html and HOWTO-make-plugin.html.

=== Written in Ruby
Important :-). tDiary requires Ruby-1.6.3 or later.

=== Others
tDiary also supports these features.

* Section anchor 
* Read the past diaries

# セクションの概念は自明ではないでしょう。

== Installation and Configuration 
In this manual, we presume this environment as one example.

* WWW server: Apache 1.3.x
* User: foo
* Diary URL: http://www.bar.example.org/~foo/diary/
* Diary Path: /home/foo/public_html/diary/

=== CGI script configuration
Unpack the archive, and copy all the files to "/home/foo/public_html/diary/". You must change the permission of the two file, which are executed as CGI script.

* index.rb
* update.rb

If you use tDiary in an environment where the command "/usr/bin/env" can't be used, you need to edit these files and change their front line so that it stands for the Ruby executable. Except the case when you install Ruby under your home directory, you may be not careful about this thing.  

=== .htaccess 
Next, you arrange the CGI environment. You copy "dot.htaccess" as ".htaccess". And, edit it. The file "dot.htaccess" is like this;

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

This "dot.htaccess" configures these things.

* makes it pobssible to use CGI.
* makes the file whose suffix is ".rb" recongnized as the CGI script.
* sets the "index.rb" to the defatul file.
* prohibits the access to "*.rhtml" and "tdiary.*"
* When you access the "update.rb", the authentification is needed.

At least, you must change the "AuthUserFile" and "Require User" items. In Addition to it, you must create the the file of "AuthUserFile" by "htpasswd" command before you access your diary. If you don't know the "AuthUserFile" and "Require users", please examine these words.

If your WWW server doesn't allow you to change the suffix of the CGI script, you need to change the "AddHandeler" or "DirectoryIndex" item. In this case, you may need to change the filename of "index.rb" or "update.rb".

=== creation of tdiary.conf
You copy "tdiary.conf.sample" as "tdiary.conf" and edit "tdiary.conf". This is loaded as the Ruby script by the CGI scripts, for example, "index.rb" and "update.rb". With tDiary, you can do configuration with browser, so the item that you must change is "@data_path", which is first appeared in "tdiary.conf.sample".

   @data_path = "/home/foo/diiary"

In the "@data_path" item, you specify the directory where your diary data are stored. This item is usually set to the directory which can not be accesssed through WWW. In additin to it, you must set the permission of this directory so that the WWW server can access it.

In "tdiary.conf", you can configure many items. They are devided into three categories.

==== The items which you can't set with browser
Like "@data_path", these are the items which you can't change with browser. These items are configured only by editing the "tdiary.conf".

==== The items which you can set with browser
When you click the menu, "preferences", you can change your configuration through browser. Almost all the items are changed through browser. You don't have to edit the 'tdiary.conf' directly. 

==== The items to which you can add values with browser
"tdiary.conf" has some items to which are added a value with browser, for example, the ignored links and the rules which convert a URL. By editing the "tdiary.conf", you can set the default values(This is meaningful if you use multi-user mode). 


=== configuration
The meaning of the item is explained in "tdiary.conf.sample". Generally speaking, you can change the configuration with browser after you configure @data_path. If you want to receive a new comment by mail, you configure the @smtp_host and @smtp_port.

If you run the tDiary in the environment where you can't use the suffix, ".rb", as the CGI script, you change the file name of "index.rb" and "update.rb". In this case, you must configure @index and @update.

After you finish configuration, access "http://www.hoge.example.org/~foo/diary/". If you can see the empty page, tDiary works well. Unfortunately, if you encounter "Internal Server Error", you change configuration. The error-log of apache is useful in order to investigate the cause.    

== Secutiry 
"tdiary.conf" has the item which change the security level. If you use tDiary on your own server, you may not care about security. But, if you lend tDiary or provide the service of web-log, you need restriction.

In these cases, you set security level in "tdiary.conf". Normally, these two lines exists in the end of the "tdiary.conf.sample".

  @secure = false
  load_cgi_conf

By changing @secure, you set security level. If this is false, no security check is carried out. If no security check is executed, the user can change tDiary indulgently. When you run tDiary under the dangerous circumstance, you set @secure to true. If you do it, the dangerous operation, for example, file operation or variable assignment, is prohibited in loading "tdiary.conf".

# プラグインの説明がないので、省略します。
# The "@secure" affects the plugin.
# If security check is carried out, you can't use some plugins.

"load_cgi_conf" is the function which loads the tDiary's configuration file of CGI. In this example, the CGI configuration file is loaded after the security level is configured.

Because you can change the positions of "load_cgi_conf" and @secure indepedently, you can do detailed configuration. If you omit @secure, @secure is set to the default value, true.

== run tDiary 

=== update the diary

# ここの""で囲まれた文字はtDiaryの日記に表示させるボタンに使ってください。


In the beginning of the diary page, there are two link, "top" and "update". When you click "top", you move to the page which is specified by "@index_page". When you click "update", you move to the page which has the form in order to update your diary. If the authentification dialog doesn't appear in clicking "update", there is possibility that your ".htaccess" is wrong.

The "update" page also has the menu in its beginning. In "update" page, "preferences" is added in the right of the menu. When you click it, the "preferences" page is opened. The detail about the "preferences" page is explained in the below.

The "update" page has the form where you can input the date, title, and body of the diary. Write your diary and put the "add" button. By this procedure, the diary is added. Because this procedure is "add", you don't have to show all the diary data if you write diary many times a day. Once you set the title of the diary, tDiary uses it. 

If you set the date and click the "edit the diary of this date" button, the title and body of the date are loaded(If the data is empty, these data are not loaded.). In this case, the last button of the form is "register"(Be careful. It is not "add").

In tDiary, You use a bit specialized HTML in order to describe your diary. It is a little characteristic and it takes considerable time for some people to get accustomed to writing diary in this format. Please read HOWTO-write-diary.
 
== Configuration with browser

# 設定ページを英訳してください。

When you click the "preferences" button in the "update" page, the "preferences" page is shown. Here, you can configure many items with browser. In the "preferences" page, each items has explanation. When you change a item, it is good to refer to this explanation. Though the "preferences" page has many "OK" buttons, their role is the same. When any "OK" button is clicked, all the items are stored to the configuration file. These buttons are located for the purpose of convenience. 

The configuration which is done with browser is stored as the "tdiary.conf", which is located in the "@data_path" directory. This "tdiary.conf" is not the "tdiary.conf" which you edit manually. This file is normally loaded after the original "tdiary.conf" is loaded, so the values of the CGI "tdiary.conf" has priority over the values of the original "tdiary.conf". (If you edit the original "tdiary.conf", you can change the timing of loading the cgi "tdiary.conf")
 
== Read Diary
When you read your diary, tDiary provides the three kind of the pages, "Latest", "Monthly", and "Daily". In default, tDiary shows "Latest" page. You can read the "Monthly" page if you click the link of the calendar located in the beginning of the page. And you can read the "Daily" page if you click the date.

There is difference between "Latest"/"Monthly" and "Daily" page. In "Latest"/"Monthly" page, today's comments and today's links are partly omitted. On the other hand, "Daily" page shows all the comments and links. And "Daily" page has the form for comment. 

# 意味がわかりません。(みずほ)
# ツッコミをしてもらいたかったら、読者を日別ページに誘導するように、ヘッダ(@header)を工夫する必要があるかも知れません 

Every month, day, section, and comment has an anchor, and diary readers can link other place to it. Because each anchor is also a link, you can know the URL of it if you move pointer to it. 

With Small devices, for instance, mobile phone, Zaurus, Palm, you can't use some of the above features because of restriction on data amount. When you access the diary with small devices, the "Latest" page shows the page which contains only one latest diary. You can move from this page to previous day page or next day page. 

#プラグインのReadmeがないと、意味がないので、無視します。（みずほ）
#プラグインによるカスタマイズ
#
#　tDiaryにはプラグインと呼ばれる機能があります。プラグインを追加することで、tDiaryの機能を増やしたり、変更したりすることが可能です。プラグインについての詳しい説明は、HOWTO-use-plugin.html(使い方)・HOWTO-make-plugin.html(作り方)を参照してください。

=== And ...
The last thing you do is that you write diary ( But, it is the most difficult to continue to write diary:-) ). Have fun.!!

== License 
tDiary is free software created by Tadatadashi(sho@spc.gr.jp). tDiary is licensed under the terms of GPL. You can distribute and modify it under the terms of GPL. 

But, all the files that are in "erb/" directory is ERb library created by Seki-san. 
You can know the detail about the license of these files from http://www2a.biglobe.ne.jp/~seki/ruby/.

#　また、tDiaryフルセットに付属するテーマ、プラグインはすべて、それぞれの原作者が著作権を有します。配布条件も必ずしもGPLではありません。個々のファイルを参照してください。
#　tDiaryはhttp://www.tdiary.net/でサポートを行っています。ご意見・ご要望はこちらへどうぞ。パッチ歓迎です。
