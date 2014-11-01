#!/usr/bin/env ruby
# xmlrpc.rb
#
# Copyright (c) 2004 MoonWolf <moonwolf@moonwolf.com>
# Distributed under the GPL2 or any later version.
#
# require Ruby1.8 or xml-rpc(http://raa.ruby-lang.org/project/xml-rpc/)

BEGIN { $stdout.binmode }

if FileTest::symlink?( __FILE__ ) then
  org_path = File::dirname( File::readlink( __FILE__ ) )
else
  org_path = File::dirname( __FILE__ )
end
$:.unshift org_path.untaint
require 'tdiary'
require 'uri'

require 'xmlrpc/server'
if defined?(MOD_RUBY)
  server = XMLRPC::ModRubyServer.new
else
  server = XMLRPC::CGIServer.new
end

include TDiary::ViewHelper

@cgi = CGI::new
@conf = ::TDiary::Config::new(@cgi)

server.add_handler('blogger.newPost') do |appkey, blogid, username, password, content, publish|
  ENV['REQUEST_METHOD'] = 'POST'
  ENV['HTTP_REFERER'] = (URI.parse(base_url) + @conf.update).to_s
  if username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    begin
      postid = Time.now.strftime("%Y%m%d")
      year, month, day = postid.scan(/(\d{4})(\d\d)(\d\d)/)[0]
      @cgi.params['date']  = [postid]
      tdiary = ::TDiary::TDiaryDay::new( @cgi, "day.rhtml", @conf )
      time = Time::local( year, month, day ) + 12*60*60
      diary = tdiary[time] || tdiary.instance_variable_get(:@io).diary_factory(time, '', '', @conf.style)

      title,body = content.split(/\n/,2)
      index = diary.add_section(title, body)
      src = diary.to_src

      @cgi.params.delete 'date'
      @cgi.params['old']   = [postid]
      @cgi.params['hide']  = diary.visible? ? [] : ['true']
      @cgi.params['title'] = [diary.title]
      @cgi.params['year']  = [postid[0..3]]
      @cgi.params['month'] = [postid[4..5]]
      @cgi.params['day']   = [postid[6..7]]
      @cgi.params['body']  = [src]
      @cgi.params['csrf_protection_key']  = [@conf.options['csrf_protection_key']]
      ::TDiary::TDiaryReplace::new( @cgi, nil, @conf )
      postid + "%02d" % index
    rescue ::TDiary::ForceRedirect
      postid + "%02d" % index
    end
  else
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
end

server.add_handler('blogger.editPost') do |appkey, postid, username, password, content, publish|
  ENV['REQUEST_METHOD'] = 'POST'
  ENV['HTTP_REFERER'] = (URI.parse(base_url) + @conf.update).to_s
  unless username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
  begin
    @cgi.params['date']  = [postid[0,8]]
    tdiary = ::TDiary::TDiaryDay::new( @cgi, "day.rhtml", @conf )
    year, month, day, index = postid.scan(/(\d{4})(\d\d)(\d\d)(\d\d)/)[0]
    index = index.to_i
    time = Time::local( year, month, day ) + 12*60*60
    diary = tdiary[time]

    src = ''
    i = 0
    diary.each_section {|sec|
      i += 1
      if i==index
        subtitle,body = content.split(/\n/,2)
        sec.subtitle = subtitle
        sec.body     = (body || '').sub(/[\n\r]+\Z/, '') + "\n\n"
      end
      src << sec.to_src
    }

    @cgi.params.delete 'date'
    @cgi.params['old']   = [postid[0,8]]
    @cgi.params['hide']  = diary.visible? ? [] : ['true']
    @cgi.params['title'] = [diary.title]
    @cgi.params['year']  = [postid[0..3]]
    @cgi.params['month'] = [postid[4..5]]
    @cgi.params['day']   = [postid[6..7]]
    @cgi.params['body']  = [src]
    @cgi.params['csrf_protection_key']  = [@conf.options['csrf_protection_key']]
    ::TDiary::TDiaryReplace::new( @cgi, nil, @conf )
    true
  rescue ::TDiary::ForceRedirect
    true
  rescue Exception
    raise XMLRPC::FaultException.new(1,$!.to_s + "\n" + $!.backtrace.join("\n"))
  end
end

server.add_handler('blogger.deletePost') do |appkey, postid, username, password|
  ENV['REQUEST_METHOD'] = 'POST'
  ENV['HTTP_REFERER'] = (URI.parse(base_url) + @conf.update).to_s
  unless username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
  begin
    year, month, day, index = postid.scan(/(\d{4})(\d\d)(\d\d)(\d\d)/)[0]
    index = index.to_i
    @cgi.params['date']  = [postid[0,8]]
    tdiary = ::TDiary::TDiaryDay::new( @cgi, "day.rhtml", @conf )
    time = Time::local( year, month, day ) + 12*60*60
    diary = tdiary[time]

    diary.delete_section(index)
    src = diary.to_src

    @cgi.params.delete 'date'
    @cgi.params['old']   = [postid[0,8]]
    @cgi.params['hide']  = diary.visible? ? [] : ['true']
    @cgi.params['title'] = [diary.title]
    @cgi.params['year']  = [postid[0..3]]
    @cgi.params['month'] = [postid[4..5]]
    @cgi.params['day']   = [postid[6..7]]
    @cgi.params['body']  = [src]
    @cgi.params['csrf_protection_key']  = [@conf.options['csrf_protection_key']]
    ::TDiary::TDiaryReplace::new( @cgi, nil, @conf )
    true
  rescue ::TDiary::ForceRedirect
    true
  rescue Exception
    raise XMLRPC::FaultException.new(1,$!.to_s + "\n" + $!.backtrace.join("\n"))
  end
end

server.add_handler('blogger.getRecentPosts') do |appkey, blogid, username, password, numberOfPosts|
  unless username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
  result = []
  @cgi.params['title'] = ['']
  @cgi.params['body']  = ['']
  @cgi.params['hide']  = ['true']
  @conf.latest_limit = numberOfPosts
  tdiary = ::TDiary::TDiaryLatest::new( @cgi, 'latest.rhtml', @conf )
  tdiary.latest(numberOfPosts) {|diary|
    index = 0
    diary.each_section {|sec|
      index += 1
      postid = diary.date.strftime('%Y%m%d') + "%02d" % index
      author = sec.author || @conf['xmlrpc.userid']
      body  = sec.subtitle + "\n" + sec.body
      result << {
        'postid'      => postid,
        'userid'      => author,
        'content'     => body,
        'dateCreated' => diary.last_modified.utc
      }
    }
  }
  result.sort {|a,b| b['postid']<=>a['postid'] }[0,numberOfPosts]
end

server.add_handler('blogger.getUsersBlogs') do |appkey, username, password|
  unless username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
  result = [
    {
      'blogid'   => @conf['xmlrpc.blogid'],
      'blogName' => @conf.html_title,
      'url'      => base_url
    }
  ]
  result
end

server.add_handler('blogger.getUserInfo') do |appkey, username, password|
  unless username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
  result = {
    'nickname'  => @conf.author_name,
    'email'     => @conf.author_mail,
    'url'       => base_url,
    'lastname'  => @conf['xmlrpc.lastname'],
    'firstname' => @conf['xmlrpc.firstname'],
    'userid'    => @conf['xmlrpc.userid']
  }
  result
end

server.add_handler('metaWeblog.newPost') do |blogid, username, password, content, publish|
  ENV['REQUEST_METHOD'] = 'POST'
  ENV['HTTP_REFERER'] = (URI.parse(base_url) + @conf.update).to_s
  unless username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
  begin
    postid = Time.now.strftime("%Y%m%d")
    year, month, day = postid.scan(/(\d{4})(\d\d)(\d\d)/)[0]
    @cgi.params['date']  = [postid]
    tdiary = ::TDiary::TDiaryDay::new( @cgi, "day.rhtml", @conf )
    time = Time::local( year, month, day ) + 12*60*60
    diary = tdiary[time] || tdiary.instance_variable_get(:@io).diary_factory(time, '', '', @conf.style)

    index = diary.add_section(content['title'], content['description'])
    src = diary.to_src

    @cgi.params.delete 'date'
    @cgi.params['old']   = [postid]
    @cgi.params['hide']  = diary.visible? ? [] : ['true']
    @cgi.params['title'] = [diary.title]
    @cgi.params['year']  = [postid[0..3]]
    @cgi.params['month'] = [postid[4..5]]
    @cgi.params['day']   = [postid[6..7]]
    @cgi.params['body']  = [src]
    @cgi.params['csrf_protection_key']  = [@conf.options['csrf_protection_key']]
    ::TDiary::TDiaryReplace::new( @cgi, nil, @conf )
    postid + "%02d" % index
  rescue ::TDiary::ForceRedirect
    postid + "%02d" % index
  end
end

server.add_handler('metaWeblog.editPost') do |postid, username, password, content, publish|
  ENV['REQUEST_METHOD'] = 'POST'
  ENV['HTTP_REFERER'] = (URI.parse(base_url) + @conf.update).to_s
  unless username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
  begin
    @cgi.params['date']  = [postid[0,8]]
    tdiary = ::TDiary::TDiaryDay::new( @cgi, "day.rhtml", @conf )
    year, month, day, index = postid.scan(/(\d{4})(\d\d)(\d\d)(\d\d)/)[0]
    index = index.to_i
    time = Time::local( year, month, day ) + 12*60*60
    diary = tdiary[time]

    src = ''
    i = 0
    diary.each_section {|sec|
      i += 1
      if i==index
        sec.subtitle = content['title']
        sec.body     = content['description'] || ''.sub(/[\n\r]+\Z/, '') + "\n\n"
      end
      src << sec.to_src
    }

    @cgi.params.delete 'date'
    @cgi.params['old']   = [postid[0,8]]
    @cgi.params['hide']  = diary.visible? ? [] : ['true']
    @cgi.params['title'] = [diary.title]
    @cgi.params['year']  = [postid[0..3]]
    @cgi.params['month'] = [postid[4..5]]
    @cgi.params['day']   = [postid[6..7]]
    @cgi.params['body']  = [src]
    @cgi.params['csrf_protection_key']  = [@conf.options['csrf_protection_key']]
    ::TDiary::TDiaryReplace::new( @cgi, nil, @conf )
    true
  rescue ::TDiary::ForceRedirect
    true
  rescue Exception
    raise XMLRPC::FaultException.new(1,$!.to_s + "\n" + $!.backtrace.join("\n"))
  end
end

server.add_handler('metaWeblog.getPost') do |postid, username, password|
  unless username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
  @cgi.params['date'] = [postid[0,8]]
  tdiary = TDiary::TDiaryDay::new( @cgi, 'day.rhtml', @conf )
  year, month, day, index = postid.scan(/(\d{4})(\d\d)(\d\d)(\d\d)/)[0]
  index = index.to_i
  date = Time::local( year, month, day ) + 12*60*60
  diary = tdiary[date]
  i = 0
  result = {}
  diary.each_section {|sec|
    i += 1
    if i==index
      link = base_url + @conf.index.sub(%r|^\./|, '') + diary.date.strftime('%Y%m%d') + ".html\#p%02d" % i
      title = sec.stripped_subtitle || ''
      body  = sec.body
      result = {
        'userid'       => @conf['xmlrpc.userid'],
        'dateCreated'  => diary.last_modified.utc,
        'postid'       => postid,
        'description'  => body,
        'title'        => title,
        'link'         => link,
        'permaLink'    => link,
        'mt_excerpt'   => '',
        'mt_text_mode' => '',
        'mt_allow_comments' => 1,
        'mt_allow_pings' => 1,
        'mt_convert_breaks' => '__default__',
        'mt_keyword'   => ''
      }
      break
    end
  }
  result
end

server.add_handler('metaWeblog.getRecentPosts') do |blogid, username, password, numberOfPosts|
  unless username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
  result = []
  @cgi.params['title'] = ['']
  @cgi.params['body']  = ['']
  @cgi.params['hide']  = ['true']
  @conf.latest_limit = numberOfPosts
  tdiary = ::TDiary::TDiaryLatest::new( @cgi, 'latest.rhtml', @conf )
  tdiary.latest(numberOfPosts) {|diary|
    index = 0
    diary.each_section {|sec|
      index += 1
      postid = diary.date.strftime('%Y%m%d') + "%02d" % index
      link = base_url + @conf.index.sub(%r|^\./|, '') + diary.date.strftime('%Y%m%d') + ".html\#p%02d" % index
      title = sec.stripped_subtitle || ''
      body  = sec.body
      author = sec.author || @conf['xmlrpc.userid']
      result << {
        'dateCreated'       => diary.last_modified.utc,
        'userid'            => author,
        'postid'            => postid,
        'description'       => body,
        'title'             => title,
        'link'              => link,
        'permaLink'         => link,
        'mt_excerpt'        => '',
        'mt_text_more'      => '',
        'mt_allow_comments' => 1,
        'mt_allow_pings'    => 1,
        'mt_convert_breaks' => '__default__',
        'mt_keywords'       => '',
      }
    }
  }
  result.sort {|a,b| b['postid']<=>a['postid'] }[0,numberOfPosts]
end

server.add_handler('metaWeblog.newMediaObject') do |blogid, username, password, file|
  unless username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
  image_dir = @conf['image.dir'] || './images/'
  image_dir.chop! if /\/$/ =~ image_dir
  image_url = @conf['image.url'] || './images/'
  image_url.chop! if /\/$/ =~ image_url
  name = file['name']
  bits = file['bits']
  path = File.join(image_dir, name)
  open(path,'wb') {|f|
    f.write bits.to_s
  }
  {'url' => (URI.parse(base_url) + (image_url + '/' + name)).to_s }
end

server.add_handler('mt.getRecentPostTitles') do |blogid, username, password, numberOfPosts|
  unless username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
  result = []
  @cgi.params['title'] = ['']
  @cgi.params['body']  = ['']
  @cgi.params['hide']  = ['true']
  @conf.latest_limit = numberOfPosts
  tdiary = ::TDiary::TDiaryLatest::new( @cgi, 'latest.rhtml', @conf )
  tdiary.latest(numberOfPosts) {|diary|
    index = 0
    diary.each_section {|sec|
      index += 1
      postid = diary.date.strftime('%Y%m%d') + "%02d" % index
      author = sec.author || @conf['xmlrpc.userid']
      result << {
        'dateCreated'       => diary.last_modified.utc,
        'userid'            => author,
        'postid'            => postid,
        'title'             => sec.subtitle,
      }
    }
  }
  result.sort {|a,b| b['postid']<=>a['postid'] }
end

server.add_handler('mt.getCategoryList') do |blogid, username, password|
  unless username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
  @cgi.params['date'] = [Time.now.strftime('%Y%m%d')]
  tdiary = TDiary::TDiaryDay::new( @cgi, 'day.rhtml', @conf )
  list = []
  tdiary.calendar.each do |y, ms|
    ms.each do |m|
      ym = "#{y}#{m}"
      @cgi.params['date'] = [ym]
      m = ::TDiary::TDiaryMonth.new(@cgi, '', @conf)
      m.diaries.each do |ymd, diary|
        next if !diary.visible?
        diary.each_section do |s|
          list |= s.categories unless s.categories.empty?
        end
      end
    end
  end
  list = list.sort.uniq
  result = []
  list.each {|c|
    result << {
      'categoryId'   => c,
      'categoryName' => c
    }
  }
  result
end

server.add_handler('mt.getPostCategories') do |postid, username, password|
  unless username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
  @cgi.params['date'] = [postid[0,8]]
  tdiary = TDiary::TDiaryDay::new( @cgi, 'day.rhtml', @conf )
  result = []
  year, month, day, index = postid.scan(/(\d{4})(\d\d)(\d\d)(\d\d)/)[0]
  index = index.to_i
  time = Time::local( year, month, day ) + 12*60*60
  diary = tdiary[time]
  i = 0
  diary.each_section {|sec|
    i += 1
    if i==index
      sec.categories.each_with_index {|cat,j|
        result << {
          'categoryName' => cat,
          'categoryId'   => cat,
          'isPrimary'    => j==0
        }
      }
      break
    end
  }
  result
end

server.add_handler('mt.setPostCategories') do |postid, username, password, categories|
  ENV['REQUEST_METHOD'] = 'POST'
  ENV['HTTP_REFERER'] = (URI.parse(base_url) + @conf.update).to_s
  unless username == @conf['xmlrpc.username'] && password == @conf['xmlrpc.password']
    raise XMLRPC::FaultException.new(1,'userid or password incorrect')
  end
  begin
    @cgi.params['date']  = [postid[0,8]]
    tdiary = ::TDiary::TDiaryDay::new( @cgi, "day.rhtml", @conf )
    year, month, day, index = postid.scan(/(\d{4})(\d\d)(\d\d)(\d\d)/)[0]
    index = index.to_i
    time = Time::local( year, month, day ) + 12*60*60
    diary = tdiary[time]

    @cgi.params.delete 'date'

    src = ''
    i = 0
    diary.each_section {|sec|
      i += 1
      if i==index
        cats = []
        categories.sort {|a,b|
          a['isPrimary']==true ? 0 : 1
        }.each {|c|
          cats << c['categoryId']
        }
        sec.categories = cats
      end
      src << sec.to_src
    }

    @cgi.params['old']   = [postid[0,8]]
    @cgi.params['hide']  = diary.visible? ? [] : ['true']
    @cgi.params['title'] = [diary.title]
    @cgi.params['year']  = [postid[0..3]]
    @cgi.params['month'] = [postid[4..5]]
    @cgi.params['day']   = [postid[6..7]]
    @cgi.params['body']  = [src]
    @cgi.params['csrf_protection_key']  = [@conf.options['csrf_protection_key']]
    ::TDiary::TDiaryReplace::new( @cgi, nil, @conf )
    true
  rescue ::TDiary::ForceRedirect
    true
  rescue Exception
    raise XMLRPC::FaultException.new(1,$!.to_s + "\n" + $!.backtrace.join("\n"))
  end
end

server.add_handler('mt.supportedMethods') do
  [
    'blogger.newPost',
    'blogger.editPost',
    'blogger.getRecentPosts',
    'blogger.getUsersBlogs',
    'blogger.getUserInfo',
    'blogger.deletePost',
    'metaWeblog.getPost',
    'metaWeblog.newPost',
    'metaWeblog.editPost',
    'metaWeblog.getRecentPosts',
    'metaWeblog.newMediaObject',
    'mt.getCategoryList',
    'mt.setPostCategories',
    'mt.getPostCategories',
    'mt.getTrackbackPings',
    'mt.supportedTextFilters',
    'mt.getRecentPostTitles',
    'mt.publishPost'
  ]
end

server.add_handler('mt.supportedTextFilters') do
  ['__default__']
end

server.add_handler('mt.getTrackbackPings') do |postid|
  @cgi.params['date'] = [postid[0,8]]
  tdiary = TDiary::TDiaryDay::new( @cgi, 'day.rhtml', @conf )
  result = []
  date = Time::local( *postid.scan( /^(\d{4})(\d\d)(\d\d)(\d\d)$/ )[0] ) + 12*60*60
  tdiary[date].each_visible_trackback(100) {|com,i|
    url, _, title, _ = com.body.split( /\n/,4 )
    result << {
      'pingURL'   => url,
      'pingIP'    => '127.0.0.1',
      'pingTitle' => title,
    }
  }
  result
end

server.add_handler('mt.publishPost') do |postid, username, password|
  true
end

server.add_handler('mt.setNextScheduledPost') do |postid, dateCreated, username, password|
  true
end

server.serve

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
