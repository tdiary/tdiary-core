require 'test/unit'

require 'rd/visitor'
require 'rd/block-element'
require 'rd/list'
require 'rd/desclist'
require 'rd/methodlist'
require 'rd/inline-element'
require 'rd/tree'
require 'rd/rd-struct'
require 'dummy'

include RD

DummyStruct.define_relationship(NonterminalElement, DummyElement)

class TestVisitor < Test::Unit::TestCase
  def setup
    @vis = DummyVisitor.new
  end
  
  def test_visit_children
    el = TextBlock.new
    add_2_children(el)
    assert_equal(["dummy", "dummy"], @vis.visit_children(el))

    empty = TextBlock.new
    assert_equal([], @vis.visit_children(empty))
  end

  def test_visit_DocumentElement
    el = DocumentElement.new
    add_2_children(el)
    assert_equal(["apply_to_DocumentElement", [el, ["dummy", "dummy"]]],
                 @vis.visit_DocumentElement(el))
  end

  def test_visit_Headline
    el = Headline.new(1)
    add_2_children(el)
    assert_equal(["apply_to_Headline", [el, ["dummy", "dummy"]]],
                 @vis.visit_Headline(el))
  end

  def test_visit_Include
    el = Include.new "include"
    assert_equal(["apply_to_Include", [el]],
                 @vis.visit_Include(el))
  end

  def test_visit_TextBlock
    el = TextBlock.new
    add_2_children(el)
    assert_equal(["apply_to_TextBlock", [el, ["dummy", "dummy"]]],
                 @vis.visit_TextBlock(el))
  end

  def test_visit_Verbatim
    el = Verbatim.new "Verbatim"
    assert_equal(["apply_to_Verbatim", [el]],
                 @vis.visit_Verbatim(el))
  end

  def test_visit_ItemList
    el = ItemList.new
    add_2_children(el)
    assert_equal(["apply_to_ItemList", [el, ["dummy", "dummy"]]],
                 @vis.visit_ItemList(el))
  end

  def test_visit_EnumList
    el = EnumList.new
    add_2_children(el)
    assert_equal(["apply_to_EnumList", [el, ["dummy", "dummy"]]],
                 @vis.visit_EnumList(el))
  end

  def test_visit_DescList
    el = DescList.new
    add_2_children(el)
    assert_equal(["apply_to_DescList", [el, ["dummy", "dummy"]]],
                 @vis.visit_DescList(el))
  end

  def test_visit_MethodList
    el = MethodList.new
    add_2_children(el)
    assert_equal(["apply_to_MethodList", [el, ["dummy", "dummy"]]],
                 @vis.visit_MethodList(el))
  end

  def test_visit_ItemListItem
    el = ItemListItem.new
    add_2_children(el)
    assert_equal(["apply_to_ItemListItem", [el, ["dummy", "dummy"]]],
                 @vis.visit_ItemListItem(el))
  end

  def test_visit_EnumListItem
    el = EnumListItem.new
    add_2_children(el)
    assert_equal(["apply_to_EnumListItem", [el, ["dummy", "dummy"]]],
                 @vis.visit_EnumListItem(el))
  end

  def test_visit_DescListItem
    el = DescListItem.new
    el.set_term_under_document_struct(DummyElement.new, DummyStruct)
    add_2_children(el)
    assert_equal(["apply_to_DescListItem", [el, "dummy", ["dummy", "dummy"]]],
                 @vis.visit_DescListItem(el))

    empty = DescListItem.new
    empty.set_term_under_document_struct(DummyElement.new, DummyStruct)
    assert_equal(["apply_to_DescListItem", [empty, "dummy", []]],
                 @vis.visit_DescListItem(empty))
  end

  def test_visit_DescListItemTerm
    el = DescListItem::Term.new
    add_2_children(el)
    assert_equal(["apply_to_DescListItemTerm", [el, ["dummy", "dummy"]]],
                 @vis.visit_DescListItemTerm(el))
  end

  def test_visit_MethodListItem
    el = MethodListItem.new
    el.set_term_under_document_struct(DummyElement.new, DummyStruct)
    add_2_children(el)
    assert_equal(["apply_to_MethodListItem", [el, "dummy", ["dummy", "dummy"]]],
                 @vis.visit_MethodListItem(el))

    empty = MethodListItem.new
    empty.set_term_under_document_struct(DummyElement.new, DummyStruct)
    assert_equal(["apply_to_MethodListItem", [empty, "dummy", []]],
                 @vis.visit_MethodListItem(empty))
  end

  def test_visit_MethodListItemTerm
    el = MethodListItem::Term.new
    assert_equal(["apply_to_MethodListItemTerm", [el]],
                 @vis.visit_MethodListItemTerm(el))
  end

  def test_visit_StringElement
    el = StringElement.new "string"
    assert_equal(["apply_to_StringElement", [el]], @vis.visit_StringElement(el))
  end

  def test_visit_Verb
    el = Verb.new "string"
    assert_equal(["apply_to_Verb", [el]], @vis.visit_Verb(el))
  end

  def test_visit_Emphasis
    el = Emphasis.new
    add_2_children(el)
    assert_equal(["apply_to_Emphasis", [el, ["dummy", "dummy"]]],
                 @vis.visit_Emphasis(el))
  end

  def test_visit_Code
    el = Code.new
    add_2_children(el)
    assert_equal(["apply_to_Code", [el, ["dummy", "dummy"]]],
                 @vis.visit_Code(el))
  end

  def test_visit_Var
    el = Var.new
    add_2_children(el)
    assert_equal(["apply_to_Var", [el, ["dummy", "dummy"]]],
                 @vis.visit_Var(el))
  end

  def test_visit_Keyboard
    el = Keyboard.new
    add_2_children(el)
    assert_equal(["apply_to_Keyboard", [el, ["dummy", "dummy"]]],
                 @vis.visit_Keyboard(el))
  end

  def test_visit_Index
    el = Index.new
    add_2_children(el)
    assert_equal(["apply_to_Index", [el, ["dummy", "dummy"]]],
                 @vis.visit_Index(el))
  end

  def test_visit_Footnote
    el = Footnote.new
    add_2_children(el)
    assert_equal(["apply_to_Footnote", [el, ["dummy", "dummy"]]],
                 @vis.visit_Footnote(el))
  end

  def test_visit_Reference
    el = Reference.new(Reference::RDLabel.new("label"))
    add_2_children(el)
    assert_equal(["apply_to_Reference_with_RDLabel", [el, ["dummy", "dummy"]]],
                 @vis.visit_Reference(el))

    empty = Reference.new(Reference::RDLabel.new("label"))
    assert_equal(["apply_to_Reference_with_RDLabel", [empty, []]],
                 @vis.visit_Reference(empty))

    url_reference = Reference.new(Reference::URL.new("url"))
    add_2_children(url_reference)
    assert_equal(["apply_to_Reference_with_URL",
                   [url_reference, ["dummy", "dummy"]]],
                 @vis.visit_Reference(url_reference))

    # OldStyleDummyVisitor#apply_to_Reference_with_RDLabel is not implemented.
    # So, #apply_to_reference is called instead of it.
    old_visitor = OldStyleDummyVisitor.new
    assert_equal(["apply_to_Reference", [el, ["dummy", "dummy"]]],
                 old_visitor.visit_Reference(el))
  end

  def add_2_children(el)
    el.add_children_under_document_struct([DummyElement.new, DummyElement.new],
                                          DummyStruct)
  end
end

class OldStyleDummyVisitor < Visitor
  def apply_to_Reference(*args)
    ["apply_to_Reference", args]
  end
end
