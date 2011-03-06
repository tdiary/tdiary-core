require 'test/unit'

require 'rd/document-struct.rb'
require 'rd/rdfmt'

class TestDocumentStructure < Test::Unit::TestCase
  include RD

  def test_each_relationship
    a = DocumentStructure.new
    r1 = ElementRelationship.new(TextBlock, InlineElement)
    r2 = ElementRelationship.new(DocumentElement, BlockElement)
    r3 = ElementRelationship.new(ListItem, BlockElement)
    r4 = ElementRelationship.new(ItemList, ItemListItem)
    exp = [r1, r2, r3, r4]

    a.add_relationships(*exp)

    a.each_relationship do |i|
      assert(exp.include?(i))
      exp.delete(i)
    end
    assert_equal([], exp)
  end

  def test_is_valid?
    a = DocumentStructure.new
    r1 = ElementRelationship.new(TextBlock, InlineElement)
    r2 = ElementRelationship.new(DocumentElement, BlockElement)
    r3 = ElementRelationship.new(ListItem, BlockElement)
    r4 = ElementRelationship.new(ItemList, ItemListItem)
    a.add_relationships(r1, r2, r3, r4)

    assert(a.is_valid?(TextBlock.new, Emphasis.new))
    assert(a.is_valid?(DocumentElement.new, TextBlock.new))
    assert(a.is_valid?(ItemList.new, ItemListItem.new))
    assert_false(a.is_valid?(TextBlock.new, Headline.new(1)))
    assert_false(a.is_valid?(ItemList.new, TextBlock.new))
  end
end

class TestElementRelationship < Test::Unit::TestCase
  include RD

  def test_match?
    a = ElementRelationship.new(TextBlock, InlineElement)
    assert(a.match?(TextBlock.new, Emphasis.new))
    assert_false(a.match?(TextBlock.new, Headline.new(1)))

    a = ElementRelationship.new(InlineElement, InlineElement)
    assert(a.match?(Emphasis.new, Code.new))
    assert_false(a.match?(Emphasis.new, Headline.new(1)))
    
    a = ElementRelationship.new(DocumentElement, BlockElement)
    assert(a.match?(DocumentElement.new, Headline.new(1)))
    assert_false(a.match?(DocumentElement.new, Emphasis.new))

    a = ElementRelationship.new(ItemList, ItemListItem)
    assert(a.match?(ItemList.new, ItemListItem.new))
    assert_false(a.match?(ItemList.new, TextBlock.new))
  end
end

def assert_false(cond)
  assert_equal(false, cond)
end
