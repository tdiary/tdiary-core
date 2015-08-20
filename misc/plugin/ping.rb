# ping.rb
#
# ping to weblog ping servers.
#
# Copyright (c) 2004 TADA Tadashi <sho@spc.gr.jp>
# Distributed under the GPL2 or any later version.
#
# Modified: by MoonWolf <moonwolf@moonwolf.com>
#
add_update_proc do
	if @conf['ping.list'] then
		list = @conf['ping.list'].split
		ping( list ) unless list.empty?
	end
end

def ping( list )
	return unless @cgi.params['plugin_ping_send'][0] == 'true'

	xml = to_utf8( <<-XML )
<?xml version="1.0" encoding="UTF-8"?>
<methodCall>
  <methodName>weblogUpdates.ping</methodName>
  <params>
    <param>
      <value>#{@conf.html_title}</value>
    </param>
    <param>
      <value>#{base_url}</value>
    </param>
  </params>
</methodCall>
	XML

	require 'net/http'
	require 'timeout'
	threads = []
	list.each do |url|
		u = URI::parse( url.untaint )
		next unless u.host
		threads << Thread.start( u, xml ) do |u, xml|
			begin
				Timeout::timeout( @conf['ping.timeout'].to_i ) do
					Net::HTTP.start( u.host, u.port ) do |http|
						http.post( u.path, xml, 'Content-Type' => 'text/xml' )
					end
				end
			rescue Exception,Timeout::Error
			end
		end
	end
	threads.each {|t| t.join }
end

add_conf_proc( 'ping', @ping_label_conf, 'update' ) do
	ping_conf_proc
end

def ping_conf_proc
	if @mode == 'saveconf' then
		@conf['ping.list'] = @cgi.params['ping.list'][0]
		@conf['ping.timeout'] = @cgi.params['ping.timeout'][0]
	end
	@conf['ping.list'] = '' unless @conf['ping.list']
	@conf['ping.timeout'] = '3' unless @conf['ping.timeout']

	<<-HTML
		<h3>#{@ping_label_list}</h3>
		<p>#{@ping_label_list_desc}</p>
		<p><textarea name="ping.list" cols="70" rows="5">#{h( @conf['ping.list'] )}</textarea></p>
		<h3>#{@ping_label_timeout}</h3>
		<p><input type="text" name="ping.timeout" value="#{h( @conf['ping.timeout'] )}" /></p>
	HTML
end

add_edit_proc do
	ping_edit_proc
end

def ping_edit_proc
	checked = ' checked'
	if @mode == 'preview' then
		checked = @cgi.params['plugin_ping_send'][0] == 'true' ? ' checked' : ''
	end
	<<-HTML
	<div class="ping"><label for="plugin_ping_send">
	<input type="checkbox" id="plugin_ping_send" name="plugin_ping_send" value="true"#{checked}  tabindex="400">
	#{@ping_label_send}
	</label></div>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
