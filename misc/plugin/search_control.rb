# -*- coding: utf-8 -*-
=begin
= ここだけ検索プラグイン/search control plugin((-$Id: search_control.rb,v 1.11 2008-03-02 09:01:45 kazuhiko Exp $-))

Under revision! TODO: add/remove user agents

== License
Copyright (C) 2003, 2004 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL version 2 or later.
=end

=begin ChangeLog
See ChangeLog for changes after this.

* Aug 28, 2003 zunda <zunda at freeshell.org>
- 1.3
- simpler configuration display

* Aug 26, 2003 zunda <zunda at freeshell.org>
- 1.2
- no table in configuration view, thanks to Tada-san.

* Aug 26, 2003 zunda <zunda at freeshell.org>
- no nofollow
- English translation
=end ChangeLog

# Default values
unless defined?( Search_control_agents ) then
	Search_control_agents = [
		'',
		'Comaneci_bot',
	]
	Search_control_defaults = [
		{	# agent: generic
			'latest' => 'f',
			'day' => 't',
			'month' => 'f',
			'nyear' => 'f',
			'category' => 'f',
		},
		{	# agent: 'Comaneci_bot'
			'latest' => 't',
			'day' => 'f',
			'month' => 'f',
			'nyear' => 'f',
			'category' => 'f',
		},
	]

	# to be used for @options and in the HTML form
	Search_control_prefix = 'search_control'

	# functions used in this file
	# number of agents
	def _sc_nkey
		"#{Search_control_prefix}.agents"
	end

	# agent name key for agent number
	def _sc_akey( number )
		"#{Search_control_prefix}.agent#{number.to_i > 0 ? number : ''}"
	end

	# views
	def _sc_vkey( view, number )
		"#{Search_control_prefix}.#{number.to_i > 0 ? number : ''}#{view}.index"
	end
	def _sc_each_view
		Search_control_defaults[0].each_key do |view|
			yield( view )
		end
	end
	def _sc_each_vkey( number )
		_sc_each_view do |view|
			yield( _sc_vkey( view, number ) )
		end
	end

	# keys in the form
	def _sc_newkey
		"#{Search_control_prefix}.newagent"
	end
	def _sc_delkey( number )
		"#{Search_control_prefix}.delete#{number}"
	end
end

# defaults
unless @conf[_sc_nkey] then
	@conf[_sc_nkey] = Search_control_agents.size
end
_sc_each_vkey( 0 ) do |vkey|
	@conf[vkey] = value unless @conf[vkey]
end
Search_control_defaults.each_with_index do |d, i|
	@conf[_sc_akey(i)] = Search_control_agents[i] unless @conf[_sc_akey(i)] and i > 0
	d.each_pair do |view, value|
		vkey = _sc_vkey( view, i )
		@conf[vkey] = value unless @conf[vkey]
	end
end

# configuration
add_conf_proc( Search_control_prefix, Search_control_plugin_name ) do
	# receive the configurations from the form
	if 'saveconf' == @mode then

		# setting changes
		if @cgi.params[_sc_nkey][0] then
			@conf[_sc_nkey] = @cgi.params[_sc_nkey][0].to_i
		end
		(0...@conf[_sc_nkey]).each do |i|
			if i > 0 and @cgi.params[_sc_akey( i )][0] then
				agent = @cgi.params[_sc_akey( i )][0].strip
				unless agent.empty? then
					@conf[_sc_akey( i )] = agent
				end
			end
			_sc_each_vkey( i ) do |vkey|
				if 't' == @cgi.params[vkey][0] then
					@conf[vkey] = 't'
				else
					@conf[vkey] = 'f'
				end
			end
		end

		# deleted agents
		(@conf[_sc_nkey] - 1).downto( 1 ) do |i|
			if 't' == @cgi.params[_sc_delkey( i )][0] then
				(i...(@conf[_sc_nkey] - 1)).each do |j|
					@conf[_sc_akey( j )] = @conf[_sc_akey( j+1 )]
					_sc_each_view do |view|
						@conf[_sc_vkey( view, j ) ] = @conf[_sc_vkey( view, j+1 ) ]
					end
				end
				@conf[_sc_nkey] -= 1
				@conf.delete( _sc_akey( @conf[_sc_nkey] ) )
				_sc_each_vkey( @conf[_sc_nkey] ) do |vkey|
					@conf.delete( vkey )
				end
			end
		end

		# new agent
		newagent = @cgi.params[_sc_newkey] ? @cgi.params[_sc_newkey][0].strip : nil
		if newagent and not newagent.empty? then
			@conf[_sc_akey( @conf[_sc_nkey] )] = newagent
			Search_control_defaults[0].each_pair do |view, value|
				@conf[_sc_vkey( view, @conf[_sc_nkey] )] = value
			end
			@conf[_sc_nkey] += 1
		end

	end

	# show the HTML
	r = Search_control_description_html + "<ul>\n"
	r << %Q|<li><input name="#{_sc_newkey}" value="" type="text"> #{Search_control_new_label}\n|
	(@conf[_sc_nkey] - 1).downto( 1 ) do |i|
		r << %Q|<li><input name="#{_sc_akey( i )}" value="#{h( @conf[_sc_akey( i )] )}" type="text">\n|
		name = "#{_sc_delkey( i )}"
		r << %Q|<label for="#{name}"><input id="#{name}" name="#{name}" value="t" type="checkbox">#{Search_control_delete_label}</label>\n|
		r << "<ul>\n"
		Search_control_categories.each do |c|
			label = c[0]
			view = c[1]
			checked = 't' == @conf[_sc_vkey( view, i )] ? ' checked' : ''
			name = "#{_sc_vkey( view, i )}"
			r << %Q|<li><label for="#{name}"><input id="#{name}" name="#{name}" value="t" type="checkbox"#{checked}>#{label}</label>\n|
		end
		r << "</ul>\n"
	end
	r << %Q|<li>#{Search_control_default_label}\n|
	r << "<ul>\n"
	Search_control_categories.each do |c|
		label = c[0]
		view = c[1]
		checked = 't' == @conf[_sc_vkey( view, 0 )] ? ' checked' : ''
		name = "#{_sc_vkey( view, 0 )}"
		r << %Q|<li><label for="#{name}"><input id="#{name}" name="#{name}" value="t" type="checkbox"#{checked}>#{label}</label>\n|
	end
	r << "</ul>\n</ul>\n"
	r << %Q|<input type="hidden" name="#{_sc_nkey}" value="#{@conf[_sc_nkey]}">|
end

add_header_proc do
	# agent
	number = ''	# default agent
	if @cgi.user_agent then
		(1...@conf[_sc_nkey]).each do |i|
			if @cgi.user_agent.include?( @conf[_sc_akey( i )] ) then
				number = i.to_s
				break
			end
		end
	end

	# view
	view = ''
	follow = 'follow'
	if /^(latest|day|month|nyear)$/ =~ @mode then
		view = @mode
	elsif /^category/ =~ @mode then
		view = 'category'
		follow = 'nofollow'
	end

	# output
	sw = @conf[_sc_vkey( view, number )]
	if sw then
		%Q|\t<meta name="robots" content="#{'f' == sw ? 'noindex' : 'index' },#{follow}">\n|
	else
		''
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
