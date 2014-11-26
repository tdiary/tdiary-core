# -*- coding: utf-8 -*-
=begin
= A little bit more powerful display of referrers((-$Id: disp_referrer.rb,v 1.20 2008-03-02 09:01:46 kazuhiko Exp $-))
English resource

== Copyright notice
Copyright (C) 2003 zunda <zunda at freeshell.org>

Please note that some methods in this plugin are written by other
authors as written in the comments.

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL version 2 or later.
=end

=begin ChangeLog
See ../ChangeLog for changes after this.

* Mon Sep 29, 2003 zunda <zunda at freeshell.org>
- forgot to change arguments after changing initialize()
* Thu Sep 25, 2003 zunda <zunda at freeshell.org>
- name.untaint to eval name
* Thu Sep 25, 2003 zunda <zunda at freeshell.org>
- use to_native instead of to_euc
* Mon Sep 19, 2003 zunda <zunda at freeshell.org>
- disp_referrer2.rb,v 1.1.2.104 commited as disp_referrer.rb
* Mon Sep  1, 2003 zunda <zunda at freeshell.org>
- more strcit check for infoseek search enigne
* Wed Aug 27, 2003 zunda <zunda at freeshell.org>
- rd.yahoo, Searchalot, Hotbot added
* Tue Aug 12, 2003 zunda <zunda at freeshell.org>
- search engine list cleaned up
* Mon Aug 11, 2003 zunda <zunda at freeshell.org>
- instance_eval for e[2] in the search engine list
* Wed Aug  7, 2003 zunda <zunda at freeshell.org>
- WWW browser configuration interface
  - キャッシュの更新をより確実にするようにしました。WWWブラウザから置換
    リストを作った場合にはリストの最初に追加されます。
  - secure=trueな日記でその他のリンク元リストが表示できるようになりました。
- Regexp generation for Wiki sites
* Wed Aug  6, 2003 zunda <zunda at freeshell.org>
- WWW browser configuration interface
  - 主なオプションとリンク元置換リストの効率的な編集がWWWブラウザからで
    きるようになりました。secure=trueな日記では一部の機能は使えません。
* Sat Aug  2, 2003 zunda <zunda at freeshell.org>
- Second version
- basic functions re-implemented
  - オプションを命名しなおしました。また不要なオプションを消しました。
    tdiary.confを編集していた方は、お手数ですが設定をしなおしてください。
  - Noraライブラリとキャッシュの利用で高速化しました。
  - 検索エンジンのリストをプラグインで持つようになりました。&や;を含む検
    索文字列も期待通りに抽出できます。
* Mon Feb 17, 2003 zunda <zunda at freeshell.org>
- First version
=end

# Message strings
Disp_referrer2_name = 'Referrer classification'.taint
Disp_referrer2_abstract = <<'_END'.taint
<p>
	This plugin distinguishes the URLs from antennas and search engines
	and shows them separately. Search keywords from different engines are
	compound together.
</p>
_END
Disp_referrer2_cache_info = <<'_END'.taint
<p>
	Total size of the caches is %1$s byte(s).
</p>
_END
Disp_referrer2_update_info = <<'_END'.taint
<p>
	Please clear the cache by checking this box:
  <label for="dr2.cache.update"><input id="dr2.cache.update" name="dr2.cache.update" value="force" type="checkbox">clear the cache</label>,
	and clicking OK
	after editing the <a href="%1$s">today's link</a> lists.
</p>
_END
Disp_referrer2_move_to_refererlist = <<'_END'.taint
	<a href="%s">Follow this link</a> to edit the referer lists.
_END
Disp_referrer2_move_to_config = <<'_END'.taint
	<a href="%s">Follow this link</a> to configure the plug-in.
_END
Disp_referrer2_also_todayslink = <<'_END'.taint
	Referer list can also be edited via &quot;<a href="%s">Today's link</a>&quot;.
_END
Disp_referrer2_antenna_label = 'Antennae'.taint
Disp_referrer2_unknown_label = 'Others'.taint
Disp_referrer2_search_label = 'Search engines'.taint
Disp_referrer2_search_unknown_keyword = 'Unknown keyword'.taint
Disp_referrer2_cache_label = '(cache from %s)'.taint

class DispRef2SetupIF

	# show options
	def show_options
		r = <<-_HTML
			<h3>Categorization and display of referrer URLs</h3>
			<input name="dr2.current_mode" value="#{Options}" type="hidden">
			<table>
			<tr>
				<td><label for="dr2.unknown.divide.true"><input id="dr2.unknown.divide.true" name="dr2.unknown.divide" value="true" type="radio"#{' checked'if @setup['unknown.divide']}>Separate #{DispRef2String::escapeHTML(@setup['unknown.label'])}</label>
				<td><label for="dr2.unknown.divide.false"><input id="dr2.unknown.divide.false" name="dr2.unknown.divide" value="false" type="radio"#{' checked'if not @setup['unknown.divide']}>Treat #{DispRef2String::escapeHTML(@setup['unknown.label'])}</label> as normal links.
			</table>
			<table>
			<tr>
				<td><label for="dr2.unknown.hide.false"><input id="dr2.unknown.hide.false" name="dr2.unknown.hide" value="false" type="radio"#{' checked'if not @setup['unknown.hide']}>Show</label>
				<td><label for="dr2.unknown.hide.true"><input id="dr2.unknown.hide.true" name="dr2.unknown.hide" value="true" type="radio"#{' checked'if @setup['unknown.hide']}>Hide</label>
				separated #{DispRef2String::escapeHTML(@setup['unknown.label'])}.
			<tr>
				<td><label for="dr2.normal.categorize.true"><input id="dr2.normal.categorize.true" name="dr2.normal.categorize" value="true" type="radio"#{' checked'if @setup['normal.categorize']}>Use</label>
				<td><label for="dr2.normal.categorize.false"><input id="dr2.normal.categorize.false" name="dr2.normal.categorize" value="false" type="radio"#{' checked'if not @setup['normal.categorize']}>Don't use</label>
				strings inside [ and ] to categorize normal links.
			<tr>
				<td><label for="dr2.long.only_normal.false"><input id="dr2.long.only_normal.false" name="dr2.long.only_normal" value="false" type="radio"#{' checked'if not @setup['long.only_normal']}>Show</label>
				<td><label for="dr2.long.only_normal.true"><input id="dr2.long.only_normal.true" name="dr2.long.only_normal" value="true" type="radio"#{' checked'if @setup['long.only_normal']}>Hide</label>
				links other than normal URLs in the daily view.
			<tr>
				<td><label for="dr2.short.only_normal.false"><input id="dr2.short.only_normal.false" name="dr2.short.only_normal" value="false" type="radio"#{' checked'if not @setup['short.only_normal']}>Show</label>
				<td><label for="dr2.short.only_normal.true"><input id="dr2.short.only_normal.true" name="dr2.short.only_normal" value="true" type="radio"#{' checked'if @setup['short.only_normal']}>Hide</label>
				links other than normal URLs in the latest view.
			</table>
			<h3>Grouping of normal links</h3>
			<table>
			<tr>
				<td><label for="dr2.normal.group.true"><input id="dr2.normal.group.true" name="dr2.normal.group" value="true" type="radio"#{' checked'if @setup['normal.group']}>Group with the title strings</label>
				<td><label for="dr2.normal.group.false"><input id="dr2.normal.group.false" name="dr2.normal.group" value="false" type="radio"#{' checked'if not @setup['normal.group']}>Show each URLs</label>
				of normal links.
			<tr>
				<td><label for="dr2.normal.ignore_parenthesis.true"><input id="dr2.normal.ignore_parenthesis.true" name="dr2.normal.ignore_parenthesis" value="true" type="radio"#{' checked'if @setup['normal.ignore_parenthesis']}>Ignore</label>
				<td><label for="dr2.normal.ignore_parenthesis.false"><input id="dr2.normal.ignore_parenthesis.false" name="dr2.normal.ignore_parenthesis" value="false" type="radio"#{' checked'if not @setup['normal.ignore_parenthesis']}>don't ignore</label>
				the last parenthesis when grouping normal links with the titles.
			</table>
			<h3>Grouping of links from antennae</h3>
			<table>
			<tr>
				<td><label for="dr2.antenna.group.true"><input id="dr2.antenna.group.true" name="dr2.antenna.group" value="true" type="radio"#{' checked'if @setup['antenna.group']}>Group with the title strings</label>
				<td><label for="dr2.antenna.group.false"><input id="dr2.antenna.group.false" name="dr2.antenna.group" value="false" type="radio"#{' checked'if not @setup['antenna.group']}>Show each URLs</label>
				of links from antennae.
			<tr>
				<td><label for="dr2.antenna.ignore_parenthesis.true"><input id="dr2.antenna.ignore_parenthesis.true" name="dr2.antenna.ignore_parenthesis" value="true" type="radio"#{' checked'if @setup['antenna.ignore_parenthesis']}>ignore</labe>
				<td><label for="dr2.antenna.ignore_parenthesis.false"><input id="dr2.antenna.ignore_parenthesis.false" name="dr2.antenna.ignore_parenthesis" value="false" type="radio"#{' checked'if not @setup['antenna.ignore_parenthesis']}>don't ignore</labe>
				the last parenthesis when grouping links from antennae with the titles.
			</table>
			<h3>Keywords from search engines</h3>
			<table>
			<tr>
				<td><label for="dr2.search.expand.true"><input id="dr2.search.expand.true" name="dr2.search.expand" value="true" type="radio"#{' checked'if @setup['search.expand']}>Show</label>
				<td><Label for="dr2.search.expand.false"><input id="dr2.search.expand.false" name="dr2.search.expand" value="false" type="radio"#{' checked'if not @setup['search.expand']}>Don't show</label>
				the search engine names.
			</table>
		_HTML
		unless @setup.secure then
		r << <<-_HTML
			<h3>Cache</h3>
			<p>It isn't available to turn on this option with tDiary2 file format(DefaultIO).</p>
			<table>
			<tr>
				<td><label for="dr2.no_cache.false"><input id="dr2.no_cache.false" name="dr2.no_cache" value="false" type="radio"#{' checked'if not @setup['no_cache']}>Use</label>
				<td><label for="dr2.no_cache.true"><input id="dr2.no_cache.true" name="dr2.no_cache" value="true" type="radio"#{' checked'if @setup['no_cache']}>Don't use</label>
				cache.
			<tr>
				<td>Limit cache size to
				<td colspan="3"><input name="dr2.cache_max_size" value="#{DispRef2String::escapeHTML(@setup['cache_max_size'])}" type="text">Bytes.
			<tr>
				<td><label for="dr2.cache.update.force"><input id="dr2.cache.update.force" name="dr2.cache.update" value="force" type="radio">clear</label>
				<td><label for="dr2.cache.update.auto"><input id="dr2.cache.update.auto" name="dr2.cache.update" value="auto" type="radio" checked>clear if needed</label>
				<td><label for="dr2.cache.update.never"><input id="dr2.cache.update.never" name="dr2.cache.update" value="never" type="radio">don't clear</label>
				the cache at this time.
			</table>
			<p>Cache size limit is an approximation. There is a chance that the cache size is bigger than the configured value. Setting the limit to zero disalbes limitation. K or M can be suffixed meaning Kbytes or Mbytes.</p>
		_HTML
		end # unless @setup.secure
		r
	end

	# shows URL list to be added to the referer_table or no_referer
	def show_unknown_list
		if @setup.secure then
			urls = DispRef2Latest.new( @cgi, 'latest.rhtml', @conf, @setup ).unknown_urls
		else
			urls = DispRef2Cache.new( @setup ).urls( DispRef2URL::Unknown ).keys
			if urls.size == 0 then
				urls = DispRef2Latest.new( @cgi, 'latest.rhtml', @conf, @setup ).unknown_urls
			end
		end
		urls.reject!{ |url| DispRef2String::url_match?( url, @setup['reflist.ignore_urls'] ) }
		r = <<-_HTML
			<h3>URL Conversion</h3>
			<input name="dr2.current_mode" value="#{RefList}" type="hidden">
			<p>URLs that match the Ignore list are not listed here.</p>
		<p>
			If you don't want to see the URLs that you neither put into the
			Conversion list or the Excluding list can be put in the Ignore
			list. The Ignore list only affects the list shown here.
			Please check <input name="dr2.clear_ignore_urls" value="true"
			type="checkbox">here if you want to reset the Ignore list.
		</p>
		_HTML
		if urls.size > 0 then
			r << <<-_HTML
				<p>Please fill in the titles for the URL(s) in the lower text
					box(es) to put the URL(s) into the Conversion list. Please
					check the check box(es) if you want to put the URL(s) into the
					Excluding list.
				</p>
				<p>
					Regular expressions are made up automatically. You can edit them
					if you want.
				</p>
				<p>
					In the titles, you can refer to the strings between
					parenthesis in the regular expression with something like
					&quot;\\1&quot; (backslash plus a number). You can also use
					a script fragment like &quot;sprintf('[tdiary:%d]', $1.to_i+1)&quot;.
				</p>
			_HTML
			if @cgi.auth_type and @cgi.remote_user and @setup['configure.use_link'] then
				r << <<-_HTML
					<p>
						[NOTE] Be aware that by clicking the URLs below, the author
						of the www site might know the URL of this page to edit and
						configure your diary.
					</p>
				_HTML
			end
			r << <<-_HTML
				<p>
					Please edit URLs not shown here through &quot;<a
					href="#{DispRef2String::escapeHTML(@conf.update)}?conf=referer">Today's link</a>&quot;
				</p>
				<dl>
			_HTML
			i = 0
			urls.sort.each do |url|
				shown_url = DispRef2String::escapeHTML( @setup.to_native( DispRef2String::unescape( url ) ) )
				if @cgi.auth_type and @cgi.remote_user and @setup['configure.use_link'] then
					r << "<dt><a href=\"#{DispRef2String::escapeHTML(url)}\">#{shown_url}</a>"
				else
					r << "<dt>#{shown_url}"
				end
				r << <<-_HTML
					<dd>
						Add this URL to
						<label for="dr2.#{i}.noref"><input id="dr2.#{i}.noref" name="dr2.#{i}.noref" value="true" type="checkbox">Excluding list</label>
						<label for="dr2.#{i}.ignore"><input id="dr2.#{i}.ignore" name="dr2.#{i}.ignore" value="true" type="checkbox">Ignore list</label><br>
						<input name="dr2.#{i}.reg" value="#{DispRef2String::escapeHTML( DispRef2String::url_regexp( url ) )}" type="text" size="70"><br>
						<input name="dr2.#{i}.title" value="" type="text" size="70">
				_HTML
				i += 1
			end
			r << <<-_HTML
				<input name="dr2.urls" type="hidden" value="#{i}">
				</dl>
			_HTML
		else
			r << <<-_HTML
				<p>Currently there is no #{DispRef2String::escapeHTML(@setup['unknown.label'])}.</p>
			_HTML
		end
		r << <<-_HTML
			<h3>Regular expressions for antennae</h3>
			<p>URLs or titles matching these expression will be categorized as
				antennae.</p>
			<ul>
			<li>URL:
				<input name="dr2.antenna.url" value="#{DispRef2String::escapeHTML( @setup.to_native( @setup['antenna.url'] ) )}" type="text" size="70">
				<label for="dr2.antenna.url.default"><input id="dr2.antenna.url.default" name="dr2.antenna.url.default" value="true" type="checkbox">Use default</label>
			<li>Title:<input name="dr2.antenna.title" value="#{DispRef2String::escapeHTML( @setup.to_native( @setup['antenna.title'] ) )}" type="text" size="70">
				<label for="dr2.antenna.title.default"><input id="dr2.antenna.title.default" name="dr2.antenna.title.default" value="true" type="checkbox">Use default</label>
			</ul>
			_HTML
		r
	end

end

# Hash table of search engines
# key: company name
# value: array of:
# [0]:url regexp [1]:title [2]:keys for search keyword [3]:cache regexp
# keys - an Array of Strings for usual keys
#      - a String as a Ruby code to be sent to URL after regexp matching
#      - a Symbol to indicate the key contains URL to be recursively converted
DispReferrer2_Google_cache = /cache:[^:]+:([^+]+)+/
DispReferrer2_Engines = {
	'google' => [
		[%r{\Ahttp://(?:[^./]+\.)*?google\.([^/]+)/(search|custom|ie)}i, '"Google in .#{$1}"', ['as_q', 'q', 'as_epq'], DispReferrer2_Google_cache],
		[%r{\Ahttp://(?:[^./]+\.)*?google\.([^/]+)/.*url}i, '"Google URL search in .#{$1}"', ['as_q', 'q'], DispReferrer2_Google_cache],
		[%r{\Ahttp://(?:[^./]+\.)*?google/search}i, '"Google?"', ['as_q', 'q'], DispReferrer2_Google_cache],
		[%r{\Ahttp://eval.google\.([^/]+)}i, '"Google Accounts in .#{$1}"', [], nil],
		[%r{\Ahttp://(?:[^./]+\.)*?google\.([^/]+)}i, '"Google in .#{$1}"', [], nil],
	],
	'yahoo' => [
		[%r{\Ahttp://.*?\.rd\.yahoo\.([^/]+)}i, '"Yahoo! redirector.#{$1}"', 'split(/\*/)[1]', nil],
		[%r{\Ahttp://.*?\.yahoo\.([^/]+)}i, '"Yahoo! search in .#{$1}"', ['p', 'va', 'vp'], DispReferrer2_Google_cache],
	],
	'netscape' => [[%r{\Ahttp://.*?\.netscape\.([^/]+)}i, '"Netscape search in .#{$1}"', ['search', 'query'], DispReferrer2_Google_cache]],
	'msn' => [[%r{\Ahttp://.*?\.MSN\.([^/]+)}i, '"MSN search in .#{$1}"', ['q', 'MT'], nil ]],
	'metacrawler' => [[%r{\Ahttp://.*?.metacrawler.com}i, '"MetaCrawler"', ['q'], nil ]],
	'metabot' => [[%r{\Ahttp://.*?\.metabot\.ru}i, '"MetaBot.ru"', ['st'], nil ]],
	'altavista' => [[%r{\Ahttp://.*?\.altavista\.([^/]+)}i, '"Altavista in .#{$1}"', ['q'], nil ]],
	'infoseek' => [[%r{\Ahttp://(www\.)?infoseek\.co\.jp}i, '"Infoseek"', ['qt'], nil ]],
	'odn' => [[%r{\Ahttp://.*?\.odn\.ne\.jp}i, '"ODN検索"', ['QueryString', 'key'], nil ]],
	'lycos' => [[%r{\Ahttp://.*?\.lycos\.([^/]+)}i, '"Lycos in .#{$1}"', ['query', 'q', 'qt'], nil ]],
	'fresheye' => [[%r{\Ahttp://.*?\.fresheye}i, '"Fresheye"', ['kw'], nil ]],
	'goo' => [
		[%r{\Ahttp://.*?\.goo\.ne\.jp}i, '"goo"', ['MT'], nil ],
		[%r{\Ahttp://.*?\.goo\.ne\.jp}i, '"goo"', [], nil ],
	],
	'nifty' => [
		[%r{\Ahttp://search\.nifty\.com}i, '"@nifty/@search"', ['q', 'Text'], DispReferrer2_Google_cache],
		[%r{\Ahttp://srchnavi\.nifty\.com}i, '"@nifty redirector"', ['title'], nil ],
	],
	'eniro' => [[%r{\Ahttp://.*?\.eniro\.se}i, '"Eniro"', ['q'], DispReferrer2_Google_cache]],
	'excite' => [[%r{\Ahttp://.*?\.excite\.([^/]+)}i, '"Excite in .#{$1}"', ['search', 's', 'query', 'qkw'], nil ]],
	'biglobe' => [
		[%r{\Ahttp://.*?search\.biglobe\.ne\.jp}i, '"BIGLOBE search"', ['q'], nil ],
		[%r{\Ahttp://.*?search\.biglobe\.ne\.jp}i, '"BIGLOBE search"', [], nil ],
	],
	'dion' => [[%r{\Ahttp://dir\.dion\.ne\.jp}i, '"Dion"', ['QueryString', 'key'], nil ]],
	'naver' => [[%r{\Ahttp://.*?\.naver\.co\.jp}i, '"NAVER Japan"', ['query'], nil ]],
	'webcrawler' => [[%r{\Ahttp://.*?\.webcrawler\.com}i, '"WebCrawler"', ['qkw'], nil ]],
	'euroseek' => [[%r{\Ahttp://.*?\.euroseek\.com}i, '"Euroseek.com"', ['string'], nil ]],
	'aol' => [[%r{\Ahttp://.*?\.aol\.}i, '"AOL search"', ['query'], nil ]],
	'alltheweb' => [
		[%r{\Ahttp://.*?\.alltheweb\.com}i, '"AlltheWeb.com"', ['q'], nil ],
		[%r{\Ahttp://.*?\.alltheweb\.com}i, '"AlltheWeb.com"', [], nil ],
	],
	'kobe-u' => [
		[%r{\Ahttp://bach\.scitec\.kobe-u\.ac\.jp/cgi-bin/metcha.cgi}i, '"Metcha search engine"', ['q'], nil ],
		[%r{\Ahttp://bach\.istc\.kobe-u\.ac\.jp/cgi-bin/metcha.cgi}i, '"Metcha search engine"', ['q'], nil ],
	],
	'tocc' => [[%r{\Ahttp://www\.tocc\.co\.jp/search/}i, '"TOCC/Search"', ['QRY'], nil ]],
	'yappo' => [[%r{\Ahttp://i\.yappo\.jp/}i, '"iYappo"', [], nil ]],
	'suomi24' => [[%r{\Ahttp://.*?\.suomi24\.([^/]+)/.*query}i, '"Suomi24"', ['q'], DispReferrer2_Google_cache]],
	'earthlink' => [[%r{\Ahttp://search\.earthlink\.net/search}i, '"EarthLink Search"', ['as_q', 'q', 'query'], DispReferrer2_Google_cache]],
	'infobee' => [[%r{\Ahttp://infobee\.ne\.jp/}i, '"Infobee"', ['MT'], nil ]],
	't-online' => [[%r{\Ahttp://brisbane\.t-online\.de/}i, '"T-Online"', ['q'], DispReferrer2_Google_cache]],
	'walla' => [[%r{\Ahttp://find\.walla\.co\.il/}i, '"Walla! Channels"', ['q'], nil ]],
	'mysearch' => [[%r{\Ahttp://.*?\.mysearch\.com/}i, '"My Search"', ['searchfor'], nil ]],
	'jword' => [[%r{\Ahttp://search\.jword.jp/}i, '"JWord"', ['name'], nil ]],
	'nytimes' => [[%r{\Ahttp://query\.nytimes\.com/search}i, '"New York Times: Search"', ['as_q', 'q', 'query'], DispReferrer2_Google_cache]],
	'aaacafe' => [[%r{\Ahttp://search\.aaacafe\.ne\.jp/search}i, '"AAA!CAFE"', ['key'], nil]],
	'virgilio' => [[%r{\Ahttp://search\.virgilio\.it/search}i, '"VIRGILIO Ricerca"', ['qs'], nil]],
	'ceek' => [[%r{\Ahttp://www\.ceek\.jp}i, '"ceek.jp"', ['q'], nil]],
	'cnn' => [[%r{\Ahttp://websearch\.cnn\.com}i, '"CNN.com"', ['query', 'as_q', 'q', 'as_epq'], DispReferrer2_Google_cache]],
	'webferret' => [[%r{\Ahttp://webferret\.search\.com}i, '"WebFerret"', 'split(/,/)[1]', nil]],
	'eniro' => [[%r{\Ahttp://www\.eniro\.se}i, '"Eniro"', ['query', 'as_q', 'q'], DispReferrer2_Google_cache]],
	'passagen' => [[%r{\Ahttp://search\.evreka\.passagen\.se}i, '"Eniro"', ['q', 'as_q', 'query'], DispReferrer2_Google_cache]],
	'redbox' => [[%r{\Ahttp://www\.redbox\.cz}i, '"RedBox"', ['srch'], nil]],
	'odin' => [[%r{\Ahttp://odin\.ingrid\.org}i, '"ODiN"', ['key'], nil]],
	'kensaku' => [[%r{\Ahttp://www\.kensaku\.}i, '"kensaku.jp"', ['key'], nil]],
	'hotbot' => [[%r{\Ahttp://www\.hotbot\.}i, '"HotBot Web Search"', ['MT'], nil ]],
	'searchalot' => [[%r{\Ahttp://www\.searchalot\.}i, '"Searchalot"', ['q'], nil ]],
	'cometsystems' => [[%r{\Ahttp://search\.cometsystems\.com}i, '"Comet Web Search"', ['qry'], nil ]],
	'bulkfeeds' => [
	    [%r{\Ahttp://bulkfeeds\.net/app/search2}i, '"Bulkfeeds: RSS Directory & Search"', ['q'], nil ],
	    [%r{\Ahttp://bulkfeeds\.net/app/similar}i, '"Bulkfeeds Similarity Search"', ['url'], nil ],
	],
	'answerbus' => [[%r{\Ahttp://www\.answerbus\.com}i, '"AnswerBus"', [], nil ]],
	'dogplile' => [[%r{\Ahttp://www.\dogpile\.com/info\.dogpl/search/web/}i, '"AnswerBus"', [], nil ]],
	'www' => [[%r{\Ahttp://www\.google/search}i, '"Google?"', ['as_q', 'q'], DispReferrer2_Google_cache]],	# TLD missing
	'planet' => [[%r{\Ahttp://www\.planet\.nl/planet/}i, '"Planet-Zoekpagina"', ['googleq', 'keyword'], DispReferrer2_Google_cache]], # googleq parameter has a strange prefix
	'216' => [[%r{\Ahttp://(\d+\.){3}\d+/search}i, '"Google?"', ['as_q', 'q'], DispReferrer2_Google_cache]],	# cache servers of google?
}

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
