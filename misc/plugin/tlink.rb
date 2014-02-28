# -*- coding: utf-8 -*-
# tlink.rb
#
# title 属性付 anchor plugin
#
# 使い方
#   <%= tlink( "URL", "文字列", "title 属性の中身（省略可）" ) %>
#
#   第 3 パラメータを省略した時、URL の末尾が c#?? ならば、
#   そのツッコミの内容が最初の行だけ表示されます。
#   末尾が p#?? ならば、サブタイトルがあればサブタイトルが、
#   なければ最初のパラグラフが表示されます。
#
#   例. <%= tlink( "http://tdiary.tdiary.net/20020131.html#c01", "このツッコミ" ) %>
#       出力結果:
#       <a href="http://tdiary.tdiary.net/20020131.html#c01", title="テストでござるよ">このツッコミ</a>
#
# Copyright(C) 2002 NT <nt@24i.net>
# Distributed under the GPL.
#
# Modified: by abbey <inlet@cello.no-ip.org>
#
=begin ChangeLog
2003-03-03 NT <nt@be.to>
	* add the function to try regetting a subtitle.

2003-01-29 NT <nt@be.to>
	* fix a critical bug.

2003-01-28 NT <nt@be.to>
	* correspond to change in movile mode.

2002-11-19 NT <nt@24i.net>
	* add require 'pstore'.

2002-07-01 NT <nt@24i.net>
	* change some regular expressions.

2002-05-18 NT <nt@24i.net>
	* remove "," from %Q[<a href="#{url}", title="#{title}">#{str}</a>].

2002-05-16 MUTOH Masao <mutoh@highway.ne.jp>
	* cache mechanism support.
	* code cleanup(remove require 'cgi',
		getcomment rename to tlink_getcomment).

2002-05-05 NT <nt@24i.net>
	* add URL to User-Agent

2002-04-21 abbey <inlet@cello.no-ip.org>
	* add error shori

2002-04-20 NT <nt@24i.net>
	* change User-Agent
	* modify some regular expressions

2002-04-19 NT <nt@24i.net>
	* modify some regular expressions
	* add User-Agent

2002-04-18 abbey <inlet@cello.no-ip.org>
	* adapt to port numbers except 80
	* adapt to #pXX

2002-04-17 NT <nt@24i.net>
	* create
=end

require 'net/http'
require 'kconv'
require 'pstore'

def tlink_initialize
  dir = @cache_path + "/tlink"
  @tlink_path = dir + "/tlink.dat"

  Dir.mkdir(dir, 0700) unless FileTest.exist?(dir)
  db = PStore.new(@tlink_path).transaction do |db|
    if (db.root?('tlinkdata')) then
      @tlink_dic = db["tlinkdata"]
    else
      @tlink_dic = Hash.new
    end
  end
end

def tlink_finalize
  db = PStore.new(@tlink_path)
  db.transaction do
    begin
      db["tlinkdata"] = @tlink_dic
    rescue PStore::Error
    end
  end
end

def tlink_getcomment( url )
  result = ""
  ref = base_url
  agent = { "User-Agent" => "DoCoMo (compatible; tDiary plugin; tlink; #{ref})" }
  host, path, frag = url.scan( %r[http://(.*?)/(.*)#((?:p|c)\d\d)] )[0]
  if /p0/ =~ frag
    frag = "(?:" + frag + "|" + frag.sub( /p/, "p#" ).sub( /#0/, "#" ) + ")"
  end
  port = 80
  if /(.*):(\d+)/ =~ host
    host = $1
    port = $2
  end
  hata = 0
  http = Net::HTTP.new( host, port )
  begin
    http.open_timeout = 3
    response , = http.get( "/#{path}", agent )
    response.body.each { |line|
      if %r[<A NAME="#{frag}] =~ line
        if %r[<(?:P|H3)><A NAME="#{frag}">(?:.*?)</A> (.*?)</(?:P|H3)>] =~ line.toutf8
          result = $1
          break
        else
          hata = 1
        end
      elsif hata == 1 && %r[^\t*(.*?)<BR>] =~ line.toutf8
        result = $1
        hata = 0
        break
      end
    }
  rescue
    result = ""
  end

  result = CGI::escapeHTML( result.gsub( %r[</?[aA](.*?)>], "" ) ).gsub( /&amp;nbsp;/, " " )
end

tlink_initialize

def tlink( url, str, title = nil )
  unless title
    if @tlink_dic[url] && %r[#(p|c)\d\d$] =~ url && @tlink_dic[url] != ''
      title = @tlink_dic[url]
    elsif @tlink_dic[url] && %r[#(p|c)\d\d$] !~ url
      title = @tlink_dic[url]
    else
      if /#{url}/ =~ ENV["REDIRECT_URL"] && /#{url}/ =~ @date.strftime('%Y%m%d')
      else
        title = tlink_getcomment( url )
        @tlink_dic[url] = title
        tlink_finalize
      end
    end
  end

  %Q[<a href="#{h url}" title="#{h title}">#{str}</a>]
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
