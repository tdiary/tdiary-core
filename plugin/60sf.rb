# -*- coding: utf-8; -*-
# 60sf.rb - select-filters plugin
# This file is based on 50sp.rb Revision: 1.5
# Modified by KURODA Hiraku.

SF_PREFIX = 'sf'
@sf_path = [( @conf["#{SF_PREFIX}.path"] || "#{TDiary::PATH}/misc/filter" )].flatten
@sf_path = @sf_path.collect do |path|
	/\/$/ =~ path ? path.chop : path
end

# get plugin option
def sf_option( key )
	@conf["#{SF_PREFIX}.#{key}"]
end

# hash of paths from array of dirs
def sf_hash_from_dirs( dirs )
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
def sf_doc_url( file )
	"http://docs.tdiary.org/#{@conf.lang}/?#{CGI::escape( file )}"
end

# <li> list of plugins
def sf_li_plugins( paths, is_checked )
	r = ''
	paths.collect { |path| File.basename( path ) }.sort.each do |file|
		r += <<-_HTML
			<li><input name="#{SF_PREFIX}.#{h file}" type="checkbox" value="t"#{'checked' if is_checked}><a href="#{h sf_doc_url( file )}">#{h file}</a>
		_HTML
	end
	r
end

# lists of plugins
def sf_list_plugins( sf_opt )
	r = ''
	if ( sf_opt && !sf_opt.empty? ) then
		# categorize the available plugins
		used = Array.new
		notused = Array.new
		unknown = Array.new
		# File.basenmame needed to read option from 01sp.rb <= 1.10
		selected_array = sf_option( 'selected' ) ? sf_option( 'selected').split( /\n/ ).collect{ |p| File.basename( p ) } : []
		notselected_array = sf_option( 'notselected' ) ? sf_option( 'notselected').split( /\n/ ).collect{ |p| File.basename( p ) } : []
		sf_opt.keys.each do |path|
			if selected_array.include?( path ) then
				used << path
			elsif notselected_array.include?( path ) then
				notused << path
			else
				unknown << path
			end
		end

		# list up
		r += @sf_label_please_select
		unless unknown.empty? then
			r += @sf_label_new
			r += "<ul>\n"
			r += sf_li_plugins( unknown, sf_option( 'usenew' ) )
			r += "</ul>\n"
		end
		# selected plugins
		unless used.empty? then
			r += @sf_label_used
			r += "<ul>\n"
			r += sf_li_plugins( used, true )
			r += "</ul>\n"
		end
		# not selected plugins
		unless notused.empty? then
			r += @sf_label_notused
			r += "<ul>\n"
			r += sf_li_plugins( notused, false )
			r += "</ul>\n"
		end
	else
		r += @sf_label_noplugin
	end
	r
end

# things needed to configure this plugin
if SF_PREFIX == (@cgi.params['conf'] && @cgi.params['conf'][0]) then
	# list of plugins
	@sf_opt = sf_hash_from_dirs( @sf_path )

	# update options
	# we have to do this when we are eval'ed to update the config menu
	if /saveconf/ =~ @mode then
		@conf["#{SF_PREFIX}.selected"] = ''
		@conf["#{SF_PREFIX}.notselected"] = ''
		@sf_opt.each_key do |file|
			if 't' == @cgi.params["#{SF_PREFIX}.#{file}"][0] then
				@conf["#{SF_PREFIX}.selected"] << "#{file}\n"
			else
				@conf["#{SF_PREFIX}.notselected"] << "#{file}\n"
			end
		end
	end
end

# configuration menu
# options are updated when we are eval'ed
add_conf_proc( SF_PREFIX, @sf_label, 'security' ) do
	r = @sf_label_description + sf_list_plugins( @sf_opt )
end

# Finally, we can eval the selected plugins as tdiary.rb does
if sf_option( 'selected' ) && !@sf_filters then
	@sf_filters = []
	sf_option( 'selected' ).untaint.split( /\n/ ).collect{ |p| File.basename( p ) }.sort.each do |filename|
		@sf_path.each do |dir|
			path = "#{dir}/#{filename}"
			if File.readable?( path ) then
				begin
					require path
					@sf_filters << TDiary::Filter::const_get("#{File::basename(filename, ".rb").capitalize}Filter")::new(@cgi, @conf)
					plugin_path = "#{dir}/plugin/#{filename}"
					load_plugin(plugin_path) if File.readable?(plugin_path)
				rescue Exception
					raise PluginError::new( "Plugin error in '#{path}'.\n#{$!}" )
				end
				break
			end
		end
	end
end

def sf_filters
	@sf_filters||[]
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
