require 'test/unit'

require 'rd/rd2html-lib'
require 'rd/tree'
require 'rd/element'
require 'rd/block-element'
require 'rd/list'
require 'rd/desclist'
require 'rd/methodlist'
require 'rd/inline-element'
require 'rd/rd-struct'

include RD

class TestRD2HTMLVisitor < Test::Unit::TestCase
  
  def setup
    @vis = RD2HTMLVisitor.new
    @vis.class.module_eval {
      public :xml_decl
      public :forward_links, :backward_links
      public :document_title
      public :html_content_type
      public :html_title
      public :html_open_tag
      public :link_to_css
      public :prepare_footnotes
      public :make_foottext
    }
    @ch1 = ["a"]
    @ch2 = ["a", "b"]
    @ch3 = ["a\n"]
    @ch0 = []

    @tr_fn = Tree.new_with_document_struct(DocumentStructure::RD)
    @tr_fn.root = DocumentElement.new
    fn1, fn2 = nil
    @tr_fn.root.build do
      new TextBlock do
        fn1 = new Footnote do
          new StringElement, "footnote 1"
        end
        fn2 = new Footnote do
          new StringElement, "footnote 2"
        end
      end
    end
    @fn1_fn = fn1
    @fn2_fn = fn2

    @tr2_fn = Tree.new_with_document_struct(DocumentStructure::RD)
    @tr2_fn.root = DocumentElement.new
    @tr2_fn.root.build do
      new Headline, 1
      new TextBlock do
        new StringElement, "string"
      end
    end
  end

  def test_xml_decl
    vis_with_charset = RD2HTMLVisitor.new
    vis_with_charset.charset = "CharSet"
    assert_equal(%|<?xml version="1.0" encoding="CharSet" ?>|,
                 vis_with_charset.xml_decl)
    vis_no_charset = RD2HTMLVisitor.new
    assert_equal(%|<?xml version="1.0" ?>|,
                 vis_no_charset.xml_decl)
  end

  def test_html_open_tag
    vis_with_lang = RD2HTMLVisitor.new
    vis_with_lang.lang = "Language"
    assert_equal(%|<html xmlns="http://www.w3.org/1999/xhtml" lang="Language"|+
                 %| xml:lang="Language">|, vis_with_lang.html_open_tag)

    vis_no_lang = RD2HTMLVisitor.new
    assert_equal(%|<html xmlns="http://www.w3.org/1999/xhtml">|,
                 vis_no_lang.html_open_tag)
  end

  def test_html_title
    vis_with_title = RD2HTMLVisitor.new
    vis_with_title.title = "Title"
    assert_equal("<title>Title</title>", vis_with_title.html_title)

    vis_no_title = RD2HTMLVisitor.new
    assert_equal("<title>Untitled</title>", vis_no_title.html_title)
  end

  def test_html_content_type
    vis_with_charset = RD2HTMLVisitor.new
    vis_with_charset.charset = "CharSet"
    assert_equal(%|<meta http-equiv="Content-type" | +
                 %|content="text/html; charset=CharSet" | +
                 "/>", vis_with_charset.html_content_type)
    vis_no_charset = RD2HTMLVisitor.new
    assert_equal(nil, vis_no_charset.html_content_type)
  end

  def test_link_to_css
    vis_with_css = RD2HTMLVisitor.new
    vis_with_css.css = "CSS.css"
    assert_equal(%|<link href="CSS.css" type="text/css" rel="stylesheet"| +
                 " />", vis_with_css.link_to_css)
    vis_no_css = RD2HTMLVisitor.new
    assert_equal(nil, vis_no_css.link_to_css)
  end

  def test_forward_links
    vis_rel1 = RD2HTMLVisitor.new
    vis_rel1.html_link_rel["rel1"] = "REL1"
    assert_equal('<link href="REL1" rel="rel1" />', vis_rel1.forward_links)

    vis_rel2 = vis_rel1
    vis_rel2.html_link_rel["rel2"] = "REL2"
    assert_equal('<link href="REL1" rel="rel1" />' + "\n" +
                 '<link href="REL2" rel="rel2" />', vis_rel2.forward_links)

    vis_no_rel = RD2HTMLVisitor.new
    assert_equal(nil, vis_no_rel.forward_links)
  end

  def test_backward_links
    vis_rev1 = RD2HTMLVisitor.new
    vis_rev1.html_link_rev["rev1"] = "REV1"
    assert_equal('<link href="REV1" rev="rev1" />', vis_rev1.backward_links)

    vis_rev2 = vis_rev1
    vis_rev2.html_link_rev["rev2"] = "REV2"
    assert_equal('<link href="REV1" rev="rev1" />' + "\n" +
                 '<link href="REV2" rev="rev2" />', vis_rev2.backward_links)

    vis_no_rev = RD2HTMLVisitor.new
    assert_equal(nil, vis_no_rev.backward_links)
  end


  def test_document_title
    vis_titled = RD2HTMLVisitor.new
    vis_titled.title = "Title"
    assert_equal("Title", vis_titled.document_title)
    
    vis_with_filename = RD2HTMLVisitor.new
    vis_with_filename.filename = "FileName"
    assert_equal("FileName", vis_with_filename.document_title)

    vis_untitled = RD2HTMLVisitor.new
    assert_equal("Untitled", vis_untitled.document_title)
  end
  
  def test_apply_to_Headline
    tr = Tree.new_with_document_struct(DocumentStructure::RD)
    tr.root = DocumentElement.new
    hl1, hl2 = nil
    tr.root.build do
      hl1 = new Headline, 1 do
        new StringElement, "headline 1"
      end
      hl2 = new Headline, 2 do
        new StringElement, "headline 2"
      end
    end
    @vis.prepare_labels(tr, "label:")

    assert_equal(expect_for_hl1(@ch1), @vis.apply_to_Headline(hl1, @ch1))
    assert_equal(expect_for_hl1(@ch2), @vis.apply_to_Headline(hl1, @ch2))
    assert_equal(expect_for_hl1(@ch0), @vis.apply_to_Headline(hl1, @ch0))
    assert_equal(expect_for_hl2(@ch1), @vis.apply_to_Headline(hl2, @ch1))
    assert_equal(expect_for_hl2(@ch2), @vis.apply_to_Headline(hl2, @ch2))
    assert_equal(expect_for_hl2(@ch0), @vis.apply_to_Headline(hl2, @ch0))
  end

  def expect_for_hl1(children)
    %|<h1><a name="label:0" id="label:0">#{children.join('')}</a></h1><!-- RDLabel: "headline 1" -->|
  end

  def expect_for_hl2(children)
    %|<h2><a name="label:1" id="label:1">#{children.join('')}</a></h2><!-- RDLabel: "headline 2" -->|
  end

  def test_apply_to_TextBlock
    tb = TextBlock.new
    assert_equal("<p>a</p>", @vis.apply_to_TextBlock(tb, @ch1))
    assert_equal("<p>ab</p>", @vis.apply_to_TextBlock(tb, @ch2))
    assert_equal("<p>a</p>", @vis.apply_to_TextBlock(tb, @ch3))
    assert_equal("<p></p>", @vis.apply_to_TextBlock(tb, @ch0))

    tb_in_list = TextBlock.new
    li = ItemListItem.new
    li.add_child_under_document_struct(tb_in_list, DocumentStructure::RD)
    assert_equal("a", @vis.apply_to_TextBlock(tb_in_list, @ch1))
    assert_equal("ab", @vis.apply_to_TextBlock(tb_in_list, @ch2))
    assert_equal("a", @vis.apply_to_TextBlock(tb_in_list, @ch3))
    assert_equal("", @vis.apply_to_TextBlock(tb_in_list, @ch0))

    tb1_in_list2 = TextBlock.new
    tb2_in_list2 = TextBlock.new    
    li2 = ItemListItem.new
    li2.add_children_under_document_struct([tb1_in_list2, tb2_in_list2],
                                           DocumentStructure::RD)
    assert_equal("<p>a</p>", @vis.apply_to_TextBlock(tb1_in_list2, @ch1))
    assert_equal("<p>ab</p>", @vis.apply_to_TextBlock(tb1_in_list2, @ch2))
    assert_equal("<p>a</p>", @vis.apply_to_TextBlock(tb1_in_list2, @ch3))
    assert_equal("<p></p>", @vis.apply_to_TextBlock(tb1_in_list2, @ch0))
  end

  def test_apply_to_Verbatim
    verb1 = Verbatim.new "aaa"
    assert_equal("<pre>aaa</pre>", @vis.apply_to_Verbatim(verb1))
    verb2 = Verbatim.new "aaa\n"
    assert_equal("<pre>aaa</pre>", @vis.apply_to_Verbatim(verb2))
    verb3 = Verbatim.new "aaa\nbbb"
    assert_equal("<pre>aaa\nbbb</pre>", @vis.apply_to_Verbatim(verb3))
    verb_empty = Verbatim.new ""
    assert_equal("<pre></pre>", @vis.apply_to_Verbatim(verb_empty))
    verb_amp = Verbatim.new "&"
    assert_equal("<pre>&amp;</pre>", @vis.apply_to_Verbatim(verb_amp))
    verb_lt = Verbatim.new "<"
    assert_equal("<pre>&lt;</pre>", @vis.apply_to_Verbatim(verb_lt))
    verb_gt = Verbatim.new ">"
    assert_equal("<pre>&gt;</pre>", @vis.apply_to_Verbatim(verb_gt))

    verb3 = Verbatim.new ["aaa\n", "bbb"]
    assert_equal("<pre>aaa\nbbb</pre>", @vis.apply_to_Verbatim(verb3))
  end

  def test_apply_to_ItemList
    list = ItemList.new
    assert_equal("<ul>\na\n</ul>", @vis.apply_to_ItemList(list, @ch1))
    assert_equal("<ul>\na\nb\n</ul>", @vis.apply_to_ItemList(list, @ch2))
    assert_equal("<ul>\na\n</ul>", @vis.apply_to_ItemList(list, @ch3))
    assert_equal("<ul>\n\n</ul>", @vis.apply_to_ItemList(list, @ch0))
  end

  def test_apply_to_EnumList
    list = EnumList.new
    assert_equal("<ol>\na\n</ol>", @vis.apply_to_EnumList(list, @ch1))
    assert_equal("<ol>\na\nb\n</ol>", @vis.apply_to_EnumList(list, @ch2))
    assert_equal("<ol>\na\n</ol>", @vis.apply_to_EnumList(list, @ch3))
    assert_equal("<ol>\n\n</ol>", @vis.apply_to_EnumList(list, @ch0))
  end

  def test_apply_to_DescList
    list = DescList.new
    assert_equal("<dl>\na\n</dl>", @vis.apply_to_DescList(list, @ch1))
    assert_equal("<dl>\na\nb\n</dl>", @vis.apply_to_DescList(list, @ch2))
    assert_equal("<dl>\na\n</dl>", @vis.apply_to_DescList(list, @ch3))
    assert_equal("<dl>\n\n</dl>", @vis.apply_to_DescList(list, @ch0))
  end

  def test_apply_to_MethodList
    list = MethodList.new
    assert_equal("<dl>\na\n</dl>", @vis.apply_to_MethodList(list, @ch1))
    assert_equal("<dl>\na\nb\n</dl>", @vis.apply_to_MethodList(list, @ch2))
    assert_equal("<dl>\na\n</dl>", @vis.apply_to_MethodList(list, @ch3))
    assert_equal("<dl>\n\n</dl>", @vis.apply_to_MethodList(list, @ch0))
  end

  def test_apply_to_ItemListItem
    item = ItemListItem.new
    assert_equal("<li>a</li>", @vis.apply_to_ItemListItem(item, @ch1))
    assert_equal("<li>a\nb</li>", @vis.apply_to_ItemListItem(item, @ch2))
    assert_equal("<li>a</li>", @vis.apply_to_ItemListItem(item, @ch3))
    assert_equal("<li></li>", @vis.apply_to_ItemListItem(item, @ch0))
  end

  def test_apply_to_EnumListItem
    item = EnumListItem.new
    assert_equal("<li>a</li>", @vis.apply_to_EnumListItem(item, @ch1))
    assert_equal("<li>a\nb</li>", @vis.apply_to_EnumListItem(item, @ch2))
    assert_equal("<li>a</li>", @vis.apply_to_EnumListItem(item, @ch3))
    assert_equal("<li></li>", @vis.apply_to_EnumListItem(item, @ch0))
  end

  def test_apply_to_DescListItem
    tr = Tree.new_with_document_struct(DocumentStructure::RD)
    tr.root = DocumentElement.new
    di1, di2 = nil
    tr.root.build do
      new DescList do
        di1 = new DescListItem do
          make_term do
            new StringElement, "desclist 1"
          end
        end
        di2 = new DescListItem do
          make_term do
            new StringElement, "desclist 2"
          end
        end
      end
    end

    @vis.prepare_labels(tr, "label:")

    assert_equal(expect_for_di1_with_child("term1", @ch1),
                 @vis.apply_to_DescListItem(di1, ["term1"], @ch1))
    assert_equal(expect_for_di1_with_child("term1term2", @ch1),
                 @vis.apply_to_DescListItem(di1, ["term1", "term2"], @ch1))
    assert_equal(expect_for_di1_with_child("term1", @ch2),
                 @vis.apply_to_DescListItem(di1, ["term1"], @ch2))
    assert_equal(expect_for_di1_with_child("term1", @ch3),
                 @vis.apply_to_DescListItem(di1, ["term1"], @ch3))
    assert_equal(expect_for_di1_no_child("term1"),
                 @vis.apply_to_DescListItem(di1, ["term1"], @ch0))
    assert_equal(expect_for_di1_no_child("term1term2"),
                 @vis.apply_to_DescListItem(di1, ["term1", "term2"], @ch0))
    assert_equal(expect_for_di2_with_child("term1", @ch1),
                 @vis.apply_to_DescListItem(di2, ["term1"], @ch1))
    assert_equal(expect_for_di2_no_child("term1"),
                 @vis.apply_to_DescListItem(di2, ["term1"], @ch0))

  end

  def expect_for_di1_with_child(term, children)
    %|<dt><a name="label:0" id="label:0">#{term}</a></dt><!-- RDLabel: "desclist 1" -->\n| +
      %|<dd>\n#{children.join("\n").chomp}\n</dd>|
  end

  def expect_for_di1_no_child(term)
    %|<dt><a name="label:0" id="label:0">#{term}</a></dt><!-- RDLabel: "desclist 1" -->|
  end

  def expect_for_di2_with_child(term, children)
    %|<dt><a name="label:1" id="label:1">#{term}</a></dt><!-- RDLabel: "desclist 2" -->\n| +
      %|<dd>\n#{children.join("\n").chomp}\n</dd>|
  end

  def expect_for_di2_no_child(term)
    %|<dt><a name="label:1" id="label:1">#{term}</a></dt><!-- RDLabel: "desclist 2" -->|
  end

  # MethodListItem ...

  def check_apply_to_NonterminalInline(type, tag)
    element = type.new
    name = type.to_s.sub(/RD::/, "")

    assert_equal("<#{tag}>a</#{tag}>",
                 @vis.send("apply_to_#{name}", element, @ch1))
    assert_equal("<#{tag}>ab</#{tag}>",
                 @vis.send("apply_to_#{name}", element, @ch2))
    assert_equal("<#{tag}>a\n</#{tag}>",
                 @vis.send("apply_to_#{name}", element, @ch3))
    assert_equal("<#{tag}></#{tag}>",
                 @vis.send("apply_to_#{name}", element, @ch0))
  end

  def test_apply_to_Emphasis
    check_apply_to_NonterminalInline(Emphasis, "em")
  end

  def test_apply_to_Code
    check_apply_to_NonterminalInline(Code, "code")
  end

  def test_apply_to_Var
    check_apply_to_NonterminalInline(Var, "var")
  end

  def test_apply_to_Keyboard
    check_apply_to_NonterminalInline(Keyboard, "kbd")
  end

  def test_apply_to_StringElement
    se1 = StringElement.new "a"
    assert_equal("a", @vis.apply_to_StringElement(se1))
    se2 = StringElement.new "a\nb"
    assert_equal("a\nb", @vis.apply_to_StringElement(se2))
    se_empty = StringElement.new ""
    assert_equal("", @vis.apply_to_StringElement(se_empty))
    se_ws = StringElement.new " "
    assert_equal(" ", @vis.apply_to_StringElement(se_ws))
    se_lt = StringElement.new "<"
    assert_equal("&lt;", @vis.apply_to_StringElement(se_lt))
    se_gt = StringElement.new ">"
    assert_equal("&gt;", @vis.apply_to_StringElement(se_gt))
    se_amp = StringElement.new "&"
    assert_equal("&amp;", @vis.apply_to_StringElement(se_amp))
  end

  def test_apply_to_Verb
    verb1 = Verb.new "a"
    assert_equal("a", @vis.apply_to_Verb(verb1))
    verb2 = Verb.new "a\nb"
    assert_equal("a\nb", @vis.apply_to_Verb(verb2))
    verb_empty = Verb.new ""
    assert_equal("", @vis.apply_to_Verb(verb_empty))
    verb_ws = Verb.new " "
    assert_equal(" ", @vis.apply_to_Verb(verb_ws))
    verb_lt = Verb.new "<"
    assert_equal("&lt;", @vis.apply_to_Verb(verb_lt))
    verb_gt = Verb.new ">"
    assert_equal("&gt;", @vis.apply_to_Verb(verb_gt))
    verb_amp = Verb.new "&"
    assert_equal("&amp;", @vis.apply_to_Verb(verb_amp))
  end

  def test_apply_to_Footnote
    @vis.prepare_footnotes(@tr_fn)
    assert_equal([], @vis.foottexts)

    assert_equal(expect_for_footnote(1),
                 @vis.apply_to_Footnote(@fn1_fn, ["footnote 1"]))
    assert_equal([["footnote 1"]], @vis.foottexts)

    assert_equal(expect_for_footnote(2),
                 @vis.apply_to_Footnote(@fn2_fn, ["footnote", " 2"]))
    assert_equal([["footnote 1"], ["footnote", " 2"]], @vis.foottexts)

    @vis.prepare_footnotes(@tr2_fn)
    assert_raises(ArgumentError) do
      @vis.apply_to_Footnote(@fn2_fn, [])
    end
  end

  def expect_for_footnote(num)
    %Q|<a name="footmark-#{num}" id="footmark-#{num}" href="#foottext-#{num}">|+
      %Q|<sup><small>*#{num}</small></sup></a>|
  end

  def test_get_footnote_num
    @vis.prepare_footnotes(@tr_fn)
    assert_equal(1, @vis.get_footnote_num(@fn1_fn))
    assert_equal(2, @vis.get_footnote_num(@fn2_fn))
    assert_equal(nil, @vis.get_footnote_num(Footnote.new))
    @vis.prepare_footnotes(@tr2_fn)
    assert_equal(nil, @vis.get_footnote_num(@fn1_fn))

    assert_raises(ArgumentError) do
      @vis.get_footnote_num(Headline.new(1))
    end
  end

  def test_prepare_footnotes
    @vis.prepare_footnotes(@tr_fn)
    assert_equal([@fn1_fn, @fn2_fn], @vis.footnotes)

    @vis.prepare_footnotes(@tr2_fn)
    assert_equal([], @vis.footnotes)
  end

  def test_add_foottext
    @vis.prepare_footnotes(@tr_fn)
    assert_equal([], @vis.foottexts)    
    @vis.add_foottext(@vis.get_footnote_num(@fn1_fn), ["footnote 1"])
    assert_equal([["footnote 1"]], @vis.foottexts)
    @vis.add_foottext(@vis.get_footnote_num(@fn2_fn), ["footnote", "2"])
    assert_equal([["footnote 1"], ["footnote", "2"]], @vis.foottexts)
    assert_raises(ArgumentError) do
      @vis.add_foottext(3, "footnote 3")
    end
  end

  def test_apply_to_Foottext
    @vis.prepare_footnotes(@tr_fn)
    
    exp1 = %|<a name="foottext-1" id="foottext-1" href="#footmark-1">| +
      %|<sup><small>*1</small></sup></a>| +
      %|<small>footnote 1</small><br />|
    assert_equal(exp1, @vis.apply_to_Foottext(@fn1_fn, ["footnote 1"]))
    exp2 = %|<a name="foottext-2" id="foottext-2" href="#footmark-2">| +
      %|<sup><small>*2</small></sup></a>| +
      %|<small>footnote 2</small><br />|
    assert_equal(exp2, @vis.apply_to_Foottext(@fn2_fn, ["footnote", " 2"]))

    @vis.prepare_footnotes(@tr2_fn)
    assert_raises(ArgumentError) do
      @vis.apply_to_Foottext(@fn1_fn, ["footnote 1"])
    end
  end

  def test_make_foottext
    @vis.prepare_footnotes(@tr_fn)
    ft1 = ["footnote 1"]
    ft2 = ["footnote", " 2"]
    @vis.add_foottext(@vis.get_footnote_num(@fn1_fn), ft1)
    @vis.add_foottext(@vis.get_footnote_num(@fn2_fn), ft2)
    exp1 = @vis.apply_to_Foottext(@fn1_fn, ft1)
    exp2 = @vis.apply_to_Foottext(@fn2_fn, ft2)
    assert_equal(%|<hr />\n<p class="foottext">\n#{exp1}\n#{exp2}\n</p>|, @vis.make_foottext)

    @vis.prepare_footnotes(@tr2_fn)
    assert_equal(nil, @vis.make_foottext)
  end

  def test_hyphen_escape
    assert_equal("&shy;&shy;", @vis.hyphen_escape("--"))
    assert_equal("-", @vis.hyphen_escape("-"))
    assert_equal("&shy;&shy;-", @vis.hyphen_escape("---"))
    assert_equal("- -", @vis.hyphen_escape("- -"))
    assert_equal("aa&shy;&shy;bb", @vis.hyphen_escape("aa--bb"))
    assert_equal("", @vis.hyphen_escape(""))
  end
end
