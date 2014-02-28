# pb-show.rb
#
# functions:
#   * show Pingback ping URL in right of TSUKKOMI label.
#   * hide Pingbacks in TSUKKOMI.
#   * show Pingbacks above Today's Links.
#
# options:
#	@options['pb.cgi']:
#		the Pingback ping URL. './pb.rb' is default.
#	@options['pb.hide_if_no_pb']:
#		If true, hide 'Pingbacks(n)' when there is no Pingbacks.  Default value is false.
#
# Copyright (c) 2003 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL.
#
# Modified: by Junichiro Kita <kita@kitaj.no-ip.com>
# Modified: by MoonWolf <moonwolf@moonwolf.com>
#
#

# running on only non mobile mode
unless @cgi.mobile_agent? then

#
# hide Pingbacks in TSUKKOMI
#
module ::TDiary
	module CommentManager
		def each_visible_pingback( limit = 3 )
			i = 0
			@comments.find_all {|com|
				com.visible_true? and /^Pingback$/ =~ com.name
			}[0,limit].each do |com|
				i += 1 # i starts with 1.
				yield com,i
			end
		end

		def each_visible_pingback_tail( limit = 3 )
			i = 0
			@comments.find_all {|com|
				com.visible_true? and /^Pingback$/ =~ com.name
			}.reverse[0,limit].reverse.each do |com|
				i += 1 # i starts with 1.
				yield com,i
			end
		end
	end
end

#
# insert Pingbacks above Today's Link.
#
alias :referer_of_today_short_pb_backup :referer_of_today_short
def referer_of_today_short( diary, limit )
	r = referer_of_today_short_pb_backup( diary, limit )
	return r unless @plugin_files.grep(/blog_style.rb\z/).empty?
	if diary and !bot? then
		count = 0
		diary.each_visible_pingback( 100 ) {|t,count|} # count up
		r << %Q|<a href="#{h( @index )}#{anchor( @pb_date.strftime( '%Y%m%d' ) )}#b">Pingback#{'s' if count > 1}(#{h( count )})</a>| unless count == 0 and @options['pb.hide_if_no_pb']
	end
	r
end

def pingbacks_of_today_short( diary, limit = @conf['pingback_limit'] || 3 )
	# for BlogKit only
	return if @plugin_files.grep(/blog_style.rb\z/).empty?

	fragment = 't%02d'
	today = anchor( diary.date.strftime( '%Y%m%d' ) )
	count = 0
	diary.each_visible_pingback( limit ) {|t,count|} # count up

	r = ''
	r << %Q!\t<div class="comment pingbacks">\n!

	r << %Q!\t\t<div class="caption">\n!
        r << %Q!\t\t\t#{ pingback_today }#{ pingback_total( count ) }\n!
	r << %Q!\t\t</div>\n!

	r << %Q!\t\t<div class="commentshort pingbackshort">\n!
	r << %Q!\t\t\t<p><a href="#{h @index }#{ today }#b01">Before...</a></p>\n! if count > limit

	diary.each_visible_pingback_tail( limit ) do |t,i|
		sourceURI, targetURI = t.body.split( /\n/,2 )
		r << %Q!\t\t\t<p>\n!
		r << %Q!\t\t\t\t<a href="#{ h( @index ) }#{ today }##{ fragment % i }">#{ h( @conf['pingback_anchor'] ) }</a>\n!
		r << %Q!\t\t\t\t<span class="commentator blog"><a href="#{ h( sourceURI ) }">#{h( sourceURI )}</a> to <a href="#{ h( targetURI ) }">#{h( targetURI )}</a></span>\n!
		r << %Q!\t\t\t</p>\n!
	end
	r << %Q!\t\t</div>\n!
	r << %Q!\t</div>\n!
	r
end

def pingbacks_of_today_long( diary, limit = 100 )
	count = 0
	diary.each_visible_pingback( limit ) {|t,count|} # count up
	fragment = 'b%02d'
	today = anchor( @date.strftime( '%Y%m%d' ) )

	r = ''
	r << %Q!\t<div class="comment pingbacks">\n!

	r << %Q!\t\t<div class="caption">\n!
	r << %Q!\t\t\t#{ pingback_today }#{ pingback_total( count ) }\n!
	r << %Q!\t\t</div>\n!

	r << %Q!\t\t<div class="commentbody pingbackbody">\n!
	diary.each_visible_pingback( limit ) do |t,i|
		sourceURI, targetURI = t.body.split( /\n/,2 )
		f = fragment % i

		r << %Q!\t\t\t<div class="commentator pingback">\n!
		r << %Q!\t\t\t\t<a name="#{ f }" href="#{ h( @index ) }#{ today }##{ f }">#{ @conf['pingback_anchor'] }</a>\n!
		if bot? then
			r << %Q!\t\t\t\t<span class="commentator pingbackblog">#{ h( sourceURI + " to " + targetURI )}</span>\n!
		else
			r << %Q!\t\t\t\t<span class="commentator pingbackblog"><a href="#{ h( sourceURI ) }">#{h( sourceURI )}</a> to <a href="#{ h( targetURI ) }">#{h targetURI}</a></span>\n!
		end
		r << %Q!\t\t\t\t<span class="commenttime pingbacktime">#{ comment_date( t.date ) }</span>\n!
		r << %Q!\t\t\t</div>\n!
  	end
	r << %Q!\t\t</div>\n!
	r << %Q!\t</div>\n!
	r
end

# running on only non mobile mode
end # unless mobile_agent?

#
# show Pingback ping URL
#
add_body_enter_proc do |date|
	cgi = File.basename(@options['pb.cgi'] || './pb.rb')
	@pb_date = date
   @pb_id_url = %Q|#{h @index}#{anchor( @pb_date.strftime('%Y%m%d') )}|
	@pb_id_url[0, 0] = base_url if %r|^https?://|i !~ @conf.index
	@pb_id_url.gsub!( %r|/\./|, '/' )
	@pb_url = %Q|#{h base_url}#{cgi}/#{@pb_date.strftime('%Y%m%d')}|
	''
end

# configurations
@conf['pingback_anchor'] ||= @conf.comment_anchor
@conf['pingback_limit']  ||= @conf.comment_limit

add_conf_proc( 'Pingback-Show', 'Pingback' ) do
	if @mode == 'saveconf' then
		@conf['pingback_anchor'] = @conf.to_native( @cgi.params['pingback_anchor'][0] )
		@conf['pingback_limit']  = @cgi.params['pingback_limit'][0].to_i
		@conf['pingback_limit'] = 3 if @conf['pingback_limit'] < 1
	end
	pb_show_conf_html
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
