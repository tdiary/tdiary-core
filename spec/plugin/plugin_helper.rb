$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '../../misc/plugin')).untaint

require File.dirname(__FILE__) + "/../spec_helper"
require 'erb'

# FIXME PluginFake in under construction.
class PluginFake
	include ERB::Util

	attr_reader :conf
	attr_accessor :mode, :date

	def initialize
		@conf = Config.new
		@mode = ""
		@date = nil
		@header_procs = []
		@footer_procs = []
		@update_procs = []
		@conf_procs = []
		@body_enter_procs = []
		@body_leave_procs = []
	end

	def add_conf_proc( key, label, genre=nil, &block )
		@conf_procs << block
	end

	def add_header_proc( block = Proc::new )
		@header_procs << block
	end

	def add_footer_proc( block = Proc::new )
		@footer_procs << block
	end

	def add_update_proc( block = Proc::new )
		@update_procs << block
	end

	def conf_proc
		r = []
		@conf_procs.each do |proc|
			r << proc.call
		end
		r.join.chomp
	end

	def header_proc
		r = []
		@header_procs.each do |proc|
			r << proc.call
		end
		r.join.chomp
	end

	def footer_proc
		r = []
		@footer_procs.each do |proc|
			r << proc.call
		end
		r.join.chomp
	end

	def add_body_enter_proc( block = Proc::new )
		@body_enter_procs << block
	end

	def body_enter_proc( date )
		r = []
		@body_enter_procs.each do |proc|
			r << proc.call( date )
		end
		r.join.chomp
	end

	def add_body_leave_proc( block = Proc::new )
		@body_leave_procs << block
	end

	def body_leave_proc( date )
		r = []
		@body_leave_procs.each do |proc|
			r << proc.call( date )
		end
		r.join.chomp
	end

	class Config

		attr_accessor :index, :update, :author_name, :author_mail, :index_page,
			:html_title, :theme, :css, :date_format, :referer_table, :options, :cgi,
			:plugin_path, :lang, :style, :secure,
			:io_class

		def initialize
			@cgi = CGIFake.new
			@options = {}
			@options2 = {}
			@index = './'
			@html_title = ''
			@io_class = DummyIO

			bot = ["bot", "spider", "antenna", "crawler", "moget", "slurp"]
			bot += @options['bot'] || []
			@bot = Regexp::new( "(#{bot.uniq.join( '|' )})", true )
		end

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
		end

		def mobile_agent?
			@cgi.mobile_agent?
		end

		def bot?
			@bot =~ @cgi.user_agent
		end
	end

	def smartphone?
		@conf.cgi.smartphone?
	end
  alias iphone? smartphone?
end

class CGIFake
	attr_accessor :user_agent

	def initialize
		@user_agent = ""
	end

	def mobile_agent?
		self.user_agent =~ %r[
			^DoCoMo|
			^(?:KDDI|UP\.Browser)|
			^(?:J-(?:PHONE|EMULATOR)|Vodafone|SoftBank|MOT-|[VS]emulator)|
			WILLCOM|DDIPOCKET|
			PDXGW|ASTEL|Palmscape|Xiino|sharp\ pda\ browser|Windows\ CE|L-mode
		]x
	end

	def smartphone?
		self.user_agent =~ /iP(?:hone|od)/
	end
end

class DummyIO
	def self.plugin_open(conf); nil; end
	def self.plugin_close(storage); end
	def self.plugin_transaction(storage, plugin); end
end

def fake_plugin( name_sym, cgi=nil, base=nil, &block )
	plugin = PluginFake.new
	yield plugin if block_given?

	file_path = plugin_path( name_sym, base )
	plugin_name = File.basename( file_path, ".rb" )

	plugin.instance_eval do
		eval( File.read( file_path ), binding,
			"(#{File.basename(file_path)})", 1 )
	end
	plugin_sym = plugin_name.to_sym
	if plugin.class.private_method_defined?( plugin_sym )
		plugin.__send__( :public, plugin_sym )
	end

	plugin
end

def plugin_path( plugin_sym, base=nil )
	paths = []
	paths << ( base ? base : File.join(TDiary.root, "misc/plugin") )
	paths << "#{plugin_sym.to_s}.rb"
	File.expand_path( File.join( paths ))
end

def anchor( s )
	if /^([\-\d]+)#?([pct]\d*)?$/ =~ s then
		if $2 then
			"?date=#$1##$2"
		else
			"?date=#$1"
		end
	else
		""
	end
end
