# 01sp.rb - select-plugins plugin $Revision: 1.4 $

=begin ChangeLog
See ../ChangeLog for changes after this.

* Thu Aug 28, 2003 zunda <zunda at freeshell.org>
- 1.3
- simpler configuration display

* Tue Aug 26, 2003 zunda <zunda at freeshell.org>
- 1.2
- option defaults are flipped
- Typo for @options are fixed

* Tue Aug 26, 2003 zunda <zunda at freeshell.org>
- 1.1
- English translation

* Fri Aug 22, 2003 zunda <zunda at freeshell.org>
- 1.1.2.6
- bug fix: check conf mode before updating the options

* Fri Aug 22, 2003 zunda <zunda at freeshell.org>
- 1.1.2.5
- following options are added: thanks to kaz
- @options['select_plugins.hidesource']
- @options['select_plugins.hidemandatory']
- @options['select_plugins.newdefault']
- new plugins are marked in the list until the user configures the selections

* Wed Aug 20, 2003 zunda <zunda at freeshell.org>
- 1.1.2.1
- first release
=end ChangeLog

SP_PREFIX = 'sp'
@sp_path = @conf["#{SP_PREFIX}.path"] || 'misc/plugin'

# get option
def sp_option( key )
	@conf["#{SP_PREFIX}.#{key}"] || nil
end

# list of plugins
def sp_list_plugins
	r = ''
	if sp_option( 'showmandatory' ) then
		r << @sp_label_mandatory
		r << "<ul>\n"
		@sp_defs.keys.sort.each do |file|
			r << <<-_HTML
			<li>#{CGI::escapeHTML( file )}
				#{'<a href="' + @conf.update + '?conf=' + SP_PREFIX + ';help=d' + CGI::escape( file ) + '">' + @sp_label_comment + '</a>' if sp_option( 'showhelp' )}
				#{', ' if sp_option( 'showhelp' ) and sp_option( 'showsource' )}
				#{'<a href="' + @conf.update + '?conf=' + SP_PREFIX + ';src=d' + CGI::escape( file ) + '">' + @sp_label_source + '</a>' if sp_option( 'showsource' )}
				#{"(#{@sp_ver[ 'd' + file ]})" if @sp_ver[ 'd' + file ]}
			_HTML
		end
		r << "</ul>\n"
		r << @sp_label_optional
	end	# if sp_option( 'showmandatory' )
	unless @sp_opt.empty? then
		known = ( sp_option( 'selected' ) ? sp_option( 'selected' ).split( /\n/ ) : []) + ( sp_option( 'notselected' ) ? sp_option( 'notselected' ).split( /\n/ ) : [])
		r << @sp_label_optional2
		r << "<ul>\n"
		@sp_opt.keys.sort.each do |file|
			r << <<-_HTML
			<li><input name="sp.#{CGI::escapeHTML( file )}" type="checkbox" value="t"#{((sp_option( 'selected' ) and sp_option( 'selected' ).split( /\n/ ).include?( file )) or (sp_option( 'usenew' ) and not known.include?( file ))) ? ' checked' : ''}>
				#{CGI::escapeHTML( file )}
				#{'<a href="' + @conf.update + '?conf=' + SP_PREFIX + ';help=o' + CGI::escape( file ) + '">' + @sp_label_comment + '</a>' if sp_option( 'showhelp' )}
				#{', ' if sp_option( 'showhelp' ) and sp_option( 'showsource' )}
				#{'<a href="' + @conf.update + '?conf=' + SP_PREFIX + ';src=o' + CGI::escape( file ) + '">' + @sp_label_source + '</a>' if sp_option( 'showsource' )}
				#{'(' + @sp_ver[ 'o' + file ] + ')' if @sp_ver[ 'o' + file ]}
				#{@sp_label_new unless known.include?( file )}
			_HTML
		end
		r << "</ul>\n"
	else
		r << @sp_label_noplugin
	end
	r
end

# comments
# file is prefixed with 'o' (optional/selectable) or 'd' (default/mandatory)
def sp_help( file )
	if sp_option( 'showhelp' ) and @sp_src[file] then
		if @sp_resource[file] then
			commentsource = @sp_resource[file]
		else
			commentsource = @sp_src[file]
		end
		if /^=begin$(.*?)^=end$/m =~ commentsource then
			help =  $1
		elsif /((^#.*?\n)+)/ =~ commentsource then
			help =  $1.gsub( /^#/, '' )
		end
		if help then
			case @conf.lang
			when 'en'
				<<-_HTML
					<p>Comments in #{CGI::escapeHTML( file.slice( 1..-1 ) )}.#{' Click <a href="' + @conf.update + '?conf=' + SP_PREFIX + ';src=' + CGI::escape( file ) + '">here</a> for the source.' if sp_option( 'showsource' )}</p>
					<p><a href="#{@conf.update}?conf=#{SP_PREFIX}">Back</a>
					<hr>
					<pre>#{CGI::escapeHTML( help )}</pre>
					<hr>
				_HTML
			else
				<<-_HTML
					<p>#{CGI::escapeHTML( file.slice( 1..-1 ) )}の注釈です。#{'ソースを見るには、<a href="' + @conf.update + '?conf=' + SP_PREFIX + ';src=' + CGI::escape( file ) + '">こちら</a>。' if sp_option( 'showsource' )}</p>
					<p><a href="#{@conf.update}?conf=#{SP_PREFIX}">戻る</a>
					<hr>
					<pre>#{CGI::escapeHTML( help )}</pre>
					<hr>
				_HTML
			end
		else
			case @conf.lang
			when 'en'
				<<-_HTML
					<p>There is no comment in #{CGI::escapeHTML( file.slice( 1..-1 ))}.#{' Click <a href="' + @conf.update + '?conf=' + SP_PREFIX + ';src=' + CGI::escape( file ) + '">here</a> for the source.' if sp_option( 'showsource' ) and @sp_src[file]}</p>
				_HTML
			else
				<<-_HTML
					<p>#{CGI::escapeHTML( file.slice( 1..-1 ))}の注釈はありません。#{'ソースを見るには、<a href="'+ @conf.update + '?conf=' + SP_PREFIX + ';src=' + CGI::escape( file ) + '">こちら</a>。' if sp_option( 'showsource' ) and @sp_src[file]}</p>
				_HTML
			end
		end
	else
		case @conf.lang
		when 'en'
			<<-_HTML
			<p>Comments from #{CGI::escapeHTML( file.slice( 1..-1 ))} can't be viewed.</p>
			_HTML
		else
			<<-_HTML
			<p>#{CGI::escapeHTML( file.slice( 1..-1 ))}の注釈は見られません。</p>
			_HTML
		end
	end
end

# source
# file is prefixed with 'o' (optional/selectable) or 'd' (default/mandatory)
def sp_src( file )
	if sp_option( 'showsource' ) and @sp_src[file] then
		case @conf.lang
		when 'en'
			<<-_HTML
			<p>Source for #{CGI::escapeHTML( file.slice( 1..-1 ) )}</p>
			<p><a href="#{@conf.update}?conf=#{SP_PREFIX}">Back</a>
			<hr>
			<pre>#{CGI::escapeHTML( @sp_src[file] )}</pre>
			<hr>
			_HTML
		else
			<<-_HTML
			<p>#{CGI::escapeHTML( file.slice( 1..-1 ) )}のソースです。</p>
			<p><a href="#{@conf.update}?conf=#{SP_PREFIX}">戻る</a>
			<hr>
			<pre>#{CGI::escapeHTML( @sp_src[file] )}</pre>
			<hr>
			_HTML
		end
	else
		case @conf.lang
		when 'en'
			<<-_HTML
			<p>Source for #{CGI::escapeHTML( file.slice( 1..-1 ) )} can't be viewed.</p>
			_HTML
		else
			<<-_HTML
			<p>#{CGI::escapeHTML( file.slice( 1..-1 ) )}のソースは見られません。</p>
			_HTML
		end
	end
end 

if @cgi.params['conf'][0] == SP_PREFIX then
	# mandatory plugins
	if sp_option( 'showmandatory' ) then
		@sp_defs = {}	# path to the plugin
		def_paths = Dir::glob( ( @conf.plugin_path || "#{PATH}/plugin" ) + '/*.rb' )
		def_paths.each do |path|
			@sp_defs[ File.basename( path ) ] = path
		end
	end
	# selectable plugins
	@sp_opt = {}	# path to the plugin
	opt_paths = Dir::glob( "#{@sp_path}/*.rb" )
	opt_paths.each do |path|
		@sp_opt[ File.basename( path ) ] = path
	end
	# other information
	@sp_ver = {}	# revision number of the plugin
	@sp_src = {}	# source
	@sp_resource = {}	# l10n resource
	[['d', def_paths], ['o', opt_paths]].each do |prefix, paths|
		next unless paths
		paths.each do |path|
			file = File.basename( path )
			source = File.open( path.untaint ) { |f| f.read }
			# source
			@sp_src[ prefix + file ] = source
			# versions
			if /\$(Revision.*?)\s*\$/ =~ source then
				@sp_ver[ prefix + file ] = $1
			elsif /\$(Id.*?)\s*\$/ =~ source then
				@sp_ver[ prefix + file ] = $1
			end
			# l10n resource
			rcpath = File.dirname( path ) + '/' + @conf.lang + '/' + File.basename( path )
			rcpath.untaint
			if File.exist?( rcpath ) then
				@sp_resource[ prefix + file ] = File.open( rcpath ) { |f| f.read }
			end
		end
	end

	# update options
	# we have to do this when we are eval'ed to update the config menu
	if /saveconf/ =~ @mode then
		@conf["#{SP_PREFIX}.selected"] = ''
		@conf["#{SP_PREFIX}.notselected"] = ''
		@sp_opt.each_key do |file|
			if 't' == @cgi.params["#{SP_PREFIX}.#{file}"][0] then
				@conf["#{SP_PREFIX}.selected"] << "#{file}\n"
			else
				@conf["#{SP_PREFIX}.notselected"] << "#{file}\n"
			end
		end
	end
end

# configuration menu
# options are updated when we are eval'ed
add_conf_proc( SP_PREFIX, @sp_label ) do
	r = @sp_label_description.dup
	if @cgi.params['help'][0] then
		r += sp_help( @cgi.params['help'][0] )
	elsif sp_option( 'showsource' ) and @cgi.params['src'][0] then
		r += sp_src( @cgi.params['src'][0] )
	else
		r += sp_list_plugins
	end
end

# Finally, we can eval the selected plugins as tdiary.rb does
if sp_option( 'selected' ) then
	sp_option( 'selected' ).split( /\n/ ).sort.each do |file|
		next if /(\/|\\)/ =~ file	# / or \ should not appear
		path = "#{@sp_path}/#{file}"
		begin
			load_plugin( path.untaint )
			@plugin_files << path
		rescue IOError, Errno::ENOENT	# for now, just ignore missing plugins
		end
	end
end
