# -*- coding: utf-8 -*-
#
# recent_comment3: 最近のツッコミをリストアップする
#
#   @secure = true な環境では動作しません．
#
# Copyright (c) 2002 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#
require 'pstore'
require 'fileutils'
require 'time'
require 'pathname'

def recent_comment3_format(format, *args)
	format.gsub(/\$(\d)/) {|s| args[$1.to_i - 1]}
end

def migrate_old_data
	# backward compatibility
	if File.exist?("#{@cache_path}/recent_comments") && !File.exist?("{#{@conf.data_path}/recent_comments")
		FileUtils.mv( "#{@cache_path}/recent_comments", "#{@conf.data_path}/recent_comments" )
	end
	# workaround for "/foo//bar" doesn't equal "/foo/bar"
	if @conf['recent_comment3.cache'] &&
			Pathname(@conf['recent_comment3.cache']).cleanpath == Pathname("#{@cache_path}/recent_comments").cleanpath
		@conf['recent_comment3.cache'] = "#{@conf.data_path}/recent_comments"
	end
end

def recent_comment3_init
	@conf['recent_comment3.cache'] ||= "#{@conf.data_path}/recent_comments"
	@conf['recent_comment3.cache_size'] ||= 50
	@conf['recent_comment3.max'] ||= 3
	@conf['recent_comment3.date_format'] ||= "(%m-%d)"
	@conf['recent_comment3.except_list'] ||= ''
	@conf['recent_comment3.format'] ||= '<a href="$2" title="$3">$4 $5</a>'
	@conf['recent_comment3.tree'] ||= ""
	@conf['recent_comment3.titlelen'] ||= 20
	@conf['recent_comment.notfound_msg'] ||= ''
end

def recent_comment3(ob_max = 'OBSOLUTE' ,sep = 'OBSOLUTE',ob_date_format = 'OBSOLUTE',*ob_except )
	return 'DO NOT USE IN SECURE MODE' if @conf.secure

	migrate_old_data
	recent_comment3_init

	cache = @conf['recent_comment3.cache'].untaint
	date_format = @conf['recent_comment3.date_format']
	excepts = @conf['recent_comment3.except_list'].split(/,/)
	format = @conf['recent_comment3.format']
	titlelen = @conf['recent_comment3.titlelen']
	notfound_msg = @conf['recent_comment.notfound_msg']

	entries = {}
	tree_order =[]
	order = []
	idx = 0

	PStore.new(cache).transaction do |db|
		break unless db.root?('comments')
		db['comments'].each do |c|
			break if c.nil? || idx >= @conf['recent_comment3.max']

			comment, date, serial = c
			next if excepts.include?(comment.name) || !comment.visible?

			a = h( @index ) + anchor("#{date.strftime('%Y%m%d')}#c#{'%02d' % serial}")
			# XXX handling Encoding::CompatibilityError
			popup = h(comment.shorten(@conf.comment_length)) rescue nil
			str = h(comment.name)
			date_str = h( comment.date.strftime(date_format) )

			idx += 1

			entry_date = "#{date.strftime('%Y%m%d')}"
			comment_str = entries[entry_date]

			if comment_str.nil?
				comment_str = []
				tree_order << entry_date
			end

			comment_str << recent_comment3_format(format, idx, a, popup, str, date_str)
			entries[entry_date] = comment_str
			order << entry_date
		end
		db.abort
	end

	result = []

	if @conf['recent_comment3.tree'] == "t"
		if entries.size == 0
			notfound_msg
		else
			cgi = CGI::new
			def cgi.referer; nil; end

			tree_order.each do |entry_date|
				a_entry = @index + anchor(entry_date)
				cgi.params['date'] = [entry_date]
				diary = TDiaryDay::new(cgi, '', @conf)
				title = diary.diaries[entry_date].title.gsub( /<[^>]*>/, '' ) if diary

				if title.nil? || title.length == 0 || title.strip.delete('　').delete(' ').length == 0 then
					date = Time.parse(entry_date)
					title = "#{date.strftime @date_format}"
				end

				result << "<li>"
				result << %Q|<a href="#{h( a_entry )}">#{h( @conf.shorten( title, titlelen ) )}</a><br>|
				entries[entry_date].sort.each do |comment_str|
					result << comment_str + "<br>"
				end
				result << "</li>\n"
			end

			%Q|<ul class="recent-comment">\n| + result.join( '' ) + "</ul>\n"
		end
	else
		if entries.size == 0
			''
		else
			order.each do | entry_date |
				result << "<li>#{entries[entry_date][0]}</li>\n"
				entries[entry_date].shift
			end
			%Q|<ol class="recent-comment">\n| + result.join( '' ) + "</ol>\n"
		end
	end
end

add_update_proc do
	migrate_old_data
	recent_comment3_init

	date = @date.strftime( '%Y%m%d' )
	cache = @conf['recent_comment3.cache'].untaint
	size = @conf['recent_comment3.cache_size']

	if @mode == 'comment' && @comment && @comment.visible?
		PStore.new(cache).transaction do |db|
			comment = @comment
			serial = 0
			@diaries[date].each_comment { serial += 1 }
			db['comments'] = Array.new( size ) unless db.root?('comments')
			if db['comments'][0].nil? or comment != db['comments'][0][0]
				db['comments'].unshift([comment, @date, serial]).pop
			end
		end
	elsif @mode == 'showcomment'
		PStore.new( cache ).transaction do |db|
			break unless db.root?('comments')

			@diaries[date].each_comment do |dcomment|
				db['comments'].each do |c|
					break if c.nil?

					comment, cdate, serial = c
					next if cdate.strftime('%Y%m%d') != date

					if comment == dcomment && comment.date.to_s == dcomment.date.to_s
						comment.show = dcomment.visible?
						next
					end
				end
			end
		end
	end
end

if @mode == 'saveconf'
	def saveconf_recent_comment3
		@conf['recent_comment3.max'] = @cgi.params['recent_comment3.max'][0].to_i
		@conf['recent_comment3.date_format'] = @cgi.params['recent_comment3.date_format'][0]
		@conf['recent_comment3.except_list'] = @cgi.params['recent_comment3.except_list'][0]
		@conf['recent_comment3.format'] = @cgi.params['recent_comment3.format'][0]
		@conf['recent_comment3.tree'] = @cgi.params['recent_comment3.tree'][0]
		@conf['recent_comment3.titlelen'] = @cgi.params['recent_comment3.titlelen'][0].to_i
		@conf['recent_comment.notfound_msg'] = @cgi.params['recent_comment.notfound_msg'][0]
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
