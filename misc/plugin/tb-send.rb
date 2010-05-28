# tb-send.rb
#
# Copyright (c) 2003 Junichiro Kita <kita@kitaj.no-ip.com>
# You can distribute this file under the GPL.
#

add_edit_proc do |date|
	url =  @conf.to_native( @cgi.params['plugin_tb_url'][0] || '' )
	excerpt =  @conf.to_native( @cgi.params['plugin_tb_excerpt'][0] || '' )
	section = @cgi.params['plugin_tb_section'][0] || ''
	select_sections = ''
	unless @conf['tb.no_section'] then
		section_titles = ''
	 	idx = 1
		selected = false
		diary = @diaries[@date.strftime('%Y%m%d')]
		if diary then
			diary.each_section do |t|
				anc = 'p%02d' % idx
				if section == anc then
					focus = ' selected'
					selected = true
				else
					focus = ''
				end
				section_titles << %[<option value="#{h( anc )}"#{h( focus )}>#{h( apply_plugin( t.subtitle_to_html, true ) ).chomp}</option>\n\t\t\t]
				idx += 1
			end
		end
		anc = 'p%02d' % idx
		section_titles << %[<option value="#{h( anc )}"#{selected ? '' : ' selected'}>#{h( @tb_send_label_current_section )}</option>]
	
		select_sections = <<-FROM
			<div class="field">
			#{@tb_send_label_section}: <select name="plugin_tb_section" tabindex="501">
			<option value="">#{@tb_send_label_no_section}</option>
			#{section_titles}
			</select>
			</div>
		FROM
	end

	<<-FORM
		<h3 class="subtitle">TrackBack</h3>
		<div class="trackback">
			<div class="field title">
			#{@tb_send_label_url}: <textarea tabindex="500" style="height: 2em;" name="plugin_tb_url" cols="40" rows="1">#{h( url )}</textarea>
			</div>
			#{select_sections}
			<div class="textarea">
			#{@tb_send_label_excerpt}: <textarea tabindex="502" style="height: 4em;" name="plugin_tb_excerpt" cols="70" rows="4">#{h( excerpt )}</textarea>
			</div>
		</div>
	FORM
end

add_update_proc do
	tb_send_trackback if /^(append|replace)$/ =~ @mode
end

def tb_send_trackback
	urls = (@cgi.params['plugin_tb_url'][0] || '').split
	return if urls.size == 0

	title = @cgi.params['title'][0]
	excerpt = @cgi.params['plugin_tb_excerpt'][0]
	section = @cgi.params['plugin_tb_section'][0]
	blog_name = @conf.html_title

	date = @date.strftime( '%Y%m%d' )
	if section && !section.empty? then
		diary = @diaries[date]
		ary = []; diary.each_section{|s| ary << s}
		section = sprintf( 'p%02d', ary.length ) if @mode == 'append'
		num = section[1..-1].to_i - 1
		if num < ary.size
			title = ary[num].subtitle_to_html if ary[num].subtitle && !ary[num].subtitle.empty?
			excerpt = ary[num].body_to_html if excerpt.empty?
		end
	end

	if !excerpt || excerpt.empty?
		excerpt = @diaries[date].to_html({})
	end

	old_apply_plugin = @options['apply_plugin']
	@options['apply_plugin'] = true
	title = apply_plugin( title, true )
	if respond_to?( :category_anchor ) or respond_to?( :blog_category ) then
		title.sub!( /^(\[([^\[]+?)\])+ */, '' )
	end
	excerpt = apply_plugin( excerpt, true )
	@options['apply_plugin'] = old_apply_plugin

	#if excerpt.length >= 255 then
	#	excerpt = @conf.shorten( excerpt.gsub( /\r/, '' ).gsub( /\n/, "\001" ), 252 ).gsub( /\001/, "\n" )
	#end

	my_url = %Q|#{@conf.index}#{anchor(@date.strftime('%Y%m%d'))}|
	my_url[0, 0] = @conf.base_url if %r|^https?://|i !~ @conf.index
	my_url += "##{section}" if section && !section.empty?
	my_url.gsub!( %r|/\./|, '/' )
 
	require 'net/http'
	urls.each do |url|
		trackback = "url=#{u my_url}"
		trackback << "&title=#{u to_utf8( title )}" unless title.empty?
		trackback << "&excerpt=#{u to_utf8( excerpt )}" unless excerpt.empty?
		trackback << "&blog_name=#{u to_utf8( blog_name )}"

		if %r|^http://(?:(.+):(.+)@)?([^/]+)(/.*)$| =~ url then
		   basic_user = $1
			basic_pass = $2
			request = Net::HTTP::Post.new( $4 )
			request['Content-Type'] = "application/x-www-form-urlencoded; charset=utf-8"
			host, port = $3.split( /:/, 2 )
			port = '80' unless port
			Net::HTTP.version_1_1
			begin
				Net::HTTP.start( host.untaint, port.to_i ) do |http|
				   if basic_user && basic_pass
					   request.basic_auth(basic_user, basic_pass)
					end
					response, = http.request(request, trackback)
					error, = response.body.scan(%r|<error>(\d)</error>|)[0]
					if error == '1'
						reason, = response.body.scan(%r|<message>(.*)</message>|m)[0]
						raise TDiaryTrackBackError.new(reason) if urls.length == 1
					end
				end
			rescue
				raise TDiaryTrackBackError.new( "when sending TrackBack Ping: #{$!.message}" ) if urls.length == 1
			end
		else
			raise TDiaryTrackBackError.new( "unknown URL: #{url}" ) if urls.length == 1
		end
	end
end

def tb_send_utf8( str )
	@conf.to_native( str )
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
