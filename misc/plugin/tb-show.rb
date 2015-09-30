# tb-show.rb
#
# functions:
#   * show TrackBack ping URL in right of TSUKKOMI label.
#   * hide TrackBacks in TSUKKOMI.
#   * show TrackBacks above Today's Links.
#
# options:
#	@options['tb.cgi']:
#		the TrackBack ping URL. './tb.rb' is default.
#	@options['tb.hide_if_no_tb']:
#		If true, hide 'TrackBacks(n)' when there is no TrackBacks.  Default value is false.
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL2 or any later version.
#
# Modified: by Junichiro Kita <kita@kitaj.no-ip.com>
#
#
# If you want to show TrackBack Ping URL under comment_new link, try this.
#
#	alias :comment_new_tb_backup :comment_new
#	def comment_new
#		cgi = @options['tb.cgi'] || './tb.rb'
#		url = "#{cgi}/#{@tb_date.strftime( '%Y%m%d' )}"
#		%Q|#{comment_new_tb_backup }</a>]<br>[TrackBack to <a href="#{@tb_url}">#{@tb_url}|
#	end
#

#
# show TrackBack ping URL
#
add_body_enter_proc do |date|
	cgi = File.basename(@options['tb.cgi'] || './tb.rb')
	@tb_date = date
	@tb_id_url = %Q|#{@index}#{anchor( @tb_date.strftime('%Y%m%d') )}|
	@tb_id_url[0, 0] = base_url if %r|^https?://|i !~ @conf.index
	@tb_id_url.gsub!( %r|/\./|, '/' )
	@tb_url = %Q|#{base_url}#{cgi}/#{@tb_date.strftime('%Y%m%d')}|
	''
end

#
# make RDF
#
if @mode == 'day' and not bot? then
	add_body_leave_proc do |date|
		if @tb_url and @diaries[@tb_date.strftime('%Y%m%d')] then
			<<-TBRDF
<!--
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/">
<rdf:Description
	rdf:about="#{h @tb_id_url}"
	dc:identifier="#{h @tb_id_url}"
	dc:title="#{h( apply_plugin( @diaries[@tb_date.strftime('%Y%m%d')].title, true ) ).gsub(/-{2,}/) {'&#45;' * $&.size}}"
	trackback:ping="#{@tb_url}" />
</rdf:RDF>
-->
			TBRDF
		else
			''
		end
	end
end

#
# hide TrackBacks in TSUKKOMI
#
eval( <<MODIFY_CLASS, TOPLEVEL_BINDING )
module TDiary
	class Comment
		def visible_true?
			@show
		end
		#{if @mode !~ /^(form|edit|comment|showcomment|trackbackreceive)$/ then
			'def visible?
				@show and /^(TrackBack|Pingback)$/ !~ name
			end'
		else
			'def visible?; @show; end'
		end}
	end
end
MODIFY_CLASS

#
# insert TrackBacks above Today's Link.
#
alias :referer_of_today_short_tb_backup :referer_of_today_short
def referer_of_today_short( diary, limit )
	r = referer_of_today_short_tb_backup( diary, limit )
	return r unless @plugin_files.grep(/blog_style.rb\z/).empty?
	if diary and !bot? and
	  @conf['trackback_shortview_mode'] == "num_in_reflist" then
		count = 0
		diary.each_visible_trackback {|t,count|} # count up
		r << %Q|<a href="#{h @index}#{anchor @tb_date.strftime( '%Y%m%d' )}#t">TrackBack#{'s' if count > 1}(#{count})</a>| unless count == 0 and @conf['tb.hide_if_no_tb']
	end
	r
end

def trackbacks_of_today_short( diary, limit = @conf['trackback_limit'] || 3 )
	is_blog_style = !@plugin_files.grep(/blog_style.rb\z/).empty?
	return unless is_blog_style || !diary.nil? &&
	  (@conf['trackback_shortview_mode'] == "shortlist" ||
	   @conf['trackback_disp_pingurl'])
	fragment = 't%02d'
	today = anchor( diary.date.strftime( '%Y%m%d' ) )
	count = 0
	diary.each_visible_trackback( -1 ) {|t,count|} # count up
	r = ''
	r << %Q!\t<div class="comment trackbacks">\n!

	r << %Q!\t\t<div class="caption">\n!
	r << %Q!\t\t\t#{trackback_today}#{trackback_total( count )}\n! if count > 0 && (is_blog_style || @conf['trackback_shortview_mode'] == "shortlist")
	r << %Q!\t\t</div>\n!
	return r << %Q!\t</div>\n! unless is_blog_style || @conf['trackback_shortview_mode'] == "shortlist"

	r << %Q!\t\t<div class="commentshort trackbackshort">\n!
	r << %Q!\t\t\t<p><a href="#{h @index}#{today}#t01">Before...</a></p>\n! if count > limit

	diary.each_visible_trackback_tail( limit ) do |t,i|
		url, name, title, excerpt = t.body.split( /\n/,4 )
		a = name || url
		a += ':' + title if title &&! title.empty?

		r << %Q!\t\t\t<p>\n!
		r << %Q!\t\t\t\t<a href="#{h @index}#{today}##{fragment % i}">#{@conf['trackback_anchor']}</a>\n!
		r << %Q!\t\t\t\t<span class="commentator blog"><a href="#{h url}">#{h a}</a></span>\n!
		r << %Q!\t\t\t\t#{h @conf.shorten( excerpt, @conf.comment_length )} \n! if excerpt
		r << %Q!\t\t\t</p>\n!
	end
	r << %Q!\t\t</div>\n!
	r << %Q!\t</div>\n!
	r
end

def trackbacks_of_today_long( diary, limit = -1 )
	count = 0
	diary.each_visible_trackback( limit ) {|t,count|} # count up
	fragment = 't%02d'
	today = anchor( @date.strftime( '%Y%m%d' ) )

	r = ''
	r << %Q!\t<div class="comment trackbacks">\n!

	r << %Q!\t\t<div class="caption">\n!
	r << %Q!\t\t\t#{trackback_today}#{trackback_total( count )}\n! if count > 0
	r << %Q!\t\t</div>\n!

	r << %Q!\t\t<div class="commentbody trackbackbody">\n!
	diary.each_visible_trackback( limit ) do |t,i|
		url, name, title, excerpt = t.body.split( /\n/,4 )
		a = (name and name.length > 0) ? name : url
		a += ':' + title if title &&! title.empty?
		f = fragment % i
		excerpt = excerpt || ''
		if excerpt.length > 255
			excerpt = @conf.shorten( excerpt, 252 )
		end

		r << %Q!\t\t\t<div class="commentator trackback">\n!
		r << %Q!\t\t\t\t<a name="#{f}" href="#{h @index}#{today}##{f}">#{@conf['trackback_anchor']}</a>\n!
		if bot? then
			r << %Q!\t\t\t\t<span class="commentator trackbackblog">#{h a}</span>\n!
		else
			r << %Q!\t\t\t\t<span class="commentator trackbackblog"><a href="#{h url}">#{h a}</a></span>\n!
		end
		r << %Q!\t\t\t\t<span class="commenttime trackbacktime">#{comment_date( t.date )}</span>\n!
		r << %Q!\t\t\t</div>\n!
		r << %Q!\t\t\t<p>#{h( excerpt ).strip.gsub( /\n/,'<br>')}</p>\n! if excerpt
  	end
	r << %Q!\t\t</div>\n!
	r << %Q!\t</div>\n!
	r
end

# configurations
@conf['trackback_anchor'] ||= @conf.comment_anchor
@conf['trackback_limit']  ||= @conf.comment_limit

add_conf_proc( 'tb-show', 'TrackBack', 'tsukkomi' ) do
	if @mode == 'saveconf' then
		@conf['trackback_anchor'] = @conf.to_native( @cgi.params['trackback_anchor'][0] )
		@conf['trackback_shortview_mode'] = @cgi.params['trackback_shortview_mode'][0]
		if @conf['trackback_shortview_mode'] == "num_in_reflist_if_exists"
			@conf['tb.hide_if_no_tb'] = true
			@conf['trackback_shortview_mode'] = "num_in_reflist"
		elsif @conf['trackback_shortview_mode'] == "num_in_reflist"
			@conf['tb.hide_if_no_tb'] = false
		end
		@conf['trackback_limit']  = @cgi.params['trackback_limit'][0].to_i
		@conf['trackback_limit'] = 3 if @conf['trackback_limit'] < 1
		@conf['trackback_disp_pingurl'] = @cgi.params['trackback_disp_pingurl'][0] == "true" ? true : false
	end
	tb_show_conf_html
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
