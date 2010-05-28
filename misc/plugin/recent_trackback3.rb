# -*- coding: utf-8 -*-
#
# recent_trackback3: 最近のツッコミをリストアップする
#
# Copyright (c) 2004 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
require 'pstore'
require 'fileutils'
require 'time'

def recent_trackback3_format(format, *args)
	format.gsub(/\$(\d)/) {|s| args[$1.to_i - 1]}
end

def recent_trackback3_init
	# backward compatibility
	if File.exists?( "#{@cache_path}/recent_trackbacks" ) then
		FileUtils.mv( "#{@cache_path}/recent_trackbacks", "#{@conf.data_path}/recent_trackbacks" )
	end
	if @conf['recent_trackback3.cache'] == "#{@cache_path}/recent_trackbacks" then
		@conf['recent_trackback3.cache'] = "#{@conf.data_path}/recent_trackbacks"
	end

	@conf['recent_trackback3.cache'] ||= "#{@conf.data_path}/recent_trackbacks"
	@conf['recent_trackback3.cache_size'] ||= 50
	@conf['recent_trackback3.n'] ||= 3
	@conf['recent_trackback3.date_format'] ||= "(#{@date_format} %H:%M)"
	@conf['recent_trackback3.format'] ||= '<a href="$2" title="$3">$4 $5</a>'
	@conf['recent_trackback3.tree'] ||= ""
	@conf['recent_trackback3.titlelen'] ||= 20
end

def recent_trackback3
	return 'DO NOT USE IN SECURE MODE' if @conf.secure
	
	recent_trackback3_init
	
	cache = @conf['recent_trackback3.cache'].untaint
	n = @conf['recent_trackback3.n']
	date_format = @conf['recent_trackback3.date_format']
	format = @conf['recent_trackback3.format']
	titlelen = @conf['recent_trackback3.titlelen']
	
   entries = {}
   tree_order = []
	order = []
   result = []
	idx = 0
	
	PStore.new(cache).transaction do |db|
		break unless db.root?('trackbacks')
		db['trackbacks'].each do |tb|
			break if idx >= n or tb == nil
			trackback, date, serial = tb
			next unless trackback.visible_true?
			
			url, blog_name, title, excerpt = trackback.body.split(/\n/, 4)
			
			a = h(@index) + anchor("#{date.strftime('%Y%m%d')}#t#{'%02d' % serial}")
			popup = h(@conf.shorten(excerpt, 60))
			str = [blog_name, title].compact.join(":").sub(/:$/, '')
			str = url if str == ''
			str = h(@conf.shorten(str, 30))
			date_str = h(trackback.date.strftime(date_format))
			
			idx += 1
			
			entry_date = "#{date.strftime('%Y%m%d')}"
			comment_str = entries[entry_date]
			
			if comment_str == nil then
				comment_str = []
				tree_order << entry_date
			end
			
			comment_str << recent_trackback3_format(format, idx, a, popup, str, date_str)
			entries[entry_date] = comment_str
         order << entry_date
		end
		db.abort
	end
	
   if @conf['recent_trackback3.tree'] == "t" then
      if entries.size == 0
         ''
      else
         cgi = CGI::new
         def cgi.referer; nil; end
			
         tree_order.each do | entry_date |
            a_entry = @index + anchor(entry_date)
            cgi.params['date'] = [entry_date]
            diary = TDiaryDay::new(cgi, '', @conf)
				
            if diary != nil then
               title = diary.diaries[entry_date].title.gsub( /<[^>]*>/, '' )
            end
            if title == nil || title.length == 0 || title.strip.delete('　').delete(' ').length == 0 then
               date = Time.parse(entry_date)
               title = "#{date.strftime @date_format}"
            end
				
            result << "<li>"
            result << %Q|<a href="#{h( a_entry )}">#{h( @conf.shorten( title, titlelen ) )}</a><br>|
				entries[entry_date].sort.each do | comment_str |
               result << comment_str + "<br>"
            end
            result << "</li>\n"
         end
         %Q|<ul class="recent-trackback">\n| + result.join( '' ) + "</ul>\n"
      end
   else
      if entries.size == 0
         ''
      else
         order.each do | entry_date |
            result << "<li>#{entries[entry_date][0]}</li>\n"
            entries[entry_date].shift
         end
         %Q|<ol class="recent-trackback">\n| + result.join( '' ) + "</ol>\n"
      end
   end
end

add_update_proc do
	
   recent_trackback3_init
	
   date = @date.strftime( '%Y%m%d' )
   cache = @conf['recent_trackback3.cache'].untaint
   cache_size = @conf['recent_trackback3.cache_size']
	
	if @mode == 'trackbackreceive' and @comment
		trackback = @comment
		serial = 0
		@diaries[date].each_visible_trackback {|tb, idx| serial += 1}
		PStore.new(cache).transaction do |db|
			db['trackbacks'] = Array.new(cache_size) unless db.root?('trackbacks')
			if db['trackbacks'][0].nil? or trackback != db['trackbacks'][0][0]
				db['trackbacks'].unshift([trackback, @date, serial]).pop
			end
		end
	elsif @mode == 'showcomment'
		PStore.new(cache).transaction do |db|
			break unless db.root?('trackbacks')
			@diaries[date].each_comment do |dtrackback|
				db['trackbacks'].each do |c|
					break if c.nil?
					trackback, tbdate, serial = c
					next if tbdate.strftime('%Y%m%d') != date
					if trackback == dtrackback and trackback.date == dtrackback.date
						trackback.show = (dtrackback.visible? and "TrackBack" != dtrackback.name)
						next
					end
				end
			end
		end
	end
end

if @mode == 'saveconf'
	def saveconf_recent_trackback3
		@conf['recent_trackback3.n'] = @cgi.params['recent_trackback3.n'][0].to_i
		@conf['recent_trackback3.date_format'] = @cgi.params['recent_trackback3.date_format'][0]
		@conf['recent_trackback3.format'] = @cgi.params['recent_trackback3.format'][0]
		@conf['recent_trackback3.tree'] = @cgi.params['recent_trackback3.tree'][0]
		@conf['recent_trackback3.titlelen'] = @cgi.params['recent_trackback3.titlelen'][0].to_i
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
