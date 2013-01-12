require 'test/unit'

require 'rd/tree'
require 'rd/element'
require 'rd/loose-struct'
require 'rd/rd-struct'

include RD

class TestElement < Test::Unit::TestCase
  
  def test_add_child_under_document_struct
    check_add_child(TextBlock.new, StringElement.new(""))
    check_add_child(Headline.new(1), Emphasis.new)
    check_add_child(ItemList.new, ItemListItem.new)
    check_add_child(ItemListItem.new, TextBlock.new)
    check_add_child(Emphasis.new, Code.new)

    assert_raises(ArgumentError) do
      Headline.new.add_child_under_document_struct(Reference.
                                                 new(Reference::RDLabel.new),
                                                 DocumentStructure::RD)
      ItemListItem.new.add_child_under_document_struct(Headline.new,
                                                 DocumentStructure::RD)
    end
  end

  def check_add_child(p, c)
    assert(p.add_child_under_document_struct(c, DocumentStructure::RD))
  end

  def test_add_children_under_document_struct
    p = TextBlock.new
    c1 = Code.new
    c2 = Var.new
    c3 = Reference.new(Reference::RDLabel.new(""))
    p.add_children_under_document_struct([c1, c2, c3], DocumentStructure::RD)
    assert_equal([c1, c2, c3], p.children)
    [c1, c2, c3].each do |i|
      assert_equal(p, i.parent)
    end
  end

  def test_add_child_under_document_struct2
    p = TextBlock.new
    assert_equal([], p.children)

    c1 = Emphasis.new
    p.add_child_under_document_struct(c1, DocumentStructure::RD)
    assert_equal([c1], p.children)
    assert_equal(p, c1.parent)

    c2 = StringElement.new("")
    p.add_child_under_document_struct(c2, DocumentStructure::RD)
    assert_equal([c1, c2], p.children)
    assert_equal(p, c2.parent)

    p = DocumentElement.new
    c1 = Headline.new(1)
    p.add_child_under_document_struct(c1, DocumentStructure::RD)
    assert_equal([c1], p.children)
    assert_equal(p, c1.parent)

    c2 = ItemList.new
    p.add_child_under_document_struct(c2, DocumentStructure::RD)
    assert_equal([c1, c2], p.children)
    assert_equal(p, c2.parent)
  end

  def test_add_children_without_document_struct
    p = TextBlock.new
    c1 = StringElement.new "string"
    c2 = Emphasis.new
    c3 = Headline.new(1)

    assert_equal([], p.children)
    p.add_children_without_document_struct([c1])
    assert_equal([c1], p.children)
    assert_equal(p, c1.parent)
    p.add_children_without_document_struct([c1, c2])
    assert_equal([c1, c1, c2], p.children)
    assert_equal(p, c2.parent)
    p.add_children_without_document_struct([c3])
    assert_equal([c1, c1, c2, c3], p.children)
    assert_equal(p, c2.parent)
  end

  def test_push_to_children
    parent = TextBlock.new
    child1 = StringElement.new "string"
    parent.push_to_children(child1)
    assert_equal([child1], parent.children)
    assert_equal(parent, child1.parent)
  end

  def test_children
    assert_equal([], DocumentElement.new.children)
    assert_equal([], Headline.new(1).children)
    assert_equal([], TextBlock.new.children)
    assert_equal([], List.new.children)
    assert_equal([], ListItem.new.children)
    assert_equal([], DescListItem::Term.new.children)
    assert_equal([], NonterminalInline.new.children)
  end

  def test_build
    testcase = self
    tr = Tree.new_with_document_struct(DocumentStructure::RD)
    de = DocumentElement.new
    tr.root = de
    tb = TextBlock.new
    de.add_child(tb)
    res = tb.build do
      testcase.assert_equal(tb, self)
    end
    assert_equal(tb, res)
  end

  def test_build_under_document_struct
    testcase = self
    tb = TextBlock.new
    assert_nothing_raised do 
      tb.build(DocumentStructure::LOOSE) do
        testcase.assert_equal(DocumentStructure::LOOSE,
                              tb.temporary_document_structure)
        new Headline, 1
      end
    end
    assert_equal(nil, tb.temporary_document_structure)

    begin
      tb.build(DocumentStructure::LOOSE) do
        raise RuntimeError
      end
    rescue
      assert_equal(nil, tb.temporary_document_structure)
    end
  end

  def test_make_child
    tr = Tree.new_with_document_struct(DocumentStructure::RD)
    de = DocumentElement.new
    tb = TextBlock.new
    tr.root = de
    de.add_child(tb)
    
    tb.make_child(StringElement, "string")
    assert_equal("<RD::TextBlock>\n  <RD::StringElement>", tb.inspect)

    assert_raises(ArgumentError) do
      tb.make_child(TextBlock)
    end

    tr2 = Tree.new_with_document_struct(DocumentStructure::RD)
    de2 = DocumentElement.new
    tr2.root = de2

    de2.build do
      new TextBlock do
        new StringElement, "string"
        new Emphasis do
          new StringElement, "emphais"
        end
      end
    end
    assert_equal("<RD::DocumentElement>\n  <RD::TextBlock>\n" +
                 "    <RD::StringElement>\n    <RD::Emphasis>\n      " +
                 "<RD::StringElement>", de2.inspect)
  end
end
