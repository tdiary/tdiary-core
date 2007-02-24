#
# en/spamfilter.rb: resource of en $Revision: 1.11 $
#

@spamfilter_label_conf = 'spam filter'

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
	<p><select name="spamfilter.linkcheck">
		<option value="0"#{' selected' if @conf['spamfilter.linkcheck'] == 0}>Receiving all TrackBack without checking it's contents.</option>
		<option value="1"#{' selected' if @conf['spamfilter.linkcheck'] == 1}>Checking which TrackBack sender has any links to my site.</option>
	</select></p>

	<h3>Date</h3>
	<p>It is spam that TSUKKOMI was made into<br>
		<input type="text" name="spamfilter.date_limit" value="#{h @conf['spamfilter.date_limit']}" size="5">days before (null: no limit, 0: only today)
	</p>

	<h3>IP address filters</h3>
	<p>It is spam when sender IP address matches these patterns. You have to specify complete IP address or part of IP address ends by '.'.<br>
		<textarea name="spamfilter.bad_ip_addrs" cols="60" rows="8">#{h( @conf['spamfilter.bad_ip_addrs'] || '' )}</textarea></p>
	</p>
	<p>It is spam when IP address of TrackBack sender dose not match with IP address of the site.<br>
		<select name="spamfilter.resolv_check">
			<option value="true"#{" selected" if @conf['spamfilter.resolv_check']}>ON</option>
			<option value="false"#{" selected" unless @conf['spamfilter.resolv_check']}>OFF</option>
	</select></p>
	<p>Which dou you want to do spam TrackBack finally?<br>
		<select name="spamfilter.resolv_check_mode">
			<option value="true"#{" selected" if @conf['spamfilter.resolv_check_mode']}>hide</option>
			<option value="false"#{" selected" unless @conf['spamfilter.resolv_check_mode']}>dispose</option>
		</select>
	</p>
   <h3>Domain Blacklist Services</h3>
   <p>List of Domain Blacklist Services</p>
   <p><textarea name="spamlookup.domain.list" cols="70" rows="5">#{h @conf['spamlookup.domain.list']}</textarea></p>
   <p>List of Safe Domain. Example for search engine.</p>
   <p><textarea name="spamlookup.safe_domain.list" cols="70" rows="5">#{h @conf['spamlookup.safe_domain.list']}</textarea></p>
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
	<p>File name of debug log.<br>
		<input type="text" name="spamfilter.debug_file" value="#{h( @conf['filter.debug_file'] || '' )}" size="30"></p>
	HTML
	end

	r
end
