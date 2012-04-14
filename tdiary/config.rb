# -*- coding: utf-8; -*-
#
# class Config
#  configuration class
#
module TDiary
	class Config
		def initialize( cgi, request = nil )
			@cgi, @request = cgi, request
			configure_attrs
			configure_bot_pattern
			setup_attr_accessor_to_all_ivars
		end

		# saving to tdiary.conf in @data_path
		def save
			result = ERB::new( File::open( "#{TDiary::PATH}/skel/tdiary.rconf" ){|f| f.read }.untaint ).result( binding )
			result.untaint unless @secure
			Safe::safe( @secure ? 4 : 1 ) do
				eval( result, binding, "(TDiary::Config#save)", 1 )
			end
			@io_class.save_cgi_conf(self, result)
		end

		def mobile_agent?
			@cgi.mobile_agent?
		end

		def smartphone?
			@cgi.smartphone?
		end
		alias iphone? smartphone?

		def bot?
			@bot =~ @cgi.user_agent
		end

		#
		# get/set/delete plugin options
		#
		def []( key )
			@options[key]
		end

		def []=( key, val )
			@options2[key] = @options[key] = val
		end

		def delete( key )
			@options.delete( key )
			@options2.delete( key )
		end

		def base_url
			begin
				if @options['base_url'].length > 0 then
					return @options['base_url']
				end
			rescue
			end
			base_url_auto
		end

		def base_url_auto
			return '' unless @cgi.script_name
			begin
				if @cgi.https?
					port = (@cgi.server_port == 443) ? '' : ':' + @cgi.server_port.to_s
					"https://#{ @cgi.server_name }#{ port }#{File::dirname(@cgi.script_name)}/"
				else
					port = (@cgi.server_port == 80) ? '' : ':' + @cgi.server_port.to_s
					"http://#{ @cgi.server_name }#{ port }#{File::dirname(@cgi.script_name)}/"
				end.sub(%r|/+$|, '/')
			rescue SecurityError
				''
			end
		end

		if String.method_defined?(:encode)
			# preload transcodes outside $SAFE=4 environment, that is a workaround
			# for the possible SecurityError. see the following uri for the detail.
			# http://redmine.ruby-lang.org/issues/5279
			%w(utf-16be euc-jp iso-2022-jp Shift_JIS).each do |enc|
				"\uFEFF".encode(enc) rescue nil
			end

			def to_native( str, charset = nil )
				str = str.dup
				if str.encoding == Encoding::ASCII_8BIT
					str.force_encoding(charset || 'utf-8')
				end
				unless str.valid_encoding?
					str.encode!('utf-16be', {:invalid => :replace, :undef => :replace})
				end
				unless str.encoding == Encoding::UTF_8
					str.encode!('utf-8', {:invalid => :replace, :undef => :replace})
				end
				str
			end
		else
			require 'kconv'
			require 'iconv'
			require 'nkf'

			def to_native( str, charset = nil )
				return str if Kconv.isutf8(str)
				begin
					Iconv.conv('utf-8', charset || 'utf-8', str)
				rescue
					from = case charset
						when /^utf-8$/i
							'W'
						when /^shift_jis/i
							'S'
						when /^EUC-JP/i
							'E'
						else
							''
					end
					NKF::nkf("-m0 -#{from}w", str)
				end
			end
		end

	private
		# loading tdiary.conf in current directory
		def configure_attrs
			@secure = true unless @secure
			@options = {}

			eval( File::open( 'tdiary.conf' ) {|f| f.read }.untaint, b, "(tdiary.conf)", 1 )

			# language setup
			@lang = 'ja' unless @lang
			begin
				instance_eval( File::open( "#{TDiary::PATH}/tdiary/lang/#{@lang}.rb" ){|f| f.read }.untaint, "(tdiary/lang/#{@lang}.rb)", 1 )
			rescue Errno::ENOENT
				@lang = 'ja'
				retry
			end

			@data_path += '/' if /\/$/ !~ @data_path
			@style = 'tDiary' unless @style
			@index = './' unless @index
			@update = 'update.rb' unless @update
			@hide_comment_form = false unless defined?( @hide_comment_form )

			@author_name = '' unless @author_name
			@index_page = '' unless @index_page
			@hour_offset = 0 unless @hour_offset

			@html_title = '' unless @html_title
			@x_frame_options = nil unless @x_frame_options
			@header = '' unless @header
			@footer = '' unless @footer

			@section_anchor = '<span class="sanchor">_</span>' unless @section_anchor
			@comment_anchor = '<span class="canchor">_</span>' unless @comment_anchor
			@date_format = '%Y-%m-%d' unless @date_format
			@latest_limit = 10 unless @latest_limit
			@show_nyear = false unless @show_nyear

			@theme = 'default' if not @theme and not @css
			@css = '' unless @css

			@show_comment = true unless defined?( @show_comment )
			@comment_limit = 3 unless @comment_limit
			@comment_limit_per_day = 100 unless @comment_limit_per_day

			@show_referer = true unless defined?( @show_referer )
			@referer_limit = 10 unless @referer_limit
			@referer_day_only = true unless defined?( @referer_day_only )
			@no_referer = [] unless @no_referer
			@no_referer2 = [] unless @no_referer2
			@no_referer = @no_referer2 + @no_referer
			@only_volatile = [] unless @only_volatile
			@only_volatile2 = [] unless @only_volatile2
			@only_volatile = @only_volatile2 + @only_volatile
			@referer_table = [] unless @referer_table
			@referer_table2 = [] unless @referer_table2
			@referer_table = @referer_table2 + @referer_table

			@options = {} unless @options.class == Hash
			if @options2 then
				@options.update( @options2 )
			else
				@options2 = {}.taint
			end
			@options.taint

			# for 1.4 compatibility
			@section_anchor = @paragraph_anchor unless @section_anchor
		end

		# loading tdiary.conf in @data_path.
		def load_cgi_conf
			def_vars1 = ''
			def_vars2 = ''
			[
				:tdiary_version,
				:html_title, :author_name, :author_mail, :index_page, :hour_offset,
				:description, :icon, :banner, :x_frame_options,
				:header, :footer,
				:section_anchor, :comment_anchor, :date_format, :latest_limit, :show_nyear,
				:theme, :css,
				:show_comment, :comment_limit, :comment_limit_per_day,
				:mail_on_comment, :mail_header,
				:show_referer, :no_referer2, :only_volatile2, :referer_table2,
				:options2,
			].each do |var|
				def_vars1 << "#{var} = nil\n"
				def_vars2 << "@#{var} = #{var} unless #{var} == nil\n"
			end

			unless @io_class
				require 'tdiary/io/cache/file'
				require 'tdiary/io/default'
				@io_class = DefaultIO
			end

			cgi_conf = @io_class.load_cgi_conf(self)
			cgi_conf.untaint unless @secure

			b = binding.taint
			eval( def_vars1, b )
			Safe::safe( @secure ? 4 : 1 ) do
				begin
					eval( cgi_conf, b, "(TDiary::Config#load_cgi_conf)", 1 )
				rescue SyntaxError
					enc = case @lang
							when 'en'
								'UTF-8'
							else
								'EUC-JP'
							end
					cgi_conf.force_encoding( enc )
					retry
				end
			end if cgi_conf
			eval( def_vars2, b )
		end

		private
		def setup_attr_accessor_to_all_ivars
			names = instance_variables().collect {|ivar| ivar.to_s.sub(/@/, '') }
			(class << self; self; end).class_eval { attr_accessor *names }
		end

		def configure_bot_pattern
			bot = ["bot", "spider", "antenna", "crawler", "moget", "slurp"]
			bot += @options['bot'] || []
			@bot = Regexp::new( "(#{bot.uniq.join( '|' )})", true )
		end

		def method_missing( *m )
			(class << self; self; end).class_eval { attr_accessor m[0] } if m.length == 1
			nil
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
