# -*- coding: utf-8; -*-
#
# en/10spamfilter.rb: resource of en
#

@spamfilter_label_conf = 'spam filter'
@dnsblfilter_label_conf = 'DNSBL filter'

def spamfilter_conf_html
	r = <<-HTML
	<h3>Basic filters</h3>
	<p>Which dou you want to do spam TSUKKOMI finally?<br>
			<select name="spamfilter.filter_mode">
			<option value="true"#{" selected" if @conf['spamfilter.filter_mode']}>hide</option>
			<option value="false"#{" selected" unless @conf['spamfilter.filter_mode']}>dispose</option>
		</select>
	</p>
	<p>It is spam when TSUKKOMI body has URIs over this value.<br>
		<input type="text" name="spamfilter.max_uris" value="#{h @conf['spamfilter.max_uris']}" size="5"></p>
	<p>It is spam when percentage of URI charctors in TSUKKOMI body is over this value.<br>
		<input type="text" name="spamfilter.max_rate" value="#{h @conf['spamfilter.max_rate']}" size="5"></p>
	<p>It is spam when TSUKKOMI body has URIs match with these patterns.<br>
		<textarea name="spamfilter.bad_uri_patts" cols="60" rows="8">#{h( @conf['spamfilter.bad_uri_patts'] || '' )}</textarea></p>
	<p>It is spam when TSUKKOMI body matches with these patterns.<br>
		<textarea name="spamfilter.bad_comment_patts" cols="60" rows="8">#{h( @conf['spamfilter.bad_comment_patts'] || '' )}</textarea></p>
	<p>It is spam when mail address matches with these patterns.<br>
		<textarea name="spamfilter.bad_mail_patts" cols="60" rows="8">#{h( @conf['spamfilter.bad_mail_patts'] || '' )}</textarea></p>
	<p>Use patterns of URI for checking mail address.<br>
		<select name="spamfilter.bad_uri_patts_for_mails">
			<option value="true"#{" selected" if @conf['spamfilter.bad_uri_patts_for_mails']}>ON</option>
			<option value="false"#{" selected" unless @conf['spamfilter.bad_uri_patts_for_mails']}>OFF</option>
		</select></p>

	<h3>Date</h3>
	<p>Javascript is used to display TSUKKOMI from into<br>
		<input type="text" name="spamfilter.date_limit" value="#{h @conf['spamfilter.date_limit']}" size="5">days before (null: no limit, 0: only today)
	</p>

	<h3>IP address filters</h3>
	<p>It is spam when sender IP address matches these patterns. You have to specify complete IP address or part of IP address ends by '.'.<br>
		<textarea name="spamfilter.bad_ip_addrs" cols="60" rows="8">#{h( @conf['spamfilter.bad_ip_addrs'] || '' )}</textarea></p>
	</p>
	<h3>Description of TSUKKOMI</h3>
	<p>Show messeges and spam conditions for your subscribers.<br><textarea name="comment_description" cols="70" rows="5">#{h comment_description}</textarea></p>
	HTML

	unless @conf.secure then
	r << <<-HTML
	<h3>for Debug</h3>
	<p>Debug mode.<br>
		<select name="filter.debug_mode">
			<option value="0"#{" selected" if @conf['filter.debug_mode'] == 0}>OFF</option>
			<option value="1"#{" selected" if @conf['filter.debug_mode'] == 1}>Only spam</option>
			<option value="2"#{" selected" if @conf['filter.debug_mode'] == 2}>Full</option>
		</select></p>
	HTML
	end

	r
end

def dnsblfilter_conf_html
	r = <<-HTML
	<h3>Domain Blacklist Services</h3>
	<p>List of IP based Domain Blacklist Services</p>
	<p><textarea name="spamlookup.ip.list" cols="70" rows="5">#{h @conf['spamlookup.ip.list']}</textarea></p>
	<p>List of Domain Blacklist Services</p>
	<p><textarea name="spamlookup.domain.list" cols="70" rows="5">#{h @conf['spamlookup.domain.list']}</textarea></p>
	<p>List of Safe Domain. Example for search engine.</p>
	<p><textarea name="spamlookup.safe_domain.list" cols="70" rows="10">#{h @conf['spamlookup.safe_domain.list']}</textarea></p>
	HTML

	r
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
