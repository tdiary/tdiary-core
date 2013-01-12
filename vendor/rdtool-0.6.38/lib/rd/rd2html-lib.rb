=begin
= rd2html-lib.rb
=end

require "cgi"
require "rd/rdvisitor"
require "rd/version"

module RD
  class RD2HTMLVisitor < RDVisitor
    include MethodParse

    SYSTEM_NAME = "RDtool -- RD2HTMLVisitor"
    SYSTEM_VERSION = "$Version: "+ RD::VERSION+"$" 
    VERSION = Version.new_from_version_string(SYSTEM_NAME, SYSTEM_VERSION)

    def self.version
      VERSION
    end
    
    # must-have constants
    OUTPUT_SUFFIX = "html"
    INCLUDE_SUFFIX = ["html"]
    
    METACHAR = { "<" => "&lt;", ">" => "&gt;", "&" => "&amp;" }

    attr_accessor :css
    attr_accessor :charset
    alias charcode charset
    alias charcode= charset=
    attr_accessor :lang
    attr_accessor :title
    attr_reader :html_link_rel
    attr_reader :html_link_rev
    attr_accessor :use_old_anchor
    # output external Label file.
    attr_accessor :output_rbl

    attr_reader :footnotes
    attr_reader :foottexts

    def initialize
      @css = nil
      @charset = nil
      @lang = nil
      @title = nil
      @html_link_rel = {}
      @html_link_rev = {}

      @footnotes = []
      @index = {}

      #      @use_old_anchor = nil
      @use_old_anchor = true # MUST -> nil
      @output_rbl = nil
      super
    end
    
    def visit(tree)
      prepare_labels(tree, "label-")
      prepare_footnotes(tree)
      tmp = super(tree)
      make_rbl_file(@filename) if @output_rbl and @filename
      tmp
    end

    def apply_to_DocumentElement(element, content)
      ret = ""
      ret << xml_decl + "\n"
      ret << doctype_decl + "\n"
      ret << html_open_tag + "\n"
      ret << html_head + "\n"
      ret << html_body(content) + "\n"
      ret << "</html>\n"
      ret
    end

    def document_title
      return @title if @title
      return @filename if @filename
      return @input_filename unless @input_filename == "-"
      "Untitled"
    end
    private :document_title

    def xml_decl
      encoding = %[encoding="#{@charset}" ] if @charset
      %|<?xml version="1.0" #{encoding}?>|
    end
    private :xml_decl

    def doctype_decl
      %|<!DOCTYPE html \n| +
      %|  PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"\n| +
      %|  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">|
    end
    private :doctype_decl

    def html_open_tag
      lang_attr = %[ lang="#{@lang}" xml:lang="#{@lang}"] if @lang
      %|<html xmlns="http://www.w3.org/1999/xhtml"#{lang_attr}>|
    end
    private :html_open_tag

    def html_head
      ret = %|<head>\n|
      ret << html_content_type + "\n" if html_content_type
      ret << html_title + "\n"
      ret << link_to_css + "\n" if link_to_css
      ret << forward_links + "\n" if forward_links
      ret << backward_links + "\n" if backward_links
      ret << %Q[</head>]
    end 
    private :html_head

    def html_title
      "<title>#{document_title}</title>"
    end
    private :html_title

    def html_content_type
      if @charset
	%Q[<meta http-equiv="Content-type" ] +
	  %Q[content="text/html; charset=#{@charset}" ] +
	  "/>"
      end
    end
    private :html_content_type

    def link_to_css
      if @css
	%|<link href="#{@css}" type="text/css" rel="stylesheet" | +
	  "/>" # for ruby-mode.el fontlock, it is separated into 2 lines.
      end
    end
    private :link_to_css

    def forward_links
      return nil if @html_link_rel.empty?
      rels = @html_link_rel.sort{|i, j| i[0] <=> j[0] }
      (rels.collect do |rel, href|
	%Q[<link href="#{href}" rel="#{rel}" />]
      end).join("\n")
    end
    private :forward_links

    def backward_links
      return nil if @html_link_rev.empty?
      revs = @html_link_rev.sort{|i, j| i[0] <=> j[0] }
      (revs.collect do |rev, href|
	%Q[<link href="#{href}" rev="#{rev}" />]
      end).join("\n")
    end
    private :backward_links

    def html_body(contents)
      content = contents.join("\n")
      foottext = make_foottext
      %Q|<body>\n#{content}\n#{foottext}\n</body>|
    end
    private :html_body
    
    def apply_to_Headline(element, title)
      anchor = get_anchor(element)
      label = hyphen_escape(element.label)
      title = title.join("")
      %Q[<h#{element.level}><a name="#{anchor}" id="#{anchor}">#{title}</a>] +
      %Q[</h#{element.level}><!-- RDLabel: "#{label}" -->]
    end

    # RDVisitor#apply_to_Include 

    def apply_to_TextBlock(element, content)
      content = content.join("")
      if (is_this_textblock_only_one_block_of_parent_listitem?(element) or
	  is_this_textblock_only_one_block_other_than_sublists_in_parent_listitem?(element))
	content.chomp
      else
	%Q[<p>#{content.chomp}</p>]
      end
    end

    def is_this_textblock_only_one_block_of_parent_listitem?(element)
      parent = element.parent
      (parent.is_a?(ItemListItem) or
       parent.is_a?(EnumListItem) or
       parent.is_a?(DescListItem) or
       parent.is_a?(MethodListItem)) and
	consist_of_one_textblock?(parent)
    end

    def is_this_textblock_only_one_block_other_than_sublists_in_parent_listitem?(element)
      parent = element.parent
      (parent.is_a?(ItemListItem) or
       parent.is_a?(EnumListItem) or
       parent.is_a?(DescListItem) or
       parent.is_a?(MethodListItem)) and
	consist_of_one_textblock_and_sublists(element.parent)
    end

    def consist_of_one_textblock_and_sublists(element)
      i = 0
      element.each_child do |child|
	if i == 0
	  return false unless child.is_a?(TextBlock)
	else
	  return false unless child.is_a?(List)
	end
	i += 1
      end
      return true
    end

    def apply_to_Verbatim(element)
      content = []
      element.each_line do |i|
	content.push(apply_to_String(i))
      end
      %Q[<pre>#{content.join("").chomp}</pre>]
    end
  
    def apply_to_ItemList(element, items)
      %Q[<ul>\n#{items.join("\n").chomp}\n</ul>]
    end
  
    def apply_to_EnumList(element, items)
      %Q[<ol>\n#{items.join("\n").chomp}\n</ol>]
    end
    
    def apply_to_DescList(element, items)
      %Q[<dl>\n#{items.join("\n").chomp}\n</dl>]
    end

    def apply_to_MethodList(element, items)
      %Q[<dl>\n#{items.join("\n").chomp}\n</dl>]
    end
    
    def apply_to_ItemListItem(element, content)
      %Q[<li>#{content.join("\n").chomp}</li>]
    end
    
    def apply_to_EnumListItem(element, content)
      %Q[<li>#{content.join("\n").chomp}</li>]
    end

    def consist_of_one_textblock?(listitem)
      listitem.children.size == 1 and listitem.children[0].is_a?(TextBlock)
    end
    private :consist_of_one_textblock?
    
    def apply_to_DescListItem(element, term, description)
      anchor = get_anchor(element.term)
      label = hyphen_escape(element.label)
      term = term.join("")
      if description.empty?
	%Q[<dt><a name="#{anchor}" id="#{anchor}">#{term}</a></dt>] +
	%Q[<!-- RDLabel: "#{label}" -->]
      else
        %Q[<dt><a name="#{anchor}" id="#{anchor}">#{term}</a></dt>] +
        %Q[<!-- RDLabel: "#{label}" -->\n] +
        %Q[<dd>\n#{description.join("\n").chomp}\n</dd>]
      end
    end

    def apply_to_MethodListItem(element, term, description)
      term = parse_method(term)  # maybe: term -> element.term
      anchor = get_anchor(element.term)
      label = hyphen_escape(element.label)
      if description.empty?
	%Q[<dt><a name="#{anchor}" id="#{anchor}"><code>#{term}] +
        %Q[</code></a></dt><!-- RDLabel: "#{label}" -->]
      else
        %Q[<dt><a name="#{anchor}" id="#{anchor}"><code>#{term}] +
	%Q[</code></a></dt><!-- RDLabel: "#{label}" -->\n] +
	%Q[<dd>\n#{description.join("\n")}</dd>]
      end
    end
  
    def apply_to_StringElement(element)
      apply_to_String(element.content)
    end
    
    def apply_to_Emphasis(element, content)
      %Q[<em>#{content.join("")}</em>]
    end
  
    def apply_to_Code(element, content)
      %Q[<code>#{content.join("")}</code>]
    end
  
    def apply_to_Var(element, content)
      %Q[<var>#{content.join("")}</var>]
    end
  
    def apply_to_Keyboard(element, content)
      %Q[<kbd>#{content.join("")}</kbd>]
    end
  
    def apply_to_Index(element, content)
      tmp = []
      element.each do |i|
	tmp.push(i) if i.is_a?(String)
      end
      key = meta_char_escape(tmp.join(""))
      if @index.has_key?(key)
	# warning?
	%Q[<!-- Index, but conflict -->#{content.join("")}<!-- Index end -->]
      else
	num = @index[key] = @index.size
	anchor = a_name("index", num)
	%Q[<a name="#{anchor}" id="#{anchor}">#{content.join("")}</a>]
      end
    end

    def apply_to_Reference_with_RDLabel(element, content)
      if element.label.filename
	apply_to_RefToOtherFile(element, content)
      else
	apply_to_RefToElement(element, content)
      end
    end

    def apply_to_Reference_with_URL(element, content)
      %Q[<a href="#{meta_char_escape(element.label.url)}">] +
	%Q[#{content.join("")}</a>]
    end

    def apply_to_RefToElement(element, content)
      content = content.join("")
      if anchor = refer(element)
	content = content.sub(/^function#/, "")
	%Q[<a href="\##{anchor}">#{content}</a>]
      else
	# warning?
	label = hyphen_escape(element.to_label)
	%Q[<!-- Reference, RDLabel "#{label}" doesn't exist -->] +
	  %Q[<em class="label-not-found">#{content}</em><!-- Reference end -->]
	#' 
      end
    end

    def apply_to_RefToOtherFile(element, content)
      content = content.join("")
      filename = element.label.filename.sub(/\.(rd|rb)(\.\w+)?$/, "." +
					    OUTPUT_SUFFIX)
      anchor = refer_external(element)
      if anchor
	%Q[<a href="#{filename}\##{anchor}">#{content}</a>]
      else
	%Q[<a href="#{filename}">#{content}</a>]
      end
    end
    
    def apply_to_Footnote(element, content)
      num = get_footnote_num(element)
      raise ArgumentError, "[BUG?] #{element} is not registered." unless num
      
      add_foottext(num, content)
      anchor = a_name("footmark", num)
      href = a_name("foottext", num)
      %Q|<a name="#{anchor}" id="#{anchor}" | +
	%Q|href="##{href}"><sup><small>| +
      %Q|*#{num}</small></sup></a>|
    end

    def get_footnote_num(fn)
      raise ArgumentError, "#{fn} must be Footnote." unless fn.is_a? Footnote
      i = @footnotes.index(fn)
      if i
	i + 1
      else
	nil
      end
    end

    def prepare_footnotes(tree)
      @footnotes = tree.find_all{|i| i.is_a? Footnote }
      @foottexts = []
    end
    private :prepare_footnotes

    def apply_to_Foottext(element, content)
      num = get_footnote_num(element)
      raise ArgumentError, "[BUG] #{element} isn't registered." unless num
      anchor = a_name("foottext", num)
      href = a_name("footmark", num)
      content = content.join("")
      %|<a name="#{anchor}" id="#{anchor}" href="##{href}">|+
	%|<sup><small>*#{num}</small></sup></a>| +
	%|<small>#{content}</small><br />|
    end

    def add_foottext(num, foottext)
      raise ArgumentError, "[BUG] footnote ##{num} isn't here." unless
	footnotes[num - 1]
      @foottexts[num - 1] = foottext
    end
    
    def apply_to_Verb(element)
      content = apply_to_String(element.content)
      %Q[#{content}]
    end

    def sp2nbsp(str)
      str.gsub(/\s/, "&nbsp;")
    end
    private :sp2nbsp
    
    def apply_to_String(element)
      meta_char_escape(element)
    end
    
    def parse_method(method)
      klass, kind, method, args = MethodParse.analize_method(method)
      
      if kind == :function
	klass = kind = nil
      else
	kind = MethodParse.kind2str(kind)
      end
      
      args.gsub!(/&?\w+;?/){ |m|
	if /&\w+;/ =~ m then m else '<var>'+m+'</var>' end }

      case method
      when "self"
	klass, kind, method, args = MethodParse.analize_method(args)
	"#{klass}#{kind}<var>self</var> #{method}#{args}"
      when "[]"
	args.strip!
	args.sub!(/^\((.*)\)$/, '\\1')
	"#{klass}#{kind}[#{args}]"
      when "[]="
	args.tr!(' ', '')
	args.sub!(/^\((.*)\)$/, '\\1')
	ary = args.split(/,/)

	case ary.length
	when 1
	  val = '<var>val</var>'
	when 2
	  args, val = *ary
	when 3
	  args, val = ary[0, 2].join(', '), ary[2]
	end

	"#{klass}#{kind}[#{args}] = #{val}"
      else
	"#{klass}#{kind}#{method}#{args}"
      end
    end
    private :parse_method

    def meta_char_escape(str)
      str.gsub(/[<>&]/) {
	METACHAR[$&]
      }
    end
    private :meta_char_escape

    def hyphen_escape(str)
      str.gsub(/--/, "&shy;&shy;")
    end
    
    def make_foottext
      return nil if foottexts.empty?
      content = []
      foottexts.each_with_index do |ft, num|
	content.push(apply_to_Foottext(footnotes[num], ft))
      end
      %|<hr />\n<p class="foottext">\n#{content.join("\n")}\n</p>|
    end
    private :make_foottext

    def a_name(prefix, num)
      "#{prefix}-#{num}"
    end
    private :a_name
  end # RD2HTMLVisitor
end # RD

$Visitor_Class = RD::RD2HTMLVisitor
$RD2_Sub_OptionParser = "rd/rd2html-opt"

=begin
== script info.
 RD to HTML translate library for rdfmt.rb
 $Id: rd2html-lib.rb,v 1.53 2003/03/08 12:45:08 tosh Exp $

=end
