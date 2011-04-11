#!/usr/bin/env ruby
# -*- coding: utf-8; -*-
#
# index.fcgi $Revision: 1.35 $
#
# Copyright (C) 2004, Akinori MUSHA
# Copyright (C) 2006, moriq
# Copyright (C) 2006-2009, Kazuhiko <kazuhiko@fdiary.net>
# You can redistribute it and/or modify it under GPL2.
#
require 'fcgi'
# workaround untaint LOAD_PATH for rubygems library path is always tainted.
$:.each{|path| path.untaint if path.include?('fcgi') && path.tainted? }

FCGI.each_cgi do |cgi|
  begin
    ENV.clear
    ENV.update(cgi.env_table)
    class << CGI; self; end.class_eval do
      define_method(:new) {|*args| cgi }
    end
    dir = File::dirname( cgi.env_table["SCRIPT_FILENAME"] )
    Dir.chdir(dir) do
      load 'index.rb'
    end
  ensure
    class << CGI
      remove_method :new
    end
  end
end
