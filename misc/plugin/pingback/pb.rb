#!/usr/bin/env ruby
# pb.rb
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Copyright (c) 2004 MoonWolf <moonwolf@moonwolf.com>
# Distributed under the GPL
#
# require Ruby1.8 or xml-rpc(http://raa.ruby-lang.org/project/xml-rpc/)

BEGIN { $stdout.binmode }
$KCODE = 'n'

if FileTest::symlink?( __FILE__ ) then
  org_path = File::dirname( File::readlink( __FILE__ ) )
else
  org_path = File::dirname( __FILE__ )
end
$:.unshift org_path.untaint
require 'tdiary'

module TDiary
  #
  # exception class for Pingback
  #
  class TDiaryPingbackError < StandardError
  end
  
  #
  # class TDiaryPingbackBase
  #
  class TDiaryPingbackBase < ::TDiary::TDiaryBase
    public :mode
    def initialize( cgi, rhtml, conf )
      super
      date = @cgi.request_uri.scan(%r!/(\d{4})(\d\d)(\d\d)!)[0]
      if date
        @date = Time::local(*date)
      else
        @date = Time::now
      end
    end
    
    def diary_url
      @conf.base_url + @conf.index.sub(%r|^\./|, '') + @plugin.instance_eval(%Q|anchor "#{@date.strftime('%Y%m%d')}"|)
    end
  end
  
  #
  # class TDiaryPingbackReceive
  #  receive Pingback ping and store as comment
  #
  class TDiaryPingbackReceive < TDiaryPingbackBase
    def initialize( cgi, rhtml, conf )
      super
      @error = nil
      
      sourceURI = @cgi.params['sourceURI'][0]
      targetURI = @cgi.params['targetURI'][0]
      body = [sourceURI,targetURI].join("\n")
      @cgi.params['name'] = ['Pingback']
      @cgi.params['body'] = [body]
      
      @comment = ::TDiary::Comment::new('Pingback', '', body)
      begin
        @io.transaction( @date ) do |diaries|
          @diaries = diaries
          @diary = @diaries[@date.strftime('%Y%m%d')]
          if @diary and comment_filter( @diary, @comment ) then
            @diary.add_comment(@comment)
            DIRTY_COMMENT
          else
            @comment = nil
            DIRTY_NONE
          end
        end
      rescue
        @error = $!.message
      end
    end
    
    def eval_rhtml( prefix = '' )
      raise TDiaryPingbackError.new(@error) if @error
      load_plugins
      @plugin.instance_eval { update_proc }
    end
  end
end

require 'xmlrpc/server'
if defined?(MOD_RUBY)
  server = XMLRPC::ModRubyServer.new
else
  server = XMLRPC::CGIServer.new
end
server.add_handler("pingback.ping") do |sourceURI,targetURI|
  ENV['REQUEST_METHOD'] = 'POST'
  ENV['REQUEST_URI'] = targetURI
  @cgi = CGI::new
  @cgi.params['sourceURI'] = [sourceURI]
  @cgi.params['targetURI'] = [targetURI]
  conf = ::TDiary::Config::new(@cgi)
  tdiary = TDiary::TDiaryPingbackReceive::new( @cgi, 'day.rhtml', conf )
  tdiary.eval_rhtml
  "Pingback receive success"
end
server.serve

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=2
