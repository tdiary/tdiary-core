# -*- coding: utf-8; -*-
#
# 05referer.rb: Traditional-Chinese resource of referer plugin
#
# Copyright (C) 2006, TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#

def referer_today; "今日鍊結"; end
def volatile_referer; "Links to old diaries"; end

def label_no_referer; "這是今天未列出的鍊結列表"; end
def label_only_volatile; "Volatile Links List"; end
def label_referer_table; "Today's Link Conversion Rule"; end

# referer
add_conf_proc( 'referer', "今日鍊結", 'referer' ) do
	saveconf_referer

	<<-HTML
	<h3 class="subtitle">是否秀出鍊結</h3>
	#{"<p>您可以選擇是否要秀出「今日鍊結」。 </p>" unless @conf.mobile_agent?}
	<p><select name="show_referer">
		<option value="true"#{" selected" if @conf.show_referer}>好</option>
		<option value="false"#{" selected" unless @conf.show_referer}>不要</option>
	</select></p>
	<h3 class="subtitle">#{label_no_referer}</h3>
	#{"<p>在「今日鍊結」裡不要記錄起來的鍊結。請以 regular expression 形式一行一行指定每個不想記錄的網址。 </p>" unless @conf.mobile_agent?}
	<p>請看<a href="#{h @update}?referer=no" target="referer">預設設定</a>。</p>
	<p><textarea name="no_referer" cols="70" rows="10">#{h @conf.no_referer2.join( "\n" )}</textarea></p>
	<h3 class="subtitle">#{label_only_volatile}</h3>
	#{"<p>List of URLs recorded to only volatile lists. This list will be clear when update diary in new day. Specify it in regular expression, and a URL into a line.</p>" unless @conf.mobile_agent?}
	<p>See <a href="#{h @update}?referer=volatile" target="referer">Default configuration is here</a>.</p>
	<p><textarea name="only_volatile" cols="70" rows="10">#{h @conf.only_volatile2.join( "\n" )}</textarea></p>
	<h3 class="subtitle">#{label_referer_table}</h3>
	#{"<p>將「今日鍊結」中特定的網址轉換為具意義的字面，請以 regular expression 形式一行一行指定每個要做字面轉換的網址。 <p>" unless @conf.mobile_agent?}
	<p>請看<a href="#{h @update}?referer=table" target="referer">預設設定</a>.</p>
	<p><textarea name="referer_table" cols="70" rows="10">#{h @conf.referer_table2.collect{|a|a.join( " " )}.join( "\n" )}</textarea></p>
	HTML
end
