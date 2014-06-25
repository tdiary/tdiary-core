# -*- coding: utf-8; -*-
#
# class Plugin
#  plugin management class
#
require 'erb'

module TDiary
	class Plugin
		include ERB::Util
		include ViewHelper

		attr_reader :cookies
		attr_writer :comment, :date, :diaries, :last_modified

		def initialize( params )
			@header_procs = []
			@footer_procs = []
			@update_procs = []
			@title_procs = []
			@body_enter_procs = []
			@body_leave_procs = []
			@section_index = {}
			@section_enter_procs = []
			@comment_leave_procs = []
			@subtitle_procs = []
			@section_leave_procs = []
			@edit_procs = []
			@form_procs = []
			@conf_keys = []
			@conf_procs = {}
			@conf_genre_label = {}
			@content_procs = {}
			@cookies = []
			@javascripts = []
			@javascript_setting = []

			params.each do |key, value|
				instance_variable_set( "@#{key}", value )
			end

			# for 1.4 compatibility
			@index = @conf.index
			@update = @conf.update
			@author_name = @conf.author_name || ''
			@author_mail = @conf.author_mail || ''
			@index_page = @conf.index_page || ''
			@html_title = @conf.html_title || ''
			@theme = @conf.theme
			@css = @conf.css
			@date_format = @conf.date_format
			@referer_table = @conf.referer_table
			@options = @conf.options

			# loading plugins
			@plugin_files = []
			plugin_path = @conf.plugin_path || "#{PATH}/plugin"
			plugin_file = ''
			begin
				Dir::glob( "#{plugin_path}/*.rb" ).sort.each do |file|
					plugin_file = file
					load_plugin( file )
					@plugin_files << plugin_file
				end
			rescue ::TDiary::ForceRedirect
				raise
			rescue Exception
				raise PluginError::new( "Plugin error in '#{File::basename( plugin_file )}'.\n#{$!}\n#{$!.backtrace[0]}" )
			end
		end

		def load_plugin( file )
			@resource_loaded = false
			begin
				res_file = File::dirname( file ) + "/#{@conf.lang}/" + File::basename( file )
				open( res_file.untaint ) do |src|
					instance_eval( src.read.untaint, "(plugin/#{@conf.lang}/#{File::basename( res_file )})", 1 )
				end
				@resource_loaded = true
			rescue IOError, Errno::ENOENT
			end
			File::open( file.untaint ) do |src|
				instance_eval( src.read.untaint, "(plugin/#{File::basename( file )})", 1 )
			end
		end

		def eval_src( src, secure )
			self.taint
			@conf.taint
			@title_procs.taint
			@body_enter_procs.taint
			@body_leave_procs.taint
			@section_index.taint
			@section_enter_procs.taint
			@comment_leave_procs.taint
			@subtitle_procs.taint
			@section_leave_procs.taint
			return Safe::safe( secure ? 4 : 1 ) do
				eval( src, binding, "(TDiary::Plugin#eval_src)", 1 )
			end
		end

	private
		def add_header_proc( block = Proc::new )
			@header_procs << block
		end

		def header_proc
			r = []
			@header_procs.each do |proc|
				r << proc.call
			end
			r.join.chomp
		end

		def add_footer_proc( block = Proc::new )
			@footer_procs << block
		end

		def footer_proc
			r = []
			@footer_procs.each do |proc|
				r << proc.call
			end
			r.join.chomp
		end

		def add_update_proc( block = Proc::new )
			@update_procs << block
		end

		def update_proc
			@update_procs.each do |proc|
				proc.call
			end
			''
		end

		def add_title_proc( block = Proc::new )
			@title_procs << block
		end

		def title_proc( date, title )
			@title_procs.each do |proc|
				title = proc.call( date, title )
			end
			apply_plugin( title )
		end

		def add_body_enter_proc( block = Proc::new )
			@body_enter_procs << block
		end

		def body_enter_proc( date )
			r = []
			@body_enter_procs.each do |proc|
				r << proc.call( date )
			end
			r.join
		end

		def add_body_leave_proc( block = Proc::new )
			@body_leave_procs << block
		end

		def body_leave_proc( date )
			r = []
			@body_leave_procs.each do |proc|
				r << proc.call( date )
			end
			r.join
		end

		def add_section_enter_proc( block = Proc::new )
			@section_enter_procs << block
		end

		def section_enter_proc( date )
			@section_index[date] = (@section_index[date] || 0) + 1
			r = []
			@section_enter_procs.each do |proc|
				r << proc.call( date, @section_index[date] )
			end
			r.join
		end

		def add_subtitle_proc( block = Proc::new )
			@subtitle_procs << block
		end

		def subtitle_proc( date, subtitle )
			@subtitle_procs.each do |proc|
				subtitle = proc.call( date, @section_index[date], subtitle )
			end
			apply_plugin( subtitle )
		end

		def add_section_leave_proc( block = Proc::new )
			@section_leave_procs << block
		end

		def section_leave_proc( date )
			r = []
			@section_leave_procs.each do |proc|
				r << proc.call( date, @section_index[date] )
			end
			r.join
		end

		def add_comment_leave_proc( block = Proc::new )
			@comment_leave_procs << block
		end

		def comment_leave_proc( date )
			r = []
			@comment_leave_procs.each do |proc|
				r << proc.call( date )
			end
			r.join
		end

		def add_edit_proc( block = Proc::new )
			@edit_procs << block
		end

		def edit_proc( date )
			r = []
			@edit_procs.each do |proc|
				r << proc.call( date )
			end
			r.join
		end

		def add_form_proc( block = Proc::new )
			@form_procs << block
		end

		def form_proc( date )
			r = []
			@form_procs.each do |proc|
				r << proc.call( date )
			end
			r.join
		end

		def add_conf_proc( key, label, genre = 'etc', block = Proc::new )
			return unless @mode =~ /^(conf|saveconf)$/
			genre_and_key = "#{genre}:#{key}"
			@conf_keys << genre_and_key unless @conf_keys.index( genre_and_key )
			@conf_procs[key] = [label, block]
		end

		def each_conf_genre
			genres = {}
			@conf_keys.each do |genre_and_key|
				genre, key = genre_and_key.split( /:/, 2 )
				next if genres[genre]
				yield genre
				genres[genre] = key
			end
		end

		def each_conf_key( genre )
			re = /^#{genre}:/
			@conf_keys.each do |genre_and_key|
				if re =~ genre_and_key then
					genre, key = genre_and_key.split( /:/, 2 )
					yield key
				end
			end
		end

		def conf_proc( key )
			r = ''
			_, block = @conf_procs[key]
			r = block.call if block
			r
		end

		def conf_genre_label( genre )
			label = @conf_genre_label[genre]
			label ? label : genre
		end

		def conf_label( key )
			label, = @conf_procs[key]
			label
		end

		def conf_current_style( key )
			if key == @cgi.params['conf'][0] then
				'selected'
			else
				'other'
			end
		end

		def add_cookie( cookie )
			begin
				@cookies << cookie
			rescue SecurityError
				raise SecurityError, "can't use cookies in plugin when secure mode"
			end
		end

		def enable_js( script )
			@javascripts << script unless @javascripts.index( script )
		end

		def add_js_setting( var, val = 'new Object()' )
			@javascript_setting << [var, val]
		end

		def add_content_proc( key, block = Proc::new )
			@content_procs[key] = block
		end

		def content_proc( key, date )
			unless @content_procs.key?( key )
				raise PluginError::new( "Plugin error: #{key} is not found." )
			end
			@content_procs[key].call( date )
		end

		def remove_tag( str )
			str.gsub( /<[^"'<>]*(?:"[^"]*"[^"'<>]*|'[^']*'[^"'<>]*)*(?:>|(?=<)|$)/, '' )
		end

		def apply_plugin( str, remove_tag = false )
			return '' unless str
			r = str.dup
			if @conf.options['apply_plugin'] and str.index( '<%' ) then
				r = str.untaint if $SAFE < 3
				Safe::safe( @conf.secure ? 4 : 1 ) do
					begin
						r = ERB::new( r ).result( binding )
					rescue Exception
						r = %Q|<p class="message">Invalid Text</p>#{r}|
					end
				end
			end
			r = remove_tag( r ) if remove_tag
			r
		end

		def disp_referer( table, ref )
			ref = @conf.to_native( CGI::unescape( ref ) )
			str = nil
			table.each do |url, name|
				if /#{url}/iu =~ ref then
					str = ref.gsub( /#{url}/iu, name )
					break
				end
			end
			str ? str : ref
		end

		def help( name )
			%Q[<span class="help-icon"><a href="http://docs.tdiary.org/#{h @conf.lang}/?#{h name}" target="_blank"><img src="#{theme_url}/help.png" width="19" height="19" alt="Help"></a></span>]
		end

		def method_missing( *m )
			super if @debug
			# ignore when no plugin
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
