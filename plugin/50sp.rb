# -*- coding: utf-8; -*-
# 50sp.rb - select-plugins plugin

SP_PREFIX = 'sp'
@sp_path = [( @conf["#{SP_PREFIX}.path"] || "#{TDiary::PATH}/misc/plugin" )].flatten
@sp_path = @sp_path.collect do |path|
	/\/$/ =~ path ? path.chop : path
end
@sp_path << "#{TDiary::PATH}/misc/plugin" if @sp_path.include?('misc/plugin')

@sp_path.concat TDiary::Extensions::constants.map {|extension|
	TDiary::Extensions::const_get( extension ).sp_path
}.flatten.compact.uniq

# get plugin option
def sp_option( key )
	@conf["#{SP_PREFIX}.#{key}"]
end

# hash of paths from array of dirs
def sp_hash_from_dirs( dirs )
	r = Hash.new
	dirs.each do |dir|
		Dir::glob( "#{dir}/*.rb" ).each do |path|
			filename = File.basename( path )
			unless r[ filename ] then
				r[ filename ] = path
			end
		end
	end
	r
end

# url of the document
def sp_doc_url( file )
	"http://docs.tdiary.org/#{@conf.lang}/?#{CGI::escape( file )}"
end

# <li> list of plugins
def sp_li_plugins( paths, is_checked )
	r = ''
	paths.collect { |path| File.basename( path ) }.sort.each do |file|
		r += <<-_HTML
			<li><input name="#{SP_PREFIX}.#{h file}" type="checkbox" value="t"#{'checked' if is_checked}><a href="#{h sp_doc_url( file )}">#{h file}</a>
		_HTML
	end
	r
end

# lists of plugins
def sp_list_plugins( sp_opt )
	r = ''
	if ( sp_opt && !sp_opt.empty? ) then
		# categorize the available plugins
		used = Array.new
		notused = Array.new
		unknown = Array.new
		# File.basenmame needed to read option from 01sp.rb <= 1.10
		selected_array = sp_option( 'selected' ) ? sp_option( 'selected').split( /\n/ ).collect{ |p| File.basename( p ) } : []
		notselected_array = sp_option( 'notselected' ) ? sp_option( 'notselected').split( /\n/ ).collect{ |p| File.basename( p ) } : []
		sp_opt.keys.each do |path|
			if selected_array.include?( path ) then
				used << path
			elsif notselected_array.include?( path ) then
				notused << path
			else
				unknown << path
			end
		end

		# list up
		r += @sp_label_please_select
		unless unknown.empty? then
			r += @sp_label_new
			r += "<ul>\n" 
			r += sp_li_plugins( unknown, sp_option( 'usenew' ) )
			r += "</ul>\n"
		end
		# selected plugins
		unless used.empty? then
			r += @sp_label_used
			r += "<ul>\n"
			r += sp_li_plugins( used, true )
			r += "</ul>\n"
		end
		# not selected plugins
		unless notused.empty? then
			r += @sp_label_notused
			r += "<ul>\n"
			r += sp_li_plugins( notused, false )
			r += "</ul>\n"
		end
	else
		r += @sp_label_noplugin
	end
	r
end

# things needed to configure this plugin
if SP_PREFIX == (@cgi.params['conf'] && @cgi.params['conf'][0]) then
	# list of plugins
	@sp_opt = sp_hash_from_dirs( @sp_path )

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
add_conf_proc( SP_PREFIX, @sp_label, 'basic' ) do
	r = @sp_label_description + sp_list_plugins( @sp_opt )
end

# Finally, we can eval the selected plugins as tdiary.rb does
if sp_option( 'selected' ) then
	sp_option( 'selected' ).untaint.split( /\n/ ).collect{ |p| File.basename( p ) }.sort.each do |filename|
		@sp_path.each do |dir|
			path = "#{dir}/#{filename}"
			if File.readable?( path ) then
				begin
					load_plugin( path )
					@plugin_files << path
				rescue ArgumentError
					next
				rescue Exception
					raise PluginError::new( "Plugin error in '#{path}'.\n#{$!}" )
				end
				break
			end
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
