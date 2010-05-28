# -*- coding: utf-8 -*-
def label_pingback_exclue; 'Pingback記録除外リスト'; end
add_conf_proc( 'Pingback', 'Pingback') do
	saveconf_pingback
	pingback_init

	<<-HTML
	<h3 class="subtitle">PingbackサーバのURL</h3>
	<p><input name="pingback.url" value="#{h(@conf['pingback.url'])}" size="100"></p>
	<h3 class="subtitle">キャッシュの有効時間</h3>
	<p><input name="pingback.expire" value="#{h(@conf['pingback.expire'])}" size="6">秒間</p>
	<h3 class="subtitle">Pingback記録除外リスト</h3>
	<p><textarea name="pingback.exclude" cols="70" rows="10">#{h( @conf['pingback.exclude'] )}</textarea></p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
