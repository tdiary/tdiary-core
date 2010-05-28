# pingback.rb
#
# Pingback when updating.
#
# options:
#   @options['pingback.url']    : URL of Pingback.
#   @options['pingback.expire'] : TTL for cache.
#
# Copyright (c) 2004 MoonWolf <moonwolf@moonwolf.com>
# Distributed under the GPL
#

add_header_proc do
  %Q!\t<link rel="pingback" href="#{h( @options['pingback.url'] )}" />\n!
end

add_update_proc do
  date = @date.strftime( "%Y%m%d" )
  diary = @diaries[date]
  
  require 'pstore'
  cache = {}
  PStore::new( "#{@cache_path}/pingback.cache" ).transaction do |db|
    begin
      cache = db['cache'] if db.root?( 'cache' )

      if /^append|replace$/ =~ @mode then
        index = 0
        diary.each_section do |section|
          index += 1
          id = "#{date}p%02d" % index
          my_url = %Q|#{h( @conf.index )}#{h( anchor(@date.strftime('%Y%m%d') ) )}|
          my_url[0, 0] = @conf.base_url if %r|^https?://|i !~ @conf.index
          my_url += "\#p%02d" % index
          my_url.gsub!( %r|/\./|, '/' )
          if diary.visible?
            html = ''
            html << section.subtitle_to_html if section.subtitle_to_html
            html << section.body_to_html
            html.scan(/<a\s(.+?)>/i) {
              begin
                attr = $1
                if attr=~/href\s*=\s*(?:"(http:.+?)"|'(http:.+?)')/
                  url = $1 || $2
                  raise if url=~/\.(gif|jpg|png|zip|lzh|rar|exe|tar|gz|bz2|txt)\z/i
                  @options['pingback.exclude'].each {|text|
                    text.strip!
                    next if text.empty?
                    raise if /#{text}/i =~ url
                  }
                  if t=cache[id+url]
                    if t<Time.now
                      pingback_send(my_url, url)
                      cache[id+url] = Time.now + @options['pingback.expire'].to_i
                    end
                  else
                    pingback_send(my_url, url)
                    cache[id+url] = Time.now + @options['pingback.expire'].to_i
                  end
                end
              rescue
              end
            }
          end
        end
      end

      db['cache'] = cache
    rescue PStore::Error
    end
  end
  
end

def pingback_send(sourceURI,targetURI)
  require 'uri'
  uri = URI.parse(targetURI)
  return unless uri.scheme=='http'
  # detect Pingback server URL
  target = nil
  require 'net/http'
  Net::HTTP.version_1_2
  Net::HTTP.start(uri.host, uri.port) {|http|
    path = uri.path
    path << "?" << uri.query if uri.query
    response = http.get(path)
    if value=response['X-Pingback']
      target = URI.parse(value)
    elsif response.body=~%r!<link rel="pingback" href="([^"]+)" ?/?>! #"
      target = URI.parse($1)
    end
  }
  return unless target
  # XMLRPC call
  require 'xmlrpc/client'
  path = target.path
  path << "?" << target.query if target.query
  server = XMLRPC::Client.new(target.host, path, target.port)
  param = server.call("pingback.ping", sourceURI, targetURI)
rescue Exception,Timeout::Error
end

#
# for conf_proc
#
def pingback_init
  @conf['pingback.url'] ||= ''
  @conf['pingback.expire'] ||= '86400'
  @conf['pingback.exclude'] ||= ''
end

def saveconf_pingback
  if @mode == 'saveconf' then
    @conf['pingback.url'] = @cgi.params['pingback.url'][0] || ''
    @conf['pingback.expire'] = @cgi.params['pingback.expire'][0] || '86400'
    @conf['pingback.exclude'] = @cgi.params['pingback.exclude'][0] || ''
  end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
