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
  def initialize( content = '', options = {} )
    @level = options[:level] || 1
    @empty_element_suffix = options[:empty_element_suffix] || ' />'
    super( content )
  end

  def to_html
    @stack = []
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
    ret = parse_header( ret )
    ret = parse_hrules( ret )
    ret = parse_list( ret )
    ret = parse_definition( ret )
    ret = parse_blockquote( ret )
    ret = parse_table( ret )
    ret = parse_comment( ret )
    ret = parse_paragraph( ret )
    ret.lstrip
  end

  ######################################################################
  # plugin

  PLUGIN_OPEN = '{{'
  PLUGIN_CLOSE = '}}'
  PLUGIN_RE = /#{Regexp.quote(PLUGIN_OPEN)}.*?#{Regexp.quote(PLUGIN_CLOSE)}/m
  PLUGIN_OUT_OPEN = '<span class="plugin">'
  PLUGIN_OUT_CLOSE = '</span>'

  def parse_plugin( text )
    # escape quotes
    ret = text.gsub( /(['"]).*?\1/ ) { |str| store_block( str ) }
    ret.split( /(#{PLUGIN_RE})/ ).collect { |str|
      case str
      when PLUGIN_RE
        store_block( "#{PLUGIN_OUT_OPEN}#{restore_block( str )}#{PLUGIN_OUT_CLOSE}" )
      else
        restore_block( str )
      end
    }.join
  end

  ######################################################################
  # pre

  PRE_RE = / /
  MULTI_PRE_OPEN_RE = /&lt;&lt;&lt;/
  MULTI_PRE_CLOSE_RE = /&gt;&gt;&gt;/

  def parse_pre( text )
    ret = text
    ret.gsub!( /^#{MULTI_PRE_OPEN_RE}$(.*)^#{MULTI_PRE_CLOSE_RE}$/m ) do |str|
      "\n" + store_block( "<pre>%s</pre>" % restore_pre( $1 ) ) + "\n\n"
    end
    ret.gsub!( /(?:^#{PRE_RE}.*\n?)+/ ) do |str|
      str.chomp!
      str.gsub!( /^#{PRE_RE}/, '' )
      "\n" + store_block( "<pre>\n%s\n</pre>" % restore_pre( str ) ) + "\n\n"
    end
    ret
  end

  def restore_pre( text )
    ret = unescape_meta_char( text, true )
    ret = restore_block( ret )
    ret.gsub( %r|#{PLUGIN_OUT_OPEN}(.+?)#{PLUGIN_OUT_CLOSE}|m, '\1' )
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

  HRULES_RE = /----/

  def parse_hrules( text )
    text.gsub( /^#{HRULES_RE}$/ ) do |str|
      "\n<hr#{@empty_element_suffix}\n"
    end
  end

  ######################################################################
  # list

  LIST_UL = '*'
  LIST_OL = '#'
  LIST_RE = Regexp.union( LIST_UL, LIST_OL )

  def parse_list( text )
    text.gsub( /(?:^(#{LIST_RE})\1*\s*.*\n?)+/ ) do |str|
      cur_str = "\n"
      list_type_array = []
      level = 0
      str.each do |line|
        if /^((#{LIST_RE})\2*)\s*(.*)/ =~ line
          list_type = ( $2 == LIST_UL ? 'ul' : 'ol' )
          new_level, item = $1.size, $3
          if new_level > level
            new_level = level + 1
            list_type_array << list_type
            cur_str << "<#{list_type}>\n<li>%s" % inline_parser( item )
          elsif new_level < level
            (level - new_level).times do
              cur_str << "</li>\n</#{list_type_array.pop}>\n</li>\n"
            end
            cur_str << "<li>%s" % inline_parser( item )
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
        cur_str << "</li>\n</#{list_type_array.pop}>\n\n"
      end
      cur_str
    end
  end

  ######################################################################
  # definition

  DEFINITION_RE = /:/

  def parse_definition( text )
    text.gsub( /(^#{DEFINITION_RE}.*#{DEFINITION_RE}.+\n?)+/ ) do |str|
      ret = "\n<dl>\n"
      str.strip!
      str.scan( /^#{DEFINITION_RE}(.*?)#{DEFINITION_RE}(.+)\n?/ ) do |t, d|
        if t.empty?
          ret << "<dd>%s</dd>\n" % inline_parser( d )
        else
          ret << "<dt>%s</dt><dd>%s</dd>\n" % [ inline_parser( t ), inline_parser( d ) ]
        end
      end
      ret << "</dl>\n\n"
      ret
    end
  end

  ######################################################################
  # blockquote

  BLOCKQUOTE_RE = /""/

  def parse_blockquote( text )
    text.gsub( /(^#{BLOCKQUOTE_RE} ?.*\n?)+/ ) do |str|
      str.strip!
      str.gsub!( /^#{BLOCKQUOTE_RE} ?/, '' )
      "\n<blockquote>\n%s\n</blockquote>\n\n" % block_parser(str).rstrip
    end
  end

  ######################################################################
  # table

  TABLE_RE = /\|\|/

  def parse_table( text )
    text.gsub( /(^#{TABLE_RE}.+\n?)+/ ) do |str|
      ret = %Q|\n<table border="1">\n|
      str.each do |line|
        ret << "<tr>"
        line.strip.split( TABLE_RE )[1..-1].each do |i|
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

  COMMENT_RE = %r|//|

  def parse_comment( text )
    text.gsub( /^#{COMMENT_RE}.*\n?/, '' )
  end

  ######################################################################
  # paragraph

  def parse_paragraph( text )
    text.split( /\n{2,}/ ).collect { |str|
      str.strip!
      if str.empty?
        ''
      elsif /^</ =~ str
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

  def parse_link( text )
    ret = text
    ret.gsub!( /\[\[(.+?)\]\]/ ) do |str|
      link = $1
      if /(.+?)\|(.+)/ =~ link
        uri, title = $2, $1
        title = parse_modifier( title )
      else
        uri = title = link
      end
      if /\A#{URI.regexp( %w( http https ftp mailto ) )}\z/ =~ uri
        if IMAGE_RE =~ uri
          store_block( %Q|<img src="#{uri}" alt="#{File.basename( title )}"#{@empty_element_suffix}| )
        else
          store_block( %Q|<a href="#{uri}">#{title}</a>| )
        end
      else
        uri = escape_uri( uri )
        store_block( %Q|<a href="#{uri}">#{title}</a>| )
      end
    end
    ret.gsub!( URI.regexp( %w( http https ftp mailto ) ) ) do |uri|
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
  STRONG_RE = /#{STRONG}(.+)#{STRONG}/
  EM_RE = /#{EM}(.+)#{EM}/
  DEL_RE = /#{DEL}(.+)#{DEL}/

  def parse_modifier( text )
    text.gsub( /(#{STRONG_RE}|#{EM_RE}|#{DEL_RE})/ ) do |str|
      case str
      when STRONG_RE
        "<strong>#{$1}</strong>"
      when EM_RE
        "<em>#{$1}</em>"
      when DEL_RE
        "<del>#{$1}</del>"
      else
        str
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

  def unescape_html( text )
    text.gsub( /&gt;/, '>' ).
      gsub( /&lt;/, '<' ).
      gsub( /&amp;/, '&' )
  end

  def escape_uri( text )
    text.gsub( /([^ a-zA-Z0-9_.-]+)/n ) do
      '%' + $1.unpack( 'H2' * $1.size ).join('%').upcase
    end.tr( ' ', '+' )
  end

  def unescape_uri( text )
    text.tr( '+', ' ' ).gsub( /((?:%[0-9a-fA-F]{2})+)/n ) do
      [$1.delete( '%' )].pack( 'H*' )
    end
  end


  def store_block( text )
    key = "<#{@stack.size}>"
    @stack << text
    key
  end

  def restore_block( text )
    return text if @stack.empty?
    text.gsub( /<(\d+)>/ ) do |str|
      ( @stack[$1.to_i] || '' ).rstrip
    end
  end

  META_CHARS_RE = /\\\{|\\\}|\\:|\\'|\\"|\\\|/

  def escape_meta_char( text )
    text.gsub( META_CHARS_RE ) do |s|
      '&#x%x;' % s[1]
    end
  end

  def unescape_meta_char( text, escape = false )
    text.gsub( /(?:&\#x([0-9a-f]{2});)/i ) do
      if escape
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
