#
# server: script for running standalone tdiary cgi server.
#
# Copyright (C) 2008-2010, Kakutani Shintaro <shintaro@kakutani.com>
# You can redistribute it and/or modify it under GPL2 or any later version.

task :server do
  $:.unshift File.expand_path('../../../', __FILE__).untaint
  require 'tdiary'

  unless File.exist?(TDiary.root + '/tdiary.conf')
    FileUtils.cp_r(TDiary.root + '/spec/fixtures/tdiary.conf.webrick',
      TDiary.root + '/tdiary.conf', :verbose => false)
  end
  unless File.directory?(TDiary.root + '/tmp/data')
    FileUtils.mkdir_p(TDiary.root + '/tmp/data/log')
    File.open(TDiary.root + '/tmp/data/tdiary.conf', 'w') do |f|
      f.write "tdiary_version = \"#{TDIARY_VERSION}\""
    end
    File.chmod(0644, TDiary.root + '/tmp/data/tdiary.conf')
  end

  opts = {
    :daemon => ENV['DAEMON'],
    :bind   => ENV['BIND'] || '0.0.0.0',
    :port   => ENV['PORT'] || 19292,
    :logger => $stderr,
    :access_log => $stderr,
  }

  TDiary::Server.run( opts )
end
