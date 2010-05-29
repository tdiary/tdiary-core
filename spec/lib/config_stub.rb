# -*- coding: utf-8 -*-
require 'tdiary'

class ConfigStub < TDiary::Config
	def initialize(cgi, &block)
		if block_given?
			@current_directory_proc = block
		end
		super
	end

	def load_conf_current_directory
		if @current_directory_proc
			self.instance_eval(&@current_directory_proc)
		else
			load_conf_current_directory_orig
		end
	end
	alias :load_conf_current_directory_orig :load_conf_current_directory
end

#	attr_accessor :lang, :bot, :cgi

# Langごとで定義されるinstanceメソッド
# html_lang
# encoding
# mobile_encoding
# to_native( str, charset = nil )
# to_mobile( str )
# to_mail( str )
# shorten( str, len = 120 )
# comment_length
#end
