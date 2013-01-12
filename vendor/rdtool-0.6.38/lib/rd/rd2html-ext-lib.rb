=begin
= rd2html-ext-lib.rb
$Id: rd2html-ext-lib.rb,v 1.5 2003/10/30 12:12:33 rubikitch Exp rubikitch $
Copyright(c) 2003 Rubikitch
Licence: Ruby's License or GPL-2+
=end

require "rd/rd2html-lib"

module RD
  class RD2HTMLExtVisitor < RD2HTMLVisitor
    # must-have constants
    OUTPUT_SUFFIX = "html"
    INCLUDE_SUFFIX = ["html"]

    METACHAR = { "<" => "&lt;", ">" => "&gt;", "&" => "&amp;" }

    attr_accessor :opt_headline_title, :opt_ref_extension, :opt_headline_secno, :opt_enable_br, :opt_native_inline, :opt_head_element
    attr(:head, true)

    def initialize
      @enum_count = [0, 0, 0, 0, 0, 0, 0]
      @levelold = 0
      @enum_start_level = 2
      @image_size = {}
      begin
        require 'image_size'
        @use_image_size = true
      rescue LoadError
        @use_image_size = false
      end

      super
    end

    def visit(tree)
      install_headline_title if opt_headline_title
      install_headline_secno if opt_headline_secno
      install_ref_extension if opt_ref_extension
      install_enable_br if opt_enable_br
      install_native_inline if opt_native_inline
      install_head_element if opt_head_element
      title_init if opt_headline_title || opt_headline_secno
      super
    end

    def install_headline_title
      extend HeadLineTitle
    end

    def install_native_inline
      extend NativeInline
    end

    def install_enable_br
      extend EnableBr
    end

    def install_headline_secno
      extend HeadLineTitle
      extend HeadlineSecno
    end

    def install_ref_extension
      extend RefExtension
      @ref_extension = []
      (methods + private_methods).sort.each do |m|
        if /^ref_ext/ =~ m
          @ref_extension.push(m.intern)
        end
      end
      @ref_extension.push(:default_ref_ext)
    end

    def install_head_element
      extend HeadElement
    end

    ################ <H1> to <Title>
    module HeadLineTitle
      def title_init
        @headline_called = false
      end

      def make_title(title)
        unless @headline_called || @title then
          @title = title.join.strip
          @headline_called = true
        end
      end

      def apply_to_Headline(element, title)
        make_title(title)
        super
      end
    end

    ################ index inline => native inline
    module NativeInline
      Delimiter = "\ca\ca"
      def html_body(contents)
        html = super
        a = html.split(Delimiter)
        a.each_with_index do |s, i|
          if i % 2 == 1
            meta_char_unescape!(s)
          end
        end
        a.join
      end
      private :html_body

      def apply_to_Index(element, content)
        %Q[#{Delimiter}#{content}#{Delimiter}]
      end

      def meta_char_unescape!(str)
        str.gsub!(/(&lt;|&gt;|&amp;)/) {
          METACHAR.index($&)
        }
      end
      private :meta_char_unescape!

    end

    ################ Enable <br>
    module EnableBr
      def apply_to_TextBlock(element, content)
        if (element.parent.is_a?(ItemListItem) or
            element.parent.is_a?(EnumListItem)) and
            consist_of_one_textblock?(element.parent)
          content.join.chomp
        else
          content = content.delete_if{|x| x == "\n"}.join("").gsub(/\n/, "<br />\n")
          %Q[<p>#{content.chomp}</p>]
        end
      end
    end

    ################ Headline Enumeration
    module HeadlineSecno
      def make_Headline_secno(element)
        level = element.level
        (@levelold+1).upto(@enum_count.length-1){|i| @enum_count[i]=0}
        @enum_count[level] += 1
        prefix = ""
        @enum_start_level.upto(level) do |l|
          prefix << @enum_count[l].to_s
          prefix << "." unless l == level
        end
        @levelold = level
        if prefix == '' then "Title:" else prefix end
      end
      private :make_Headline_secno

      def apply_to_Headline(element, title)
        anchor = refer(element)
        make_title(title)
        secno = make_Headline_secno element
        %Q[<h#{element.level}><a name="#{secno}" href="##{secno}">#{secno}</a> ] +
        %Q[<a name="#{anchor}">#{title}</a>] +
        %Q[</h#{element.level}><!-- RDLabel: "#{element.label}" -->\n]
      end
    end

    ################ TextBlock Label
    ################ Reference Extension from rd2rwiki-lib.rb

    module RefExtension
      def apply_to_RefToElement(element, content)
        content = content.join("")
        apply_ref_extension(element, element_label(element), content)
      end
      private

      def apply_ref_extension(element, label, content)
        @ref_extension.each do |entry|
          result = __send__(entry, element, label, content)
          return result if result
        end
      end

      def element_label(element)
        case element
        when RDElement
          element.to_label
        else
          element
        end
      end

      def default_ref_ext(element, label, content)
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

      def ref_ext_RubyML(element, label, content)
        return nil unless /^(ruby-(?:talk|list|dev|math)):(.+)$/ =~ label
        ml = $1
        article = $2.sub(/^0+/, '')
        content = "[#{label}]" if label == content

        %Q[<a href="http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/#{ ml }/#{ article }">#{ content }</a>]
      end

      def ref_ext_RAA(element, label, content)
        return nil unless /^RAA:(.+)$/ =~ label
        name = CGI.escape($1)
        content = "[#{label}]" if label == content
        %Q[<a href="http://raa.ruby-lang.org/list.rhtml?name=#{ name }">#{ content }</a>]
      end

      def ref_ext_IMG(element, label, content)
        return nil unless /^IMG:(.+)$/i =~ label
        file = $1
        label.to_s == content.to_s and content = file
        if @use_image_size
          begin
            unless @image_size[ file ]
              open( file ) do |img|
                is = ImageSize::new( img )
                @image_size[ file ] = [ is.get_height, is.get_width ]
              end
            end

            height, width = @image_size[ file ]
            %Q[<img src="#{$1}" alt="#{content}" height="#{height}" width="#{width}" />]
          rescue
            %Q[<img src="#{$1}" alt="#{content}">]
          end
        else
          %Q[<img src="#{$1}" alt="#{content}" />]
        end
      end
    end # RefExtension

    ################
    module HeadElement
      def html_head
        ret = %|<head>\n|
          ret << html_title + "\n"
          ret << html_content_type + "\n" if html_content_type
        ret << link_to_css + "\n" if link_to_css
        ret << forward_links + "\n" if forward_links
        ret << backward_links + "\n" if backward_links
        if self.head
          ret << self.head + "\n"
        else
          ret << %Q[<!-- head-element:nil -->\n]
        end
        ret << %Q[</head>]
      end
    end
  end # RD2HTMLExtVisitor
end # RD

$Visitor_Class = RD::RD2HTMLExtVisitor
$RD2_Sub_OptionParser = "rd/rd2html-ext-opt"
