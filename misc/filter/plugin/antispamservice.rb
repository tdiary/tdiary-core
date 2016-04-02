#
# antispamservice.rb: tDiary comment spam filter using API setup plugin. $Revision: 1.3 $
#
# Copyright (C) TADA Tadashi <sho@spc.gr.jp> 2007.
# Modified by SHIBATA Hiroshi <shibata.hiroshi@gmail.com> 2008.
# Distributed under GPL2 or any later version.
#

require 'net/http'
require 'uri'

@antispam_service_list = {
	# Service => ServiceHost
	'Akismet' => 'rest.akismet.com',
}

add_conf_proc( 'antispamservice', @antispam_label_conf, 'security' ) do
	antispam_conf_proc
end

def antispam_conf_proc
	verify = true
	if @mode == 'saveconf' then
		@conf['antispam.service'] = @cgi.params['antispam.service'][0]
		@conf['antispam.key'] = @cgi.params['antispam.key'][0]
		if (@conf['antispam.key'] || '').length > 0 then
			verify = antispam_verify_key?(@conf['antispam.service'], @conf['antispam.key'] )
		end
	end

	result = <<-HTML
		<p>#{@antispam_desc}</p>

		<h3>#{@antispam_label_service}</h3>
	HTML

	options = ''
	@antispam_service_list.each_key do |key|
		options << %Q|<option value="#{h key}"#{" selected" if @conf['antispam.service'] == key}>#{h key}</option>\n|
	end

	result << <<-HTML
		<p><select name="antispam.service">
			#{options}
		</select></p>

		<h3>#{@antispam_label_key}</h3>
	HTML

	unless verify then
		result << %Q[<p class="message">#{@antispam_warn_key}</p>]
	end
	result << <<-HTML
		<p>#{@antispam_desc_key}: <input name="antispam.key" value="#{h( @conf['antispam.key'] || '')}" size="15"></p>
	HTML
end

def antispam_verify_key?( host, key )
	uri = URI::parse( "http://#{@antispam_service_list[host]}/1.1/verify-key")
	blog = @conf.index.dup
	blog[0, 0] = base_url unless %r|^https?://|i =~ blog
	blog.gsub!( %r|/\./|, '/' )
	data = "key=#{key}&blog=#{blog}"
	header = {
		'User-Agent' => "tDiary/#{TDIARY_VERSION} | Antispam filter",
		'Content-Type' => 'application/x-www-form-urlencoded'
	}
	proxy_h, proxy_p = (@conf['proxy'] || '').split( /:/ )
	res = ::Net::HTTP::Proxy( proxy_h, proxy_p ).start( uri.host, uri.port ) do |http|
		http.post( uri.path, data, header )
	end
	return (res.body == 'valid')
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
