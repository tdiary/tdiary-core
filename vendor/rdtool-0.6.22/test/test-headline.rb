require 'test/unit'

require 'rd/block-element'
require 'rd/inline-element'
require 'rd/rd-struct'
require 'rd/document-struct'

include RD

class TestHeadline < Test::Unit::TestCase
  
  def test_s_new
    a = Headline.new(1)
    assert_equal(1, a.level)
  end

  def test_add_child_under_document_struct
    check_add_child(StringElement.new(""))
    check_add_child(Emphasis.new)
    check_add_child(Code.new)
    check_add_child(Var.new)
    check_add_child(Keyboard.new)
    check_add_child(Index.new)
    check_add_child(Verb.new(""))
    check_add_child_fail(TextBlock.new)
    check_add_child_fail(Verbatim.new)
    check_add_child_fail(ItemList.new)
    check_add_child_fail(ItemListItem.new)
    check_add_child_fail(Reference.new(Reference::RDLabel.new("")))
    check_add_child_fail(Footnote.new)
  end

  def check_add_child(child)
    parent = Headline.new(1)
    parent.add_child_under_document_struct(child, DocumentStructure::RD)
    assert_equal([child], parent.children)
    assert_equal(parent, child.parent)
  end

  def check_add_child_fail(child)
    parent = Headline.new(1)
    assert_raises(ArgumentError) do
      parent.add_child_under_document_struct(child, DocumentStructure::RD)
    end
  end

  def test_to_label
    a = Headline.new(1)
    c1 = StringElement.new "label"
    a.add_child_under_document_struct(c1, DocumentStructure::RD)
    assert_equal("label", a.to_label)

    b = Headline.new(1)
    c2 = Emphasis.new
    c21 = StringElement.new "LABEL"
    c2.add_child_under_document_struct(c21, DocumentStructure::RD)
    b.add_children_under_document_struct([c1, c2], DocumentStructure::RD)
    assert_equal("labelLABEL", b.to_label)

    b = Headline.new(1)
    c2 = Code.new
    c21 = StringElement.new " LABEL "
    c2.add_child_under_document_struct(c21, DocumentStructure::RD)
    b.add_children_under_document_struct([c1, c2], DocumentStructure::RD)
    assert_equal("labelLABEL", b.to_label)
  end

  def test_s_mark_to_level
    assert_equal(1, Headline.mark_to_level("="))
    assert_equal(2, Headline.mark_to_level("=="))
    assert_equal(3, Headline.mark_to_level("==="))
    assert_equal(4, Headline.mark_to_level("===="))
    assert_equal(5, Headline.mark_to_level("+"))
    assert_equal(6, Headline.mark_to_level("++"))

    assert_raises(ArgumentError) do
      Headline.mark_to_level("=====")
    end
  end
end
