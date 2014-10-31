# daily_theme.rb
#
# Copyright (c) 2005 SHIBATA Hiroshi <h-sbt@nifty.com>
# Distributed under the GPL2 or any later version.
#

def css_tag
	theme_name = File::basename( @css, '.css' )
	css_url = @css

	if @mode =~ /conf$/
		css_url = "#{h theme_url}/conf.css"
		theme_name = 'conf'
	elsif @conf.options.include?('daily_theme.list') && @conf.options['daily_theme.list'].size > 0
		theme_list = @conf.options['daily_theme.list'].split(/\n/)
		index = Time.now.yday % theme_list.size
		theme_name = theme_list[index].strip
		css_url = "#{h theme_url}/#{u theme_name}/#{u theme_name}.css"
	end

	<<-CSS
	<link rel="stylesheet" href="#{h theme_url}/base.css" type="text/css" media="all">
	<link rel="stylesheet" href="#{h css_url}" title="#{h theme_name}" type="text/css" media="all">
	CSS
end

add_conf_proc( 'daily_theme', @daily_theme_label, 'theme' ) do
	daily_theme_conf_proc
end

def daily_theme_conf_proc
	if @mode == 'saveconf'
		if @cgi.params['daily_theme.list'] && @cgi.params['daily_theme.list'][0]
			@conf['daily_theme.list'] = @cgi.params['daily_theme.list'][0]
		else
			@conf['daily_theme.list'] = nil
		end
	end

	# initialize Theme list
	@conf['daily_theme.list'] = "default" unless @conf['daily_theme.list']

	<<-HTML
	<h3>#{@daily_theme_label}</h3>
	<p>#{@daily_theme_label_desc}</p>
	<p><textarea name="daily_theme.list" cols="70" rows="20">#{h( @conf['daily_theme.list'] )}</textarea></p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
