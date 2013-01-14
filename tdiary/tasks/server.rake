# -*- coding: utf-8; -*-
#
# server: script for running standalone tdiary cgi server.
#
# Copyright (C) 2008-2010, Kakutani Shintaro <shintaro@kakutani.com>
# You can redistribute it and/or modify it under GPL2.

task :server do
  $:.unshift File.expand_path('../../../', __FILE__).untaint
  require 'tdiary'

  opts = {
    :daemon => ENV['DAEMON'],
    :bind   => ENV['BIND'] || '0.0.0.0',
    :port   => ENV['PORT'] || 19292
  }

  TDiary::Server.run( opts )
end
