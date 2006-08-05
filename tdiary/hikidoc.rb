# Copyright (c) 2005, Kazuhiko <kazuhiko@fdiary.net>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
# 
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of the HikiDoc nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
require 'uri'

class HikiDoc < String
  Revision = %q$Rev: 38 $

  def initialize( content = '', options = {} )
    @level = options[:level] || 1
    @empty_element_suffix = options[:empty_element_suffix] || ' />'
    super( content )
  end

  def to_html
    @stack = []
    @plugin_stack = []
    text = self.gsub( /\r\n?/, "\n" )
    text.sub!( /\n*\z/, "\n\n" )
    # escape '&', '<' and '>'
    text = escape_html( text )
    # escape some symbols
    text = escape_meta_char( text )
    # parse blocks
    text = block_parser( text )
    # remove needless new lines
    text.gsub!( /\n{2,}/, "\n" )
    # restore some html parts
    text = restore_block( text )
    text = restore_plugin_block( text )
    # unescape some symbols
    text = unescape_meta_char( text )
    # terminate with a single new line
    text.sub!( /\n*\z/, "\n" )
    text
  end

  private

  ######################################################################
  # block parser
  ######################################################################

  def block_parser( text )
    ret = text
    ret = parse_plugin( ret )
    ret = parse_pre( ret )
    ret = parse_comment( ret )
    ret = parse_header( ret )
    ret = parse_hrules( ret )
    ret = parse_list( ret )
    ret = parse_definition( ret )
    ret = parse_blockquote( ret )
    ret = parse_table( ret )
    ret = parse_paragraph( ret )
    ret.lstrip
  end

  ######################################################################
  # plugin

  PLUGIN_OPEN = '{{'
  PLUGIN_CLOSE = '}}'
  PLUGIN_SPLIT_RE = /(#{Regexp.union( PLUGIN_OPEN, PLUGIN_CLOSE )})/

  def parse_plugin( text )
    ret = ''
    plugin = false
    plugin_str = ''
    text.split( PLUGIN_SPLIT_RE ).each do |str|
      case str
      when PLUGIN_OPEN
        plugin = true
        plugin_str += str
      when PLUGIN_CLOSE
        if plugin
          plugin_str += str
          unless /['"]/ =~ plugin_str.gsub( /(['"]).*?\1/m, '' )
            plugin = false
            ret << store_plugin_block( unescape_meta_char( plugin_str, true ) )
            plugin_str = ''
          end
        else
          ret << str
        end
      else
        if plugin
          plugin_str << str
        else
          ret << str
        end
      end
    end
    ret << plugin_str if plugin
    ret
  end

  ######################################################################
  # pre

  MULTI_PRE_OPEN_RE = /&lt;&lt;&lt;/
  MULTI_PRE_CLOSE_RE = /&gt;&gt;&gt;/
  PRE_RE = /^[ \t]/

  def parse_pre( text )
    ret = text
    ret.gsub!( /^#{MULTI_PRE_OPEN_RE}$(.*?)^#{MULTI_PRE_CLOSE_RE}$/m ) do |str|
      "\n" + store_block( "<pre>%s</pre>" % restore_pre( $1 ) ) + "\n\n"
    end
    ret.gsub!( /(?:#{PRE_RE}.*\n?)+/ ) do |str|
      str.chomp!
      str.gsub!( PRE_RE, '' )
      "\n" + store_block( "<pre>\n%s\n</pre>" % restore_pre( str ) ) + "\n\n"
    end
    ret
  end

  def restore_pre( text )
    ret = unescape_meta_char( text, true )
    ret = restore_plugin_block( ret, true )
  end

  ######################################################################
  # header

  HEADER_RE = /!/

  def parse_header( text )
    text.gsub( /^(#{HEADER_RE}{1,#{7-@level}})\s*(.*)\n?/ ) do |str|
      level, title = $1.size + @level - 1, $2
      "\n<h#{level}>%s</h#{level}>\n\n" %
        inline_parser(title)
    end
  end

  ######################################################################
  # hrules

  HRULES_RE = /^----$/

  def parse_hrules( text )
    text.gsub( HRULES_RE ) do |str|
      "\n<hr#{@empty_element_suffix}\n"
    end
  end

  ######################################################################
  # list

  LIST_UL = '*'
  LIST_OL = '#'
  LIST_MARK_RE = Regexp.union( LIST_UL, LIST_OL )
  LIST_RE = /^((#{LIST_MARK_RE})\2*)\s*(.*)\n?/
  LISTS_RE = /(?:#{LIST_RE})+/

  def parse_list( text )
    text.gsub( LISTS_RE ) do |str|
      cur_str = "\n"
      list_type_array = []
      level = 0
      str.each do |line|
        if LIST_RE =~ line
          list_type = ( $2 == LIST_UL ? 'ul' : 'ol' )
          new_level, item = $1.size, $3
          if new_level > level
            (new_level - level).times do
              list_type_array << list_type
              cur_str << "<#{list_type}>\n<li>"
            end
            cur_str << "%s" % inline_parser( item )
          elsif new_level < level
            (level - new_level).times do
              cur_str << "</li>\n</#{list_type_array.pop}>"
            end
            cur_str << "</li>\n<li>%s" % inline_parser( item )
          elsif list_type == list_type_array.last
            cur_str << "</li>\n<li>%s" % inline_parser( item )
          else
            cur_str << "</li>\n</%s>\n" % list_type_array.pop
            cur_str << "<%s>\n" % list_type
            cur_str << "<li>%s" % inline_parser( item )
            list_type_array << list_type
          end
          level = new_level
        end
      end
      level.times do
        cur_str << "</li>\n</#{list_type_array.pop}>"
      end
      cur_str << "\n\n"
      cur_str
    end
  end

  ######################################################################
  # definition

  DEFINITION_RE = /^:(.*?)?:(.*)\n?/
  DEFINITIONS_RE = /(#{DEFINITION_RE})+/

  def parse_definition( text )
    parsed_text = text.gsub( DEFINITION_RE ) do |str|
      inline_parser( str )
    end
    parsed_text.gsub( DEFINITIONS_RE ) do |str|
      ret = "\n<dl>\n"
      str.chomp!
      str.scan( DEFINITION_RE ) do |t, d|
        if t.empty?
          ret << "<dd>%s</dd>\n" % d
        elsif d.empty?
          ret << "<dt>%s</dt>\n" % t
        else
          ret << "<dt>%s</dt><dd>%s</dd>\n" % [ t, d ]
        end
      end
      ret << "</dl>\n\n"
      ret
    end
  end

  ######################################################################
  # blockquote

  BLOCKQUOTE_RE = /^""[ \t]?/
  BLOCKQUOTES_RE = /(#{BLOCKQUOTE_RE}.*\n?)+/

  def parse_blockquote( text )
    text.gsub( BLOCKQUOTES_RE ) do |str|
      str.chomp!
      str.gsub!( BLOCKQUOTE_RE, '' )
      "\n<blockquote>\n%s\n</blockquote>\n\n" % block_parser(str)
    end
  end

  ######################################################################
  # table

  TABLE_SPLIT_RE = /\|\|/
  TABLE_RE = /^#{TABLE_SPLIT_RE}.+\n?/
  TABLES_RE = /(#{TABLE_RE})+/

  def parse_table( text )
    parsed_text = text.gsub( TABLE_RE ) do |str|
      inline_parser( str )
    end
    parsed_text.gsub( TABLES_RE ) do |str|
      ret = %Q|\n<table border="1">\n|
      str.each do |line|
        ret << "<tr>"
        line.chomp.sub( /#{TABLE_SPLIT_RE}$/, '').split( TABLE_SPLIT_RE, -1 )[1..-1].each do |i|
          tag = i.sub!( /^!/, '' ) ? 'th' : 'td'
          attr = ''
          if i.sub!( /^((?:\^|&gt;)+)/, '' )
            rs = $1.count( '^' ) + 1
            cs = $1.scan( /&gt;/ ).size + 1
            attr << ' rowspan="%d"' % rs if rs > 1
            attr << ' colspan="%d"' % cs if cs > 1
          end
          ret << "<#{tag}#{attr}>#{inline_parser( i )}</#{tag}>"
        end
        ret << "</tr>\n"
      end
      ret << "</table>\n\n"
      ret
    end
  end

  ######################################################################
  # comment

  COMMENT_RE = %r|^//.*\n?|

  def parse_comment( text )
    text.gsub( COMMENT_RE, '' )
  end

  ######################################################################
  # paragraph

  PARAGRAPH_BOUNDARY_RE = /\n{2,}/
  NON_PARAGRAPH_RE = /^<[^!]/

  def parse_paragraph( text )
    text.split( PARAGRAPH_BOUNDARY_RE ).collect { |str|
      str.chomp!
      if str.empty?
        ''
      elsif NON_PARAGRAPH_RE =~ str
        str
      else
        "<p>%s</p>" % inline_parser( str )
      end
    }.join( "\n\n" )
  end

  ######################################################################
  # inline parser
  ######################################################################

  def inline_parser( text )
    text = parse_link( text )
    text = parse_modifier( text )
  end

  ######################################################################
  # link and image

  IMAGE_RE = /\.(jpg|jpeg|gif|png)\z/i
  BRACKET_LINK_RE = /\[\[(.+?)\]\]/
  NAMED_LINK_RE = /(.+?)\|(.+)/
  URI_RE = /(?:(?:https?|ftp|file):|mailto:)[A-Za-z0-9;\/?:@&=+$,\-_.!~*\'()#%]+/

  def parse_link( text )
    ret = text
    ret.gsub!( BRACKET_LINK_RE ) do |str|
      link = $1
      if NAMED_LINK_RE =~ link
        uri, title = $2, $1
        title = parse_modifier( title )
      else
        uri = title = link
      end
      uri.sub!( /^(?:https?|ftp|file)+:/, '' ) if %r|://| !~ uri && /^mailto:/ !~ uri
      store_block( %Q|<a href="#{escape_quote( uri )}">#{title}</a>| )
    end
    ret.gsub!( URI_RE ) do |uri|
      uri.sub!( /^\w+:/, '' ) if %r|://| !~ uri && /^mailto:/ !~ uri
      if IMAGE_RE =~ uri
        store_block( %Q|<img src="#{uri}" alt="#{File.basename( uri )}"#{@empty_element_suffix}| )
      else
        store_block( %Q|<a href="#{uri}">#{uri}</a>| )
      end
    end
    ret
  end

  ######################################################################
  # modifier( strong, em, re )

  STRONG = "'''"
  EM = "''"
  DEL = '=='
  MODIFIER_RE = /(#{STRONG}|#{EM}|#{DEL})(.+?)(?:\1)/

  def parse_modifier( text )
    text.gsub( MODIFIER_RE ) do |str|
      case $1
      when STRONG
        store_block( "<strong>#{parse_modifier($2)}</strong>" )
      when EM
        store_block( "<em>#{parse_modifier($2)}</em>" )
      when DEL
        store_block( "<del>#{parse_modifier($2)}</del>" )
      end
    end
  end

  ######################################################################
  # utility methods
  ######################################################################

  def escape_html( text )
    text.gsub( /&/, '&amp;' ).
      gsub( /</, '&lt;' ).
      gsub( />/, '&gt;' )
  end

  def escape_quote( text )
    text.gsub( /"/, '&quot;' )
  end

  def store_block( text )
    key = "<#{@stack.size}>"
    @stack << text
    key
  end

  BLOCK_RE = /<(\d+)>/

  def restore_block( text )
    return text if @stack.empty?
    ret = text.dup
    while ret.gsub!( BLOCK_RE ) { |str|
      ( @stack[$1.to_i] || '' ).rstrip
      }
    end
    ret
  end

  def store_plugin_block( text )
    key = "<!#{@plugin_stack.size}>"
    @plugin_stack << text
    key
  end

  PLUGIN_BLOCK_RE = /<!(\d+)>/
  INLINE_PLUGIN_RE = %r|<p><!(\d+)></p>|
  INLINE_PLUGIN_OPEN = '<span class="plugin">'
  INLINE_PLUGIN_CLOSE = '</span>'
  BLOCK_PLUGIN_OPEN = '<div class="plugin">'
  BLOCK_PLUGIN_CLOSE = '</div>'

  def restore_plugin_block( text, original = false )
    return text if @plugin_stack.empty?
    if original
      text.gsub!( PLUGIN_BLOCK_RE ) do |str|
        @plugin_stack[$1.to_i]
      end
    else
      # block plugin
      text.gsub!( INLINE_PLUGIN_RE ) do |str|
        "#{BLOCK_PLUGIN_OPEN}#{@plugin_stack[$1.to_i]}#{BLOCK_PLUGIN_CLOSE}"
      end
      text.gsub!( PLUGIN_BLOCK_RE ) do |str|
        "#{INLINE_PLUGIN_OPEN}#{@plugin_stack[$1.to_i]}#{INLINE_PLUGIN_CLOSE}"
      end
    end
    text
  end

  META_CHAR_RE = /\\\{|\\\}|\\:|\\'|\\"|\\\|/

  def escape_meta_char( text )
    text.gsub( META_CHAR_RE ) do |s|
      '&#x%x;' % s[1]
    end
  end

  ESCAPED_META_CHAR_RE = /(?:&\#x([0-9a-f]{2});)/i

  def unescape_meta_char( text, original = false )
    text.gsub( ESCAPED_META_CHAR_RE ) do
      if original
        '\\' + [$1].pack( 'H2' )
      else
        [$1].pack( 'H2' )
      end
    end
  end
end

if __FILE__ == $0
  puts HikiDoc.new( ARGF.read ).to_html
end
