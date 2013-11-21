# -*- coding: utf-8; -*-
=begin
== NAME
tDiary: the "tsukkomi-able" web diary system.

Copyright (C) 2001-2013, TADA Tadashi <t@tdtds.jp>
You can redistribute it and/or modify it under GPL2.
=end

Encoding::default_external = 'UTF-8'

require 'tdiary/version'
TDIARY_VERSION = TDiary::VERSION

$:.unshift File.join(File::dirname(__FILE__), '/misc/lib').untaint
['/misc/lib/*/lib', '/vendor/*/lib'].each do |path|
	Dir["#{File::dirname(__FILE__) + path}"].each {|dir| $:.unshift dir.untaint }
end

require 'cgi'
require 'uri'
require 'fileutils'
require 'pstore'
require 'json'
require 'erb'
require 'tdiary/environment'
require 'tdiary/compatible'
require 'tdiary/core_ext'

#
# module TDiary
#
module TDiary
	PATH = File::dirname( __FILE__ ).untaint

	# tDiary configuration class, initialize tdiary.conf and stored configuration.
	autoload :Configuration,            'tdiary/configuration'
	autoload :Config,                   'tdiary/configuration'
	# tDiary plugin class, loading all Plugin and eval plugins in view context.
	autoload :Plugin,                   'tdiary/plugin'
	# tDiary Filter class, all filters is loaded by in TDiaryView.
	autoload :Filter,                   'tdiary/filter'

	# CGI standalone server
	autoload :Server,                   'tdiary/server'
	# Rack Application, TODO: integrate Server and Application
	autoload :Application,              'tdiary/application'

	# Diary model class
	autoload :Style,                    'tdiary/style'
	autoload :Comment,                  'tdiary/comment'

	# Routing and Dispatch
	autoload :Dispatcher,               'tdiary/dispatcher'
	# Rack Request and Reponse, If you don't use Rack, adopt Rack interface.
	autoload :Request,                  'tdiary/request'
	autoload :Response,                 'tdiary/response'

	# ViewController created by Dispatcher
	autoload :TDiaryBase,               'tdiary/base'
	autoload :TDiaryCategoryView,       'tdiary/base'
	autoload :TDiarySearch,             'tdiary/base'
	autoload :TDiaryPluginView,         'tdiary/base'
	autoload :TDiaryAuthorOnlyBase,     'tdiary/author_only_base'
	autoload :TDiaryFormPlugin,         'tdiary/author_only_base'
	autoload :TDiaryConf,               'tdiary/author_only_base'
	autoload :TDiarySaveConf,           'tdiary/author_only_base'
	autoload :TDiaryAdmin,              'tdiary/admin'
	autoload :TDiaryForm,               'tdiary/admin'
	autoload :TDiaryEdit,               'tdiary/admin'
	autoload :TDiaryPreview,            'tdiary/admin'
	autoload :TDiaryUpdate,             'tdiary/admin'
	autoload :TDiaryAppend,             'tdiary/admin'
	autoload :TDiaryReplace,            'tdiary/admin'
	autoload :TDiaryShowComment,        'tdiary/admin'
	autoload :TDiaryView,               'tdiary/view'
	autoload :TDiaryDay,                'tdiary/view'
	autoload :TDiaryComment,            'tdiary/view'
	autoload :TDiaryMonthBase,          'tdiary/view'
	autoload :TDiaryMonth,              'tdiary/view'
	autoload :TDiaryNYear,              'tdiary/view'
	autoload :TDiaryMonthWithoutFilter, 'tdiary/view'
	autoload :TDiaryLatest,             'tdiary/view'

	# Helper, these module called from ViewController and Plugins
	autoload :ViewHelper,               'tdiary/view_helper'

	#
	# exception classes
	#
	class TDiaryError < StandardError; end
	class PermissionError < TDiaryError; end
	class PluginError < TDiaryError; end
	class BadStyleError < TDiaryError; end
	class NotFound < TDiaryError;	end

	# class ForceRedirect
	#  force redirect to another page
	#
	class ForceRedirect < StandardError
		attr_reader :path
		def initialize( path )
			@path = path
		end
	end

	class << self
		def logger
			@@logger
		end

		def logger=(obj)
			@@logger = obj
		end

		def root
			library_root
		end

		# directory where tDiary libraries is located
		def library_root
			File.expand_path('..', __FILE__)
		end

		# directory where the server was started
		def server_root
			Dir.pwd
		end

		def configuration
			@@configuration ||= Configuration.new
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
