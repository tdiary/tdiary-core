# -*- coding: utf-8 -*-
# recent_comment.rb
#
# recent_comment: 最近のツッコミをリストアップする
#
# Copyright (c) 2002 TADA Tadashi <sho@spc.gr.jp>
# You can distribute this file under the GPL2.
#
def recent_comment_format(format, *args)
   format.gsub(/\$(\d)/) {|s| args[$1.to_i - 1]}
end

def recent_comment_init
   @conf['recent_comment.max'] ||= 3
   @conf['recent_comment.date_format'] ||= "(%m-%d)"
   @conf['recent_comment.except_list'] ||= ''
   @conf['recent_comment.format'] ||= '<a href="$2" title="$3">$4 $5</a>'
   @conf['recent_comment.notfound_msg'] ||= ''
end

def recent_comment( ob_max = 'OBSOLUTE', sep = 'OBSOLUTE', ob_form = 'OBSOLUTE', ob_except = 'OBSOLUTE' )
   recent_comment_init

   max = @conf['recent_comment.max']
   form = @conf['recent_comment.date_format']
   except = @conf['recent_comment.except_list']
   format = @conf['recent_comment.format']
   notfound_msg = @conf['recent_comment.notfound_msg']

   comments = []
   date = {}
   index = {}

   @diaries.each_value do |diary|
      next unless diary.visible?
      diary.each_comment_tail( max ) do |comment, idx|
         if (except != '') && (/#{except}/ =~ comment.name)
            next
         end
         comments << comment
         date[comment.date] = diary.date
         index[comment.date] = idx
      end
   end

   result = []

   comments.sort{|a,b| (a.date)<=>(b.date)}.reverse.each_with_index do |com,idx|
      break if idx >= max
      a = h(@index) + anchor("#{date[com.date].strftime( '%Y%m%d' )}#c#{'%02d' % index[com.date]}")
			# we can not escape anchor() to accomodate number_anchor.rb
      popup = h( com.shorten( @conf.comment_length ) )
      str = h( com.name )
      date_str = h( com.date.dup.strftime( form ) )
      result << "<li>"
      result << recent_comment_format(format, idx, a, popup, str, date_str)
      result << "</li>\n"
   end

   if result.size == 0
      notfound_msg
   else
      %Q|<ol class="recent-comment">\n| + result.join( '' ) + "</ol>\n"
   end
end

if @mode == 'saveconf'
   def saveconf_recent_comment
      @conf['recent_comment.max'] = @cgi.params['recent_comment.max'][0].to_i
      @conf['recent_comment.date_format'] = @cgi.params['recent_comment.date_format'][0]
      @conf['recent_comment.except_list'] = @cgi.params['recent_comment.except_list'][0]
      @conf['recent_comment.format'] = @cgi.params['recent_comment.format'][0]
      @conf['recent_comment.notfound_msg'] = @cgi.params['recent_comment.notfound_msg'][0]
   end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
