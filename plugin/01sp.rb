# 01sp.rb - select-plugins plugin $Revision: 1.5 $

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
	@conf["#{SP_PREFIX}.#{key}"]
end

# list of plugins
def sp_list_plugins
	r = ''
	unless @sp_opt.empty? then
		r += @sp_label_please_select
		used = sp_option( 'selected' ) ? sp_option( 'selected' ).split( /\n/ ) : []
		used.reject! { |plugin| not @sp_opt.keys.include?( plugin ) }
		notused = sp_option( 'notselected' ) ? sp_option( 'notselected' ).split( /\n/ ) : []
		notused.reject! { |plugin| not @sp_opt.keys.include?( plugin ) }
		unknown = @sp_opt.keys.dup
		unknown.reject! { |plugin| used.include?( plugin ) }
		unknown.reject! { |plugin| notused.include?( plugin ) }
		# new plugins
		unless unknown.empty? then
			r += @sp_label_new
			r += "<ul>\n"
			unknown.sort.each do |file|
				r += <<-_HTML
					<li><input name="#{SP_PREFIX}.#{CGI::escapeHTML( file )}" type="checkbox" value="t"#{sp_option( 'usenew' ) ? ' checked' : ''}>#{CGI::escapeHTML( file )}
				_HTML
			end
			r += "</ul>\n"
		end
		# selected plugins
		unless used.empty? then
			r += @sp_label_used
			r += "<ul>\n"
			used.sort.each do |file|
				r += <<-_HTML
					<li><input name="#{SP_PREFIX}.#{CGI::escapeHTML( file )}" type="checkbox" value="t" checked>#{CGI::escapeHTML( file )}
				_HTML
			end
			r += "</ul>\n"
		end
		# not selected plugins
		unless notused.empty? then
			r += @sp_label_notused
			r += "<ul>\n"
			notused.sort.each do |file|
				r += <<-_HTML
					<li><input name="#{SP_PREFIX}.#{CGI::escapeHTML( file )}" type="checkbox" value="t">#{CGI::escapeHTML( file )}
				_HTML
			end
			r += "</ul>\n"
		end
	else
		r += @sp_label_noplugin
	end
	r
end

if @cgi.params['conf'][0] == SP_PREFIX then
	# selectable plugins
	@sp_opt = {}	# path to the plugin
	Dir::glob( "#{@sp_path}/*.rb" ).each do |path|
		@sp_opt[ File.basename( path ) ] = path
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
	r = @sp_label_description.dup + sp_list_plugins
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
		rescue Exception
			raise PluginError::new( "Plugin error in '#{File::basename( path )}'.\n#{$!}" )
		end
	end
end
