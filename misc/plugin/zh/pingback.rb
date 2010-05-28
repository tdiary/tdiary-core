def label_pingback_exclue; "Pingback Excluding List"; end
add_conf_proc('Pingback', 'Pingback') do
	saveconf_pingback
	pingback_init

	<<-HTML
	<h3 class="subtitle">URL of Pingback server</h3>
	<p><input name="pingback.url" value="#{h(@conf['pingback.url'])}" size="100"></p>
	<h3 class="subtitle">expire time for cache</h3>
	<p><input name="pingback.expire" value="#{h(@conf['pingback.expire'])}" size="6">secs</p>
	<h3 class="subtitle">Pingback Excluding List</h3>
	<p><textarea name="pingback.exclude" cols="70" rows="10">#{h(@conf['pingback.exclude'])}</textarea></p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
